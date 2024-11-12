import 'dart:convert';
import 'package:foss_warn/class/class_BoundingBox.dart';
import 'package:foss_warn/class/abstract_Place.dart';
import 'package:foss_warn/main.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';

import 'class_ErrorLogger.dart';
import 'class_NotificationService.dart';
import 'class_WarnMessage.dart';
import 'class_UnifiedPushHandler.dart';

class FPASPlace extends Place {
  BoundingBox boundingBox;
  String subscriptionId;

  FPASPlace(
      {required this.boundingBox,
      required this.subscriptionId,
      required String name})
      : super(name: name, warnings: [], eTag: "");

  FPASPlace.withWarnings(
      {required this.boundingBox,
      required this.subscriptionId,
      required String name,
      required List<WarnMessage> warnings,
      required String eTag})
      : super(name: name, warnings: warnings, eTag: eTag);

  factory FPASPlace.fromJson(Map<String, dynamic> json) {
    /// create new warnMessage objects from saved data
    List<WarnMessage> createWarningList(String data) {
      List<dynamic> _jsonData = jsonDecode(data);
      List<WarnMessage> result = [];
      for (int i = 0; i < _jsonData.length; i++) {
        result.add(WarnMessage.fromJson(_jsonData[i]));
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
      print("Error FPASPlace to json: " + e.toString());
      ErrorLogger.writeErrorLog(
          "class_FPASPlace.dart", "Can not serialize FPASPlace", e.toString());
      return {};
    }
  }

  Future<void> callAPI() async {
    try {
      Uri urlOverview =
          Uri.parse(userPreferences.fossPublicAlertServerUrl + "/alert/all");

      Response _response = await http.post(
        urlOverview,
        headers: {
          "Content-Type": "application/json",
          'user-agent': "fosswarn"
        }, //@todo
        body: jsonEncode(
          {
            'subscription_id': subscriptionId,
          },
        ),
      );
      print(_response.body);
      dynamic _data = jsonDecode(utf8.decode(_response.bodyBytes));
      final myTransformer = Xml2Json();
      // fetch every alert
      for (String alertID in _data) {
        Uri urlAlert = Uri.parse(
            userPreferences.fossPublicAlertServerUrl + "/alert/${alertID}");
        Response _response = await http.get(
          urlAlert,
          headers: {"Content-Type": "application/json"},
        );
        myTransformer.parse(utf8.decode(_response.bodyBytes));

        dynamic _json = myTransformer.toParker();
        dynamic _alert = jsonDecode(_json);
        String _alertId = _alert["alert"]["identifier"];
        // store only new warnings
        if (!warnings.any((element) => element.identifier == _alertId)) {
          // _checkIFAlertIsUpdate(temp, place); //@todo
          print(_alert);
          WarnMessage newAlert = WarnMessage.fromJsonFPAS(_alert["alert"]);
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
      for (WarnMessage warnMessage in this.warnings) {
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
          userPreferences.fossPublicAlertServerUrl + "/subscription/heartbeat");

      Response _response = await http.post(
        heartbeatUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'subscription_id': this.subscriptionId,
        }),
      );
      if (_response.statusCode == 200) {
        // heartbeat successful
      } else if (_response.statusCode == 400) {
        // subscription timed out, register again
        try {
          String newSubscriptionID =
              await UnifiedPushHandler.registerForArea(null, this.boundingBox);
          // update subscription id
          this.subscriptionId = newSubscriptionID;
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
}
