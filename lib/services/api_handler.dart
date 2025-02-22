import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_bounding_box.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/main.dart';

import '../class/class_warn_message.dart';
import 'send_status_notification.dart';
import 'save_and_load_shared_preferences.dart';

/// call the FPAS api and load for myPlaces the warnings
Future<void> callAPI({
  required AlertAPI alertApi,
  required List<Place> places,
}) async {
  bool successfullyFetched = true;
  String error = "";
  List<WarnMessage> tempWarnMessageList = [];
  tempWarnMessageList.clear();

  debugPrint("call API");

  await loadMyPlacesList();

  var placesWithWarningsList = <Place>[];
  for (Place place in places) {
    var alertIds =
        await alertApi.getAlerts(subscriptionId: place.subscriptionId);
    var warnings = await Future.wait([
      for (var alertId in alertIds) ...[
        alertApi.getAlertDetail(alertId: alertId),
      ],
    ]);

    for (var warning in warnings) {
      warning.isUpdateOfAlreadyNotifiedWarning = _isAlertAnUpdate(
        existingWarnings: warnings,
        newAlert: warning,
      );
    }

    var updatedPlace = Place.withWarnings(
      boundingBox: place.boundingBox,
      subscriptionId: place.subscriptionId,
      name: place.name,
      warnings: warnings,
      eTag: place.eTag,
    );
    placesWithWarningsList.add(updatedPlace);

    // set flag for updated alerts
    for (WarnMessage wm in updatedPlace.warnings) {
      if (wm.references != null) {
        // the alert contains a reference, so it is an update of an previous alert
        // we search for the alert and add it to the update thread

        for (String id in wm.references!.identifier) {
          // check all warnings for references
          for (WarnMessage alWm in updatedPlace.warnings) {
            debugPrint(alWm.identifier);
            if (alWm.identifier.compareTo(id) == 0) {
              // set flag to true to hide the previous alert in the overview
              alWm.hideWarningBecauseThereIsANewerVersion =
                  true; //@todo move to better location
            }
          }
        }
      }
    }
  }

  // update status notification if the user wants
  if (userPreferences.showStatusNotification) {
    if (error != "") {
      sendStatusUpdateNotification(successfullyFetched, error);
    } else {
      sendStatusUpdateNotification(successfullyFetched);
    }
  }

  debugPrint("finished calling API");
}

/// Check if the given alert is an update of a previous alert.
/// Returns the notified status of the original alert if the severity hasn't increased
bool _isAlertAnUpdate({
  required List<WarnMessage> existingWarnings,
  required WarnMessage newAlert,
}) {
  // check if there is a referenced warning
  if (newAlert.references != null) {
    // check if one of the referenced alerts is already in the warnings list
    for (WarnMessage warnMessage in existingWarnings) {
      if (newAlert.references!.identifier
          .any((identifier) => warnMessage.identifier == identifier)) {
        // if there is a referenced alert, used the same value for notified.
        // use the notified value of the referenced warning, but only if the severity is still the same or lesser
        if (newAlert.info[0].severity.index >=
            warnMessage.info[0].severity.index) {
          return warnMessage.notified;
        }
      }
    }
  }
  return false;
}

/// Indicates the server was unable to be reached
class UnreachableServerError implements Exception {}

/// Indicates the subscription for a given place has ran out and needs to be registered again
class PlaceSubscriptionError implements Exception {}

/// Thrown when the server indicates something went wrong while unregistering
class UnregisterAreaError implements Exception {}

/// Thrown when the server indicates something went wrong while registering
class RegisterAreaError implements Exception {}

class ServerSettings {
  final String url;
  final String version;
  final String operator;
  final String privacyNotice;
  final String termsOfService;
  final int congestionState;

  ServerSettings({
    required this.url,
    required this.version,
    required this.operator,
    required this.privacyNotice,
    required this.termsOfService,
    required this.congestionState,
  });
}

abstract class AlertAPI {
  /// Fetch the server settings from the given alert server.
  ///
  /// [overrideUrl] is the url of the server to retrieve the settings from.
  /// If not specified the URL given to the class will be used instead.
  ///
  /// Returns ServerSettings if the data was successfully fetched.
  ///
  /// Throws an exception if the url is not a valid FPAS server url or something
  /// else went wrong
  Future<ServerSettings> fetchServerSettings({String overrideUrl});

  /// Get all alerts for a given place.
  /// Make sure you have registered to the area before you retrieve alerts for it.
  /// [subscriptionId] is the subscription to get alerts for.
  ///
  /// Returns a list of alert ID's.
  Future<List<String>> getAlerts({required String subscriptionId});

  /// Get detail of an alert.
  /// [alertId] is the ID of an alert to retrieve details for.
  ///
  /// Returns a [WarnMessage] containing the detail of the alert.
  Future<WarnMessage> getAlertDetail({required String alertId});

  /// Send a heartbeat to the FPAS Server once a day to prevent the given subscription to be deleted.
  /// [subscriptionId] is the ID of the subscription to send a heartbeat for.
  ///
  /// Throws a [PlaceSubscriptionError] when the server doesn't know the subscription.
  Future<void> sendHeartbeat({required String subscriptionId});

  /// Subscribe to alerts from a specific area.
  /// Make sure the application has been registered to UnifiedPush first as the server requires it.
  /// [boundingBox] is the area to register to receive alerts for.
  ///
  /// Returns a [String] containing the subscription ID
  Future<String> registerArea({
    required BoundingBox boundingBox,
    required String unifiedPushEndpoint,
  });

  /// Unregister from a given subscription.
  /// [subscriptionId] is the ID of the subscription to unregister for.
  Future<void> unregisterArea({required String subscriptionId});
}
