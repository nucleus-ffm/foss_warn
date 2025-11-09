import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_error_logger.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/services/api_handler.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/services/warnings.dart';

import 'package:unifiedpush/unifiedpush.dart';
import '../main.dart';
import '../services/alert_api/fpas.dart';
import '../services/notification_handler.dart';
import '../widgets/dialogs/no_up_distributor_found_dialog.dart';
import '../widgets/dialogs/select_unified_push_distributor_dialog.dart';

/// Thrown when a UnifiedPush registration failed with a timeout
class UnifiedPushRegistrationTimeoutError implements Exception {}

final unifiedPushHandlerProvider = Provider(
  (ref) => UnifiedPushHandler(
    preferencesService: ref.watch(userPreferencesProvider.notifier),
    userPreferences: ref.watch(userPreferencesProvider),
  ),
);

class UnifiedPushHandler {
  const UnifiedPushHandler({
    required UserPreferencesService preferencesService,
    required UserPreferences userPreferences,
  })  : _preferencesService = preferencesService,
        _userPreferences = userPreferences;

  final UserPreferencesService _preferencesService;
  final UserPreferences _userPreferences;

  /// Callback function for the UnifiedPush  plugin
  /// this method gets called when a new endpoint is selected
  void onNewEndpoint(PushEndpoint endpoint, String instance) {
    debugPrint("new Endpoint:${endpoint.url}");
    if (instance != UserPreferences.unifiedPushInstance) return;

    // update preferences with the new URL and Keys
    _preferencesService.setUnifiedpushEndpoint(endpoint.url);
    if (endpoint.pubKeySet != null) {
      _preferencesService.setWebPushPublicKey(endpoint.pubKeySet!.pubKey);
      _preferencesService.setWebPushAuthKey(endpoint.pubKeySet!.auth);
    }
    _preferencesService.setUnifiedPushRegistered(true);
    //@TODO(Nucleus): we need to update the subscriptions and send the new endpoint to the server
  }

  /// Callback for the UnfiedPush plugin
  /// This method gets called with the registration failed
  /// For now we are just logging that error
  void onRegistrationFailed(FailedReason failedReason, String instance) {
    if (instance != UserPreferences.unifiedPushInstance) return;
    // @todo error handling
    ErrorLogger.writeErrorLog(
      "class_unifiedPushHandler",
      "UnifiedPush registration failed",
      failedReason.name,
    );
    debugPrint("Registration failed: ${failedReason.name}");
  }

  /// Callback for the UnifiedPush plugin
  /// This method gets called when the client unregisters from the distributor
  /// This updates the state in the preferences
  void onUnregistered(String instance) {
    debugPrint("onUnregistered called");
    if (instance != UserPreferences.unifiedPushInstance) return;

    debugPrint("onUnregistered called");
    _preferencesService.setUnifiedpushEndpoint("");
    _preferencesService.setUnifiedPushRegistered(false);
    _preferencesService.setWebPushVapidKey("");
    _preferencesService.setWebPushAuthKey("");
    _preferencesService.setWebPushPublicKey("");
  }

  /// callback for the UnifiedPush plugin
  /// This method handles incoming notification from unifiedPush
  Future<void> onMessage({
    required AlertAPI alertApi,
    required MyPlacesService myPlacesService,
    required PushMessage message,
    required WarningService warningService,
    required String instance,
    required WidgetRef ref,
    required BuildContext context,
  }) async {
    if (instance != UserPreferences.unifiedPushInstance) return;

    var payload = utf8.decode(message.content);
    debugPrint("Received a notification. Message: $payload");

    handleIncomingNotification(payload, ref);
  }

