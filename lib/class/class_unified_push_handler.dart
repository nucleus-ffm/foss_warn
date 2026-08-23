import 'dart:async';
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
import 'package:unifiedpush_platform_interface/unifiedpush_platform_interface.dart';
import 'package:unifiedpush_storage_shared_preferences/storage.dart';
import '../constants.dart' as constants;
import '../enums/alert_service.dart';
import '../services/alert_api/fpas.dart';
import '../services/notification_handler.dart';
import '../services/subscription_handler.dart';
import '../widgets/dialogs/no_up_distributor_found_dialog.dart';
import '../widgets/dialogs/select_unified_push_distributor_dialog.dart';

/// Thrown when a UnifiedPush registration failed with a timeout
class UnifiedPushRegistrationTimeoutError implements Exception {}

class UnifiedPushRegistrationError implements Exception {}

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

  // ------------------------------- callback ------------------------------------
  /// Callback function for the UnifiedPush  plugin
  /// this method gets called when a new endpoint is selected
  void onNewEndpoint({
    required PushEndpoint endpoint,
    required String instance,
    required WidgetRef ref,
  }) {
    debugPrint("new Endpoint:${endpoint.url} for instance $instance");
    if (instance != constants.unifiedPushInstance) return;

    // update preferences with the new URL and Keys
    _preferencesService.setUnifiedpushEndpoint(endpoint.url);
    if (endpoint.pubKeySet != null) {
      _preferencesService.setWebPushPublicKey(endpoint.pubKeySet!.pubKey);
      _preferencesService.setWebPushAuthKey(endpoint.pubKeySet!.auth);
    }
    _preferencesService.setUnifiedPushRegistered(true);

    updatePushNotificationConfigForSubscription(endpoint, ref);
  }

  /// Callback for the UnifiedPush plugin
  /// This method gets called with the registration failed
  /// For now we are just logging that error
  void onRegistrationFailed(FailedReason failedReason, String instance) {
    if (instance != constants.unifiedPushInstance) return;
    // @todo error handling
    ErrorLogger.writeLog(
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
    debugPrint("onUnregistered called for instance $instance");
    if (instance != constants.unifiedPushInstance) return;

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
    if (instance != constants.unifiedPushInstance) return;
    var payload = utf8.decode(message.content);
    debugPrint("Received a notification. Message: $payload");
    handleIncomingNotification(payload, ref);
  }

  // ------------------------- End callbacks --------------------------------//

  /// Initialize UnifiedPush
  Future<void> initialize(WidgetRef ref, BuildContext context) async {
    // init unified push
    // In a dev environment with multiple hot restarts, this registers multiple callbacks
    await UnifiedPush.initialize(
      onNewEndpoint: (PushEndpoint endpoint, String instance) => onNewEndpoint(
        endpoint: endpoint,
        instance: instance,
        ref: ref,
      ),
      onRegistrationFailed: onRegistrationFailed,
      onUnregistered: onUnregistered,
      linuxOptions: LinuxOptions(
        dbusName: "de.nucleus.foss_warn",
        storage: UnifiedPushStorageSharedPreferences(),
        background: false,
      ),
      onMessage: (message, instance) => onMessage(
        message: message,
        instance: instance,
        ref: ref,
        alertApi: ref.read(alertApiProvider),
        myPlacesService: ref.read(myPlacesProvider.notifier),
        warningService: ref.read(processedAlertsProvider.notifier),
        context: context,
      ),
    ).then((registered) async {
      var userPreferences = ref.read(userPreferencesProvider);
      if (registered) {
        // as we are already registered, we don't have to call setupUnifiedPush
        await registerDistributor();
      } else if (!registered &&
          (userPreferences.alertService == AlertService.push ||
              userPreferences.alertService == AlertService.pushAndPoll)) {
        // we are not already registered and the user wants to use push services
        if (!context.mounted) {
          return;
        }
        // setup unifiedPush if the app is not already registered
        setupUnifiedPush(context, ref);
      }
    });
  }

  /// register for UnifiedPush at the saved distributor
  ///
  /// [vapidKey] used if provided, otherwise, the stored key is used
  Future<void> registerDistributor({String? vapidKey}) async {
    await UnifiedPush.register(
      // Optional String, to get multiple endpoints (one per instance)
      instance: constants.unifiedPushInstance,
      messageForDistributor: constants.unifiedPushMessageForDistributor,
      vapid: vapidKey ?? _userPreferences.webPushVapidKey,
    ).timeout(const Duration(seconds: 10));
  }

  /// unregisters the current distributor and sets the unifiedPush
  /// registered flag in the setting to false
  Future<void> unregisterDistributor() async {
    await UnifiedPush.unregister(constants.unifiedPushInstance);
    await _preferencesService.setUnifiedPushRegistered(false);
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
        ErrorLogger.writeLog(
          "class_unified_push_handler.dart",
          "setup unifiedPush",
          "Failed to fetch VAPID key for webPush",
        );
        throw UnifiedPushRegistrationError();
      }
    }

    // Only register if not already registered
    if (await UnifiedPush.getDistributor() != null) {
      // already registered - skip
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

      // there are distributors installed, let the user choose one
      if (!context.mounted) return;
      String? picked = await showDialog<String>(
        context: context,
        builder: selectUnifiedPushDistributorDialog(distributors),
      );

      // save the selected distributor
      await UnifiedPush.saveDistributor(picked ?? distributors.first);
      // register the app to the selected distributor
      try {
        await registerDistributor(vapidKey: tempVapidKey);
      } on MissingPluginException catch (e) {
        debugPrint("Error while registering UnifiedPush: $e");
        throw UnifiedPushRegistrationError();
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
    // register listener to wait until the registration is finished and we have a new endpoint
    final completer = Completer<void>();
    final sub = ref.listenManual(userPreferencesProvider, (_, next) {
      if (next.unifiedPushRegistered && !completer.isCompleted) {
        completer.complete();
      }
    });
    try {
      await unregisterDistributor();
      await saveDistributor(selectedDistributor, ref);
      // check if already done before we started listening
      if (ref.read(userPreferencesProvider).unifiedPushRegistered &&
          !completer.isCompleted) {
        completer.complete();
      }
      await completer.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          debugPrint(
            "Timeout waiting for unifiedPushRegistered to be set to true.",
          );
          throw UnifiedPushRegistrationTimeoutError();
        },
      );
    } finally {
      sub.close();
    }
  }

  /// Register for notifications with the given distributor
  ///
  /// Fetch the Vapid key from the server, if not already stored in the settings
  Future<void> saveDistributor(
    String selectedDistributor,
    WidgetRef ref,
  ) async {
    debugPrint(
      "[unifiedPushHandler] save new distributor $selectedDistributor",
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
          ErrorLogger.writeLog(
            "class_unified_push_handler.dart",
            "setup unifiedPush",
            "Failed to fetch VAPID key for webpush",
          );
        }
      }
    }
    await registerDistributor(vapidKey: tempVapidKey);
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
