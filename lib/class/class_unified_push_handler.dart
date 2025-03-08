import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_error_logger.dart';
import 'package:foss_warn/services/api_handler.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/services/warnings.dart';

import 'package:unifiedpush/unifiedpush.dart';
import '../services/alert_api/fpas.dart';
import '../services/check_for_my_places_warnings.dart';
import 'package:foss_warn/main.dart';
import '../widgets/dialogs/no_up_distributor_found_dialog.dart';
import '../widgets/dialogs/select_unified_push_distributor_dialog.dart';

class UnifiedPushHandler {
  static void onNewEndpoint(PushEndpoint endpoint, String instance) {
    debugPrint("new Endpoint:${endpoint.url}");
    if (instance != userPreferences.unifiedPushInstance) {
      return;
    }
    userPreferences.unifiedPushRegistered = true;
    userPreferences.unifiedPushEndpoint = endpoint.url;
    if (endpoint.pubKeySet != null) {
      userPreferences.webPushPublicKey = endpoint.pubKeySet!.pubKey;
      userPreferences.webPushAuthKey = endpoint.pubKeySet!.auth;
    }
  }

  static void onRegistrationFailed(FailedReason failedReason, instance) {
    // @todo error handling
    ErrorLogger.writeErrorLog(
      "class_unifiedPushHandler",
      "UnifiedPush registration failed",
      failedReason.name,
    );
    debugPrint("Registration failed");
  }

  static void onUnregistered(String instance) {
    debugPrint("unregister");
    userPreferences.unifiedPushEndpoint = "";
    userPreferences.unifiedPushRegistered = false;
    // send unregister to server
    // @todo send unregister for each subscription
    /*http.post(
      Uri.parse(userPreferences.fossPublicAlertServerUrl +
          "/subscription/unsubscribe"),
      body: jsonEncode(<String, String>{
        'subscription_id': ,
      }),
    );*/
  }

  /// callback function to handle notification from unifiedPush
  static Future<void> onMessage({
    required AlertAPI alertApi,
    required MyPlacesService myPlacesService,
    required PushMessage message,
    required WarningService warningService,
    required String instance,
    required List<Place> myPlaces,
  }) async {
    debugPrint("instance $instance");
    if (instance != userPreferences.unifiedPushInstance) {
      return;
    }
    debugPrint("onNotification");
    // check if the message is successfully decrypted and add log error if not
    // if the message is not successfully decrypted check for myPlaceWarnings
    // anyway
    if (!message.decrypted) {
      ErrorLogger.writeErrorLog(
        "class_unified_push_handler.dart",
        "error while handling onMessage",
        "Message is not decrypted",
      );
    }
    var payload = utf8.decode(message.content);
    debugPrint("message: $payload");
    if (payload.contains("[DEBUG]") || payload.contains("[HEARTBEAT]")) {
      // system message or debug
    } else {
      checkForMyPlacesWarnings(
        alertApi: alertApi,
        myPlacesService: myPlacesService,
        warningService: warningService,
        places: myPlaces,
      );
    }
    return;
  }

  /// register for push notifications and keep registration up to date
  /// This methode needs to called at every app startup
  static Future<void> setupUnifiedPush(
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
    if (userPreferences.webPushVapidKey == null &&
        isEncryptedUnifiedPushSupported) {
      try {
        userPreferences.webPushVapidKey =
            await alertAPI.fetchVapidKeyForWebPush();
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
        userPreferences
            .unifiedPushInstance, // Optional String, to get multiple endpoints (one per instance)
        [], // Optional String Array with required features
        userPreferences.webPushVapidKey,
      );
    } else {
      // Get a list of distributors that are available
      List<String> distributors = await UnifiedPush.getDistributors([
        //featureAndroidBytesMessage,
      ] // Optionnal String Array with required features
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
        userPreferences
            .unifiedPushInstance, // optional String, to get multiple endpoints (one per instance)
        [], // Optional String Array with required features
        userPreferences.webPushVapidKey,
      );
    }

    debugPrint(
      "wait for registration state=${userPreferences.unifiedPushRegistered}",
    );
    // wait for the registration to finish
    if (!userPreferences.unifiedPushRegistered) {
      await Future.doWhile(() async {
        await Future.delayed(const Duration(microseconds: 1));
        return !userPreferences.unifiedPushRegistered;
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