  /// register for push notifications and keep registration up to date
  /// This method needs to called at every app startup
  /// @TODO Nucleus: refactor this and use more smaller methods
  Future<void> setupUnifiedPush(
    BuildContext context,
    WidgetRef ref,
  ) async {
    // fetch fresh server config to check which push services are supported
    AlertAPI alertAPI = ref.read(alertApiProvider);
    ServerSettings serverSettings = await alertAPI.fetchServerSettings();
    // check if WebPush / encrypted UP is supported
    bool isEncryptedUnifiedPushSupported =
        serverSettings.supportedPushServices["UNIFIED_PUSH_ENCRYPTED"] ?? false;

    // Used to access the vapid key after a fresh fetch for some reason,
    // _userPreferences.webPushVapidKey is still empty after we called
    // setWebPushVapidKey. It takes some time until _userPreferences.webPushVapidKey
    // has the correct value.
    String? tempVapidKey;

    // if server supports WebPush, try to fetch the vapid key
    if (_userPreferences.webPushVapidKey == "" &&
        isEncryptedUnifiedPushSupported) {
      try {
        tempVapidKey = await alertAPI.fetchVapidKeyForWebPush();
        _preferencesService.setWebPushVapidKey(tempVapidKey);
      } on VapidKeyException {
        isEncryptedUnifiedPushSupported = false;
        ErrorLogger.writeErrorLog(
          "class_unified_push_handler.dart",
          "setup unifiedPush",
          "Failed to fetch VAPID key for webpush",
        );
      }
    }

    if (await UnifiedPush.getDistributor() != null) {
      // already registered - just register again without changing anything
      // register UnifiedPush with same distributor url and token as
      // this is required by the unifiedPush plugin
      await UnifiedPush.register(
        instance: UserPreferences
            .unifiedPushInstance, // Optional String, to get multiple endpoints (one per instance)
        vapid: tempVapidKey ?? _userPreferences.webPushVapidKey,
      );
    } else {
      // Get a list of distributors that are available
      List<String> distributors = await UnifiedPush.getDistributors(
        [], // Optional String Array with required features
      );

      if (distributors.isEmpty) {
        // there is no distributor installed. Inform user about it
        if (!context.mounted) return;
        await showDialog(
          context: context,
          builder: (context) => const NoUPDistributorFoundDialog(),
        );
        return;
      }

      if (!context.mounted) return;
      String? picked = await showDialog<String>(
        context: context,
        builder: selectUnifiedPushDistributorDialog(distributors),
      );

      // save the distributor
      await UnifiedPush.saveDistributor(picked ?? distributors.first);
      // register your app to the distributor
      try {
        await UnifiedPush.register(
          instance: UserPreferences.unifiedPushInstance,
          // optional String, to get multiple endpoints (one per instance)
          vapid: tempVapidKey ?? _userPreferences.webPushVapidKey,
        );
      } on MissingPluginException catch (e) {
        debugPrint("error while registering UnifiedPush: $e");
        return;
      }
      return;
    }
  }

  /// Change the current distributor to the new selected distributor
  /// This method first unregisters the old distributor and then registers
  /// again with the new selected Distributor
  /// The selected distributor has to be the [String] id of the distributor
  ///
  /// Throws an [UnifiedPushRegistrationTimeoutError] when the registration failed
  /// with en timeout error
  Future<void> changeDistributor(
    String selectedDistributor,
    WidgetRef ref,
  ) async {
    appState.reSubscriptionInProgress = true;
    await unregisterDistributor(ref);
    await registerDistributor(selectedDistributor, ref);
    // wait until the registration is finished we have a new endpoint
    await Future.doWhile(() async {
      await Future.delayed(const Duration(microseconds: 1));
      UserPreferences userPreferences = ref.read(userPreferencesProvider);
      return !userPreferences.unifiedPushRegistered;
    }).timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        debugPrint(
          "Timeout waiting for unifiedPushRegistered to be set to true.",
        );
        throw UnifiedPushRegistrationTimeoutError();
      },
    );
  }

  /// unregisters the current distributor and sets the unifiedPush
  /// registered flag in the setting to false
  Future<void> unregisterDistributor(WidgetRef ref) async {
    UnifiedPush.unregister(UserPreferences.unifiedPushInstance);
    await _preferencesService.setUnifiedPushRegistered(false);
  }

  /// Register for notifications with the given distributor
  Future<void> registerDistributor(
    String selectedDistributor,
    WidgetRef ref,
  ) async {
    debugPrint(
      "[unifiedPushHandler] register new distributor $selectedDistributor",
    );
    await UnifiedPush.saveDistributor(selectedDistributor);
    String? tempVapidKey;
    if (_userPreferences.webPushVapidKey == "") {
      // if server supports WebPush, try to fetch the vapid key
      if (_userPreferences.webPushVapidKey == "") {
        try {
          AlertAPI alertAPI = ref.read(alertApiProvider);
          tempVapidKey = await alertAPI.fetchVapidKeyForWebPush();
          _preferencesService.setWebPushVapidKey(tempVapidKey);
        } on VapidKeyException {
          ErrorLogger.writeErrorLog(
            "class_unified_push_handler.dart",
            "setup unifiedPush",
            "Failed to fetch VAPID key for webpush",
          );
        }
      }
    }

    // register your app to the distributor
    try {
      await UnifiedPush.register(
        instance: UserPreferences.unifiedPushInstance,
        vapid: tempVapidKey ?? _userPreferences.webPushVapidKey,
      );
    } on MissingPluginException catch (e) {
      //@TODO (Nucleus) do not catch this exception here
      debugPrint("error while registering UnifiedPush: $e");
      return;
    }
  }

  Future<List<Map<String, String>>> getListOfDistributors() async {
    List<Map<String, String>> result = [];
    List<String> distributors = await UnifiedPush.getDistributors();
    for (String distributor in distributors) {
      var split = distributor.split(".");
      String name = split.last;
      result.add({"name": name, "distributor": distributor});
    }
    return result;
  }

  Future<String?> getDistributor() async {
    return await UnifiedPush.getDistributor();
  }
}
