import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_ErrorLogger.dart';

import 'package:unifiedpush/constants.dart';
import 'package:unifiedpush/unifiedpush.dart';
import '../services/checkForMyPlacesWarnings.dart';
import '../services/saveAndLoadSharedPreferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:foss_warn/main.dart';
import '../widgets/dialogs/NoUPDistributorFoundDialog.dart';
import '../widgets/dialogs/selectUnifiedPushDistributorDialog.dart';
import 'class_BoundingBox.dart';

class UnifiedPushHandler {
  static void onNewEndpoint(String _endpoint, String _instance) {
    print("new Entpoint:" + _endpoint);
    if (_instance != userPreferences.unifiedPushInstance) {
      return;
    }
    userPreferences.unifiedPushRegistered = true;
    userPreferences.unifiedPushEndpoint = _endpoint;
    saveSettings();
  }

  static void onRegistrationFailed(String instance) {
    // @todo error handling
    ErrorLogger.writeErrorLog(
        "class_unifiedPushHandler", "UnifiedPush registration failed", "");
    print("Registration failed");
  }

  static void onUnregistered(String instance) {
    print("unregister");
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
  static Future<bool> onMessage(Uint8List _message, String _instance) async {
    debugPrint("instance " + _instance);
    if (_instance != userPreferences.unifiedPushInstance) {
      return false;
    }
    debugPrint("onNotification");
    var payload = utf8.decode(_message);
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
    print("setup distributor");
    // Check if a distributor is already registered
    if( await UnifiedPush.getDistributor() != "" && await UnifiedPush.getDistributor() != null) {
      // enpoint already setted up. Nothing to change
      return;
    } else if (await UnifiedPush.getDistributor() != null) {
      // Re-register in case something broke
      await UnifiedPush.registerApp(
          userPreferences.unifiedPushInstance, // Optional String, to get multiple endpoints (one per instance)
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

      if(distributors.length == 0) {
        // there is no distributor installed. Inform user about it
        await showDialog(
          context: context,
          builder: (context) =>  NoUPDistributorFoundDialog(),
        );
        return;
      }

      String? picked;
      picked = await showDialog<String>(
        context: context,
        builder: SelectUnifiedPushDistributorDialog(distributors),
      );

      // save the distributor
      await UnifiedPush.saveDistributor(picked?? distributors.first);
      // register your app to the distributor
      await UnifiedPush.registerApp(
          userPreferences.unifiedPushInstance, // optional String, to get multiple endpoints (one per instance)
          [
            featureAndroidBytesMessage
          ] // Optional String Array with required features
          );
    }

    print("wait for registration state=${userPreferences.unifiedPushRegistered}");
    // wait for the registration to finish
    if(!userPreferences.unifiedPushRegistered) {
      //@todo add timeout
      await Future.doWhile(() => userPreferences.unifiedPushRegistered).timeout(Duration(seconds: 20), onTimeout: () {return;});
    }

    print("distributor setup done: mit ${await UnifiedPush.getDistributor()} und ${userPreferences.unifiedPushEndpoint}");
  }

  /// register client for the given area
  /// requires that unifiedPush is already setted up
  /// and there is already an endpoint stored. Call setupUnifiedPush before.
  static Future<String> registerForArea(
      BuildContext? context, BoundingBox boundingBox) async {
    print("register for area");

    if (userPreferences.unifiedPushEndpoint == "") {
      throw Exception("No UnifiedPush Endpoint is set up. Can not subscribe");
    } else {
      print(userPreferences.unifiedPushEndpoint);
      // register for bounding box
      Response _response = await http.post(
        Uri.parse(userPreferences.fossPublicAlertServerUrl +
            "/subscription/subscribe"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'distributor_url': userPreferences.unifiedPushEndpoint,
          'min_lat': boundingBox.min_latLng.latitude.toString(),
          'max_lat': boundingBox.max_latLng.latitude.toString(),
          'min_lon': boundingBox.min_latLng.longitude.toString(),
          'max_lon': boundingBox.max_latLng.longitude.toString()
        }),
      );
      if (_response.statusCode == 200) {
        // registration successfully, store subscription id
        dynamic _data = jsonDecode(utf8.decode(_response.bodyBytes));
        return _data["id"];
      } else {
        throw Exception(
            "UnifiedPush registration failed. Server returned status code ${_response.statusCode} with body: ${_response.body}");
      }
    }
  }

  /// unregister for push Notification for the given subscription ID
  static Future<bool> unregisterForArea(String subscriptionId) async {
    if (userPreferences.unifiedPushRegistered &&
        userPreferences.unifiedPushEndpoint != "") {
      Response _response = await http.post(
        Uri.parse(userPreferences.fossPublicAlertServerUrl +
            "/subscription/unsubscribe"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'subscription_id': subscriptionId,
        }),
      );
      if (_response.statusCode == 200) {
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
