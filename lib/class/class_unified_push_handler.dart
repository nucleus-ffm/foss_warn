import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_error_logger.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/services/api_handler.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/services/warnings.dart';

import 'package:unifiedpush/unifiedpush.dart';
import '../services/alert_api/fpas.dart';
import '../widgets/dialogs/no_up_distributor_found_dialog.dart';
import '../widgets/dialogs/select_unified_push_distributor_dialog.dart';

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

    _preferencesService.setUnifiedPushRegistered(true);
    _preferencesService.setUnifiedpushEndpoint(endpoint.url);
    if (endpoint.pubKeySet != null) {
      _preferencesService.setWebPushPublicKey(endpoint.pubKeySet!.pubKey);
      _preferencesService.setWebPushAuthKey(endpoint.pubKeySet!.auth);
    }
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
    _preferencesService.setUnifiedpushEndpoint("");
    _preferencesService.setUnifiedPushRegistered(false);
  }

  /// callback function to handle notification from unifiedPush
  Future<void> onMessage({
    required AlertAPI alertApi,
    required MyPlacesService myPlacesService,
    required PushMessage message,
    required WarningService warningService,
    required String instance,
    required WidgetRef ref,
  }) async {
    if (instance != UserPreferences.unifiedPushInstance) return;

    var payload = utf8.decode(message.content);
    debugPrint("Received a notification. Message: $payload");

    if (payload.contains("[DEBUG]") || payload.contains("[HEARTBEAT]")) return;

    ref.invalidate(alertsFutureProvider);
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
    // check if webpush / encrypted UP is supported
    bool isEncryptedUnifiedPushSupported =
        serverSettings.supportedPushServices["UNIFIED_PUSH_ENCRYPTED"] ?? false;

    // if server supports webpush, try to fetch the vapid key
    if (_userPreferences.webPushVapidKey == null &&
        isEncryptedUnifiedPushSupported) {
      try {
        _preferencesService
            .setWebPushVapidKey(await alertAPI.fetchVapidKeyForWebPush());
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
        vapid: _userPreferences.webPushVapidKey,
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
      await UnifiedPush.register(
        instance: UserPreferences
            .unifiedPushInstance, // optional String, to get multiple endpoints (one per instance)
        vapid: _userPreferences.webPushVapidKey,
      );
      return;
    }

    // register with the distributor
    await UnifiedPush.register(instance: UserPreferences.unifiedPushInstance);

    debugPrint(
      "wait for registration state=${_userPreferences.unifiedPushRegistered}",
    );
    // wait for the registration to finish
    if (!_userPreferences.unifiedPushRegistered) {
      await Future.doWhile(() async {
        await Future.delayed(const Duration(microseconds: 1));
        return !_userPreferences.unifiedPushRegistered;
      }).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          debugPrint(
            "Timeout waiting for unifiedPushRegistered to be set to true.",
          );
          return;
        },
      );
    }
  }
}
