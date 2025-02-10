import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_bounding_box.dart';
import 'package:foss_warn/class/abstract_place.dart';
import 'package:foss_warn/main.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';

import 'class_error_logger.dart';
import 'class_notification_service.dart';
import 'class_warn_message.dart';

class FPASPlace extends Place {
  BoundingBox boundingBox;
  String subscriptionId;

  FPASPlace(
      {required this.boundingBox,
      required this.subscriptionId,
      required super.name})
      : super(warnings: [], eTag: "");

  FPASPlace.withWarnings(
      {required this.boundingBox,
      required this.subscriptionId,
      required super.name,
      required super.warnings,
      required super.eTag});

  factory FPASPlace.fromJson(Map<String, dynamic> json) {
    /// create new warnMessage objects from saved data
    List<WarnMessage> createWarningList(String data) {
      List<dynamic> jsonData = jsonDecode(data);
      List<WarnMessage> result = [];
      for (int i = 0; i < jsonData.length; i++) {
        result.add(WarnMessage.fromJson(jsonData[i]));
      }
      return result;
    }

    return FPASPlace.withWarnings(
      name: json['name'] as String,
      boundingBox: BoundingBox.fromJson(json['boundingBox']),
      subscriptionId: json['subscriptionId'] as String,
      warnings: createWarningList(json['warnings']),
      eTag: (json['eTag'] ?? "") as String,
    );
  }

  Map<String, dynamic> toJson() {
    try {
      return {
        'name': name,
        'boundingBox': boundingBox,
        'subscriptionId': subscriptionId,
        'warnings': jsonEncode(warnings),
        'eTag': eTag
      };
    } catch (e) {
      debugPrint("Error FPASPlace to json: $e");
      ErrorLogger.writeErrorLog(
          "class_FPASPlace.dart", "Can not serialize FPASPlace", e.toString());
      return {};
    }
  }

  Future<void> callAPI() async {
    try {
      Uri urlOverview =
          Uri.parse("${userPreferences.fossPublicAlertServerUrl}/alert/all");

      Response response = await http.post(
        urlOverview,
        headers: {
          "Content-Type": "application/json",
          'user-agent': userPreferences.httpUserAgent
        }, //@todo check if that works as expected
        body: jsonEncode(
          {
            'subscription_id': subscriptionId,
          },
        ),
      );
      debugPrint(response.body);
      dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
      final myTransformer = Xml2Json();
      // fetch every alert
      for (String alertID in data) {
        Uri urlAlert = Uri.parse(
            "${userPreferences.fossPublicAlertServerUrl}/alert/$alertID");
        Response response = await http.get(
          urlAlert,
          headers: {"Content-Type": "application/json"},
        );
        myTransformer.parse(utf8.decode(response.bodyBytes));

        dynamic json = myTransformer.toParker();
        dynamic alert = jsonDecode(json);
        String alertId = alert["alert"]["identifier"];
        // store only new warnings
        if (!warnings.any((element) => element.identifier == alertId)) {
          // _checkIFAlertIsUpdate(temp, place); //@todo
          debugPrint(alert);
          WarnMessage newAlert = WarnMessage.fromJsonFPAS(alert["alert"]);
          newAlert.isUpdateOfAlreadyNotifiedWarning =
              _checkIFAlertIsUpdate(newAlert);
          warnings.add(newAlert);
        }
      }
    } catch (e) {
      // something went wrong
      ErrorLogger.writeErrorLog(
          "class_FPASPlace.dart", "callAPI()", e.toString());
      appState.error = true;
    }
  }

  /// check if the given alert is an update of an preivous alert
  /// returns the notified status of the original alert if
  /// the severity hasn't increased
  bool _checkIFAlertIsUpdate(WarnMessage newAlert) {
    // check if there is a referenced warning
    if (newAlert.references != null) {
      // check if one of the referenced alerts is already in the warnings list
      for (WarnMessage warnMessage in warnings) {
        if (newAlert.references!.identifier
            .any((element) => warnMessage.identifier == element)) {
          // if there is a referenced alert, used the same value for notified.

          // use the notified value of the referenced warning, but only if the severity is still the same or lesser
          if (newAlert.info[0].severity.index >=
              warnMessage.info[0].severity.index) {
            return warnMessage.notified;
          }

          //@todo display warning, if original warning is older then 24h
        }
      }
    }
    return false;
  }

  /// send a heartbeat to the FPAS Server once a day to prevent the
  /// subscription to be deleted
  /// @todo call function once a day
  Future<void> sendHeartbeatToFPAS() async {
    try {
      Uri heartbeatUrl = Uri.parse(
          "${userPreferences.fossPublicAlertServerUrl}/subscription/heartbeat");

      Response response = await http.post(
        heartbeatUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'subscription_id': subscriptionId,
        }),
      );
      if (response.statusCode == 200) {
        // heartbeat successful
      } else if (response.statusCode == 400) {
        // subscription timed out, register again
        try {
          String newSubscriptionID = await registerForArea(null, boundingBox);
          // update subscription id
          subscriptionId = newSubscriptionID;
        } catch (e) {
          // something went wrong. Write to error logger and inform user
          ErrorLogger.writeErrorLog("class_FPASPlace",
              "Error while resubscribing to area", e.toString());
          NotificationService.showNotification(
              id: 5,
              title: "Problem with subscription detected",
              body:
                  "There occurred a problem with you subscription. Please check the error logger and contact the developer",
              channel: "de.nucleus.foss_warn.notifications_other");
        }
      }
    } catch (e) {
      // something went wrong
      ErrorLogger.writeErrorLog(
          "class_FPASPlace", "sendHeartbeatToFPAS()", e.toString());
      appState.error = true;
    }
  }

  /// unregister for push Notification for the given subscription ID
  Future<bool> unregisterForArea() async {
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
          'token': userPreferences.unifiedPushEndpoint,
          'push_service': "UnifiedPush",
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
}
