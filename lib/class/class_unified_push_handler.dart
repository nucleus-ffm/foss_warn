import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_error_logger.dart';

import 'package:unifiedpush/constants.dart';
import 'package:unifiedpush/unifiedpush.dart';
import '../services/check_for_my_places_warnings.dart';
import 'package:foss_warn/main.dart';
import '../widgets/dialogs/no_up_distributor_found_dialog.dart';
import '../widgets/dialogs/select_unified_push_distributor_dialog.dart';

class UnifiedPushHandler {
  static void onNewEndpoint(String endpoint, String instance) {
    debugPrint("new Entpoint:$endpoint");
    if (instance != userPreferences.unifiedPushInstance) {
      return;
    }
    userPreferences.unifiedPushRegistered = true;
    userPreferences.unifiedPushEndpoint = endpoint;
  }

  static void onRegistrationFailed(String instance) {
    // @todo error handling
    ErrorLogger.writeErrorLog(
        "class_unifiedPushHandler", "UnifiedPush registration failed", "");
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
  static Future<bool> onMessage(Uint8List message, String instance) async {
    debugPrint("instance $instance");
    if (instance != userPreferences.unifiedPushInstance) {
      return false;
    }
    debugPrint("onNotification");
    var payload = utf8.decode(message);
    debugPrint("message: $payload");
    if (payload.contains("[DEBUG]") || payload.contains("[HEARTBEAT]")) {
      // system message or debug
    } else {
      checkForMyPlacesWarnings(true);
    }
    return true;
  }

  /// register for push notifications
  static Future<void> setupUnifiedPush(BuildContext context) async {
    debugPrint("setup distributor");
    // Check if a distributor is already registered
    if (await UnifiedPush.getDistributor() != "" &&
        await UnifiedPush.getDistributor() != null &&
        userPreferences.unifiedPushRegistered) {
      // enpoint already setted up. Nothing to change
      return;
    } else if (await UnifiedPush.getDistributor() != null) {
      // Re-register in case something broke
      await UnifiedPush.registerApp(
          userPreferences
              .unifiedPushInstance, // Optional String, to get multiple endpoints (one per instance)
          [
            featureAndroidBytesMessage
          ] // Optional String Array with required features
          );
    } else {
      // Get a list of distributors that are available
      List<String> distributors = await UnifiedPush.getDistributors([
        featureAndroidBytesMessage
      ] // Optionnal String Array with required features
          );

      if (distributors.isEmpty) {
        // there is no distributor installed. Inform user about it
        if (!context.mounted) return;
        await showDialog(
          context: context,
          builder: (context) => NoUPDistributorFoundDialog(),
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
      await UnifiedPush.registerApp(
          userPreferences
              .unifiedPushInstance, // optional String, to get multiple endpoints (one per instance)
          [
            featureAndroidBytesMessage
          ] // Optional String Array with required features
          );
    }

    debugPrint(
        "wait for registration state=${userPreferences.unifiedPushRegistered}");
    // wait for the registration to finish
    if (!userPreferences.unifiedPushRegistered) {
      await Future.doWhile(() async {
        await Future.delayed(Duration(microseconds: 1));
        return !userPreferences.unifiedPushRegistered;
      }).timeout(Duration(seconds: 20), onTimeout: () {
        debugPrint(
            "Timeout waiting for unifiedPushRegistered to be set to true.");
        return;

        // await Future.doWhile(() => !userPreferences.unifiedPushRegistered).timeout(Duration(seconds: 20), onTimeout: () {return;});
      });
    }
    // print("distributor setup done: mit ${await UnifiedPush.getDistributor()} und ${userPreferences.unifiedPushEndpoint}");
  }
}
