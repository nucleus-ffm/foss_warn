import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_error_logger.dart';

import 'package:unifiedpush/constants.dart';
import 'package:unifiedpush/unifiedpush.dart';
import '../services/check_for_my_places_warnings.dart';
import '../services/save_and_load_shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:foss_warn/main.dart';
import '../widgets/dialogs/no_up_distributor_found_dialog.dart';
import '../widgets/dialogs/select_unified_push_distributor_dialog.dart';
import 'class_bounding_box.dart';

class UnifiedPushHandler {
  static void onNewEndpoint(String endpoint, String instance) {
    debugPrint("new Entpoint:$endpoint");
    if (instance != userPreferences.unifiedPushInstance) {
      return;
    }
    userPreferences.unifiedPushRegistered = true;
    userPreferences.unifiedPushEndpoint = endpoint;
    saveSettings();
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
    saveSettings();
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

  /// register client for the given area
  /// requires that unifiedPush is already setted up
  /// and there is already an endpoint stored. Call setupUnifiedPush before.
  static Future<String> registerForArea(
      BuildContext? context, BoundingBox boundingBox) async {
    debugPrint("register for area");

    if (userPreferences.unifiedPushEndpoint == "") {
      throw Exception("No UnifiedPush Endpoint is set up. Can not subscribe");
    } else {
      debugPrint(userPreferences.unifiedPushEndpoint);
      // register for bounding box
      Response response = await http.post(
        Uri.parse(
            "${userPreferences.fossPublicAlertServerUrl}/subscription/subscribe"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'distributor_url': userPreferences.unifiedPushEndpoint,
          'min_lat': boundingBox.minLatLng.latitude.toString(),
          'max_lat': boundingBox.maxLatLng.latitude.toString(),
          'min_lon': boundingBox.minLatLng.longitude.toString(),
          'max_lon': boundingBox.maxLatLng.longitude.toString()
        }),
      );
      if (response.statusCode == 200) {
        // registration successfully, store subscription id
        dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
        return data["id"];
      } else {
        throw Exception(
            "UnifiedPush registration failed. Server returned status code ${response.statusCode} with body: ${response.body}");
      }
    }
  }

  /// unregister for push Notification for the given subscription ID
  static Future<bool> unregisterForArea(String subscriptionId) async {
    if (userPreferences.unifiedPushRegistered &&
        userPreferences.unifiedPushEndpoint != "") {
      Response response = await http.post(
        Uri.parse(
            "${userPreferences.fossPublicAlertServerUrl}/subscription/unsubscribe"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'subscription_id': subscriptionId,
        }),
      );
      if (response.statusCode == 200) {
        // successfully unsubscribed
        return true;
      } else {
        //@todo store subscription ID in prefs to unsubscribe later,
        // if there is currently no internet connection
        return false;
      }
    } else {
      // can not unregister from server if the client is not registered
      return false;
    }
  }
}