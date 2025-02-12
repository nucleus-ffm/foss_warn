import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_bounding_box.dart';
import 'package:foss_warn/enums/severity.dart';
import 'package:foss_warn/main.dart';
import 'package:foss_warn/services/save_and_load_shared_preferences.dart';
import 'package:foss_warn/services/update_provider.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';

import 'class_error_logger.dart';
import 'class_notification_service.dart';
import 'class_warn_message.dart';

class Place {
  final String _name;
  final List<WarnMessage> _warnings;
  String eTag;

  BoundingBox boundingBox;
  String subscriptionId;

  Place({
    required String name,
    required this.boundingBox,
    required this.subscriptionId,
    List<WarnMessage> warnings = const [],
    String? eTag,
  })  : _name = name,
        _warnings = [],
        eTag = eTag ?? "";

  Place.withWarnings({
    required this.boundingBox,
    required this.subscriptionId,
    required String name,
    required List<WarnMessage> warnings,
    required this.eTag,
  })  : _name = name,
        _warnings = warnings;

  String get name => _name;
  int get countWarnings => warnings.length;
  List<WarnMessage> get warnings => _warnings;

  factory Place.fromJson(Map<String, dynamic> json) {
    /// create new warnMessage objects from saved data
    List<WarnMessage> createWarningList(String data) {
      List<dynamic> jsonData = jsonDecode(data);
      List<WarnMessage> result = [];
      for (int i = 0; i < jsonData.length; i++) {
        result.add(WarnMessage.fromJson(jsonData[i]));
      }
      return result;
    }

    return Place.withWarnings(
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
        'name': _name,
        'boundingBox': boundingBox,
        'subscriptionId': subscriptionId,
        'warnings': jsonEncode(_warnings),
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
        if (!_warnings.any((element) => element.identifier == alertId)) {
          debugPrint(alert);
          WarnMessage newAlert = WarnMessage.fromJsonFPAS(alert["alert"]);
          newAlert.isUpdateOfAlreadyNotifiedWarning =
              _checkIFAlertIsUpdate(newAlert);
          _warnings.add(newAlert);
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
      for (WarnMessage warnMessage in _warnings) {
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

  // control the list for warnings
  void addWarningToList(WarnMessage warnMessage) => _warnings.add(warnMessage);
  void removeWarningFromList(WarnMessage warnMessage) =>
      _warnings.remove(warnMessage);

  // check if all warnings in `warnings` are
  // also in the alreadyReadWarnings list
  bool checkIfAllWarningsAreRead() {
    for (WarnMessage myWarning in _warnings) {
      if (!myWarning.read &&
          !myWarning.hideWarningBecauseThereIsANewerVersion) {
        // there is min. one warning not read and which is not an update
        debugPrint("found unread warning: ${myWarning.info.first.headline}");
        return false;
      }
    }
    return true;
  }

  /// check if there is warning in the [_warnings] which is not yet in the
  /// alreadyNotifiedWarnings list.
  /// return [true] if there is warning which no notification
  bool checkIfThereIsAWarningToNotify() {
    for (WarnMessage myWarning in _warnings) {
      if (!myWarning.notified &&
          !myWarning.hideWarningBecauseThereIsANewerVersion &&
          _checkIfEventShouldBeNotified(myWarning.info[0].severity)) {
        // there is min. one warning without notification
        return true;
      }
    }
    return false;
  }

  /// checks if there can be a notification for a warning in [_warnings]
  Future<void> sendNotificationForWarnings() async {
    for (WarnMessage myWarnMessage in _warnings) {
      debugPrint(myWarnMessage.info[0].headline);

      if ((!myWarnMessage.read &&
              !myWarnMessage.notified &&
              !myWarnMessage.isUpdateOfAlreadyNotifiedWarning) &&
          _checkIfEventShouldBeNotified(myWarnMessage.info[0].severity)) {
        // Alert is not already read or shown as notification
        // set notified to true to avoid sending notification twice
        myWarnMessage.notified = true;

        await NotificationService.showNotification(
            // generate from the warning in the List the notification id
            // because the warning identifier is no int, we have to generate a hash code
            id: myWarnMessage.identifier.hashCode,
            title: "Neue Warnung für $_name",
            body: myWarnMessage.info[0].headline,
            payload: _name,
            channel: myWarnMessage.info[0].severity.name);
      } else if (myWarnMessage.isUpdateOfAlreadyNotifiedWarning &&
          !myWarnMessage.notified &&
          !myWarnMessage.read) {
        myWarnMessage.notified = true;
        await await NotificationService.showNotification(
            // generate from the warning in the List the notification id
            // because the warning identifier is no int, we have to generate a hash code
            id: myWarnMessage.identifier.hashCode,
            title: "Update einer Warnung für $_name",
            body: myWarnMessage.info[0].headline,
            payload: _name,
            channel: "de.nucleus.foss_warn.notifications_update");
      } else {
        debugPrint("there is no warning or the warning is not in "
            "the notificationSettingsImportance list");
      }
    }
  }

  /// set the read status from all warnings to true
  /// @ref to update view
  void markAllWarningsAsRead(WidgetRef ref) {
    for (WarnMessage myWarnMessage in _warnings) {
      myWarnMessage.read = true;
      NotificationService.cancelOneNotification(
          myWarnMessage.identifier.hashCode);
    }
    final updater = ref.read(updaterProvider);
    updater.updateReadStatusInList();
    saveMyPlacesList();
  }

  /// set the read and notified status from all warnings to false
  /// used for debug purpose
  /// [@ref] to update view
  void resetReadAndNotificationStatusForAllWarnings(WidgetRef ref) {
    for (WarnMessage myWarnMessage in _warnings) {
      myWarnMessage.read = false;
      myWarnMessage.notified = false;
    }
    final updater = ref.read(updaterProvider);
    updater.updateReadStatusInList();
    saveMyPlacesList();
  }

  /// Return [true] if the user wants a notification - [false] if not.
  ///
  /// The source should be listed in the List notificationSourceSettings.
  /// check if the user wants to be notified for
  /// the given source and the given severity
  ///
  /// example:
  ///
  /// Warning severity | Notification setting | notification?   <br>
  /// Moderate (2)     | Minor (3)            | 3 >= 2 => true  <br>
  /// Minor (3)        | Moderate (2)         | 2 >= 3 => false
  bool _checkIfEventShouldBeNotified(Severity severity) =>
      Severity.getIndexFromSeverity(
          userPreferences.notificationSourceSetting.notificationLevel) >=
      Severity.getIndexFromSeverity(severity);
}
