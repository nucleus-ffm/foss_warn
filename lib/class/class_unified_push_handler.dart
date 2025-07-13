import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_error_logger.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/class/class_warn_message.dart';
import 'package:foss_warn/services/api_handler.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/services/warnings.dart';

import 'package:unifiedpush/unifiedpush.dart';
import '../services/alert_api/fpas.dart';
import '../widgets/dialogs/no_up_distributor_found_dialog.dart';
import '../widgets/dialogs/select_unified_push_distributor_dialog.dart';
import 'class_notification_service.dart';

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

  void onNewEndpoint(PushEndpoint endpoint, String instance) {
    debugPrint("new Endpoint:${endpoint.url}");
    if (instance != UserPreferences.unifiedPushInstance) {
      return;
    }

    _preferencesService.setUnifiedpushEndpoint(endpoint.url);
    if (endpoint.pubKeySet != null) {
      _preferencesService.setWebPushPublicKey(endpoint.pubKeySet!.pubKey);
      _preferencesService.setWebPushAuthKey(endpoint.pubKeySet!.auth);
    }
    _preferencesService.setUnifiedPushRegistered(true);
    //@TODO(Nucleus): we need to update the subscriptions and send the new endpoint to the server
  }

  void onRegistrationFailed(FailedReason failedReason, String instance) {
    // @todo error handling
    ErrorLogger.writeErrorLog(
      "class_unifiedPushHandler",
      "UnifiedPush registration failed",
      failedReason.name,
    );
    debugPrint("Registration failed: ${failedReason.name}");
  }

  void onUnregistered(String instance) {
    debugPrint("onUnregistered called");
    _preferencesService.setUnifiedpushEndpoint("");
    _preferencesService.setUnifiedPushRegistered(false);
    _preferencesService.setWebPushVapidKey("");
    _preferencesService.setWebPushAuthKey("");
    _preferencesService.setWebPushPublicKey("");
  }

  /// callback function to handle notification from unifiedPush
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
    var userPreferences = ref.read(userPreferencesProvider);

    if (userPreferences.showDebugNotification) {
      NotificationService.showNotification(
        id: Random().nextInt(100),
        title: "DEBUG Notification",
        body:
            "FOSSWarn has received a push notification with content: $payload",
        payload: "",
        channelId: "de.nucleus.foss_warn.notifications_other",
        channelName: "Debug notifications",
      );
    }

    String? addedAlertId;

    try {
      var payloadAsJson = jsonDecode(payload) as Map<String, dynamic>;
      addedAlertId = payloadAsJson["alert_id"];
      if (addedAlertId != null) {
        WarnMessage alert = await ref.read(alertApiProvider).getAlertDetail(
              alertId: addedAlertId,
              placeSubscriptionId: "Not used",
            );
        if (checkIfEventShouldBeNotified(
          alert.info[0].severity,
          userPreferences,
        )) {
          NotificationService.showNotification(
            id: alert.identifier.hashCode,
            title: "New alert",
            body: alert.info.first.headline,
            payload: "",
            channelId:
                "de.nucleus.foss_warn.notifications_${alert.info[0].severity.name}",
            channelName: "",
          );
        }
      }
    } on FormatException catch (e) {
      debugPrint("Payload is not a json: $e");
    } on AlertUnavailableError catch (e) {
      debugPrint("Alert is not available anymore: $e");
      ErrorLogger.writeErrorLog(
        "class_unified_push_handler.dart",
        "onMessage",
        "Alert $addedAlertId is not available anymore",
      );
    }
    // @TODO(Nucleus): This is not the perfect solution as we can not check for already read alerts or if the alert is just an update. It would be preferable if we could fetch all alerts like we did before. Currently, this results in a "concurrent modification during iteration" error if the app is launched by a notification.
  }

  /// register for push notifications and keep registration up to date
  /// This method needs to called at every app startup
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
}
