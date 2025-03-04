import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_bounding_box.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/main.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:foss_warn/services/warnings.dart';

import '../class/class_warn_message.dart';
import 'send_status_notification.dart';
import 'save_and_load_shared_preferences.dart';

/// call the FPAS api and load for myPlaces the warnings
Future<void> callAPI({
  required AlertAPI alertApi,
  required WarningService warningService,
  required List<Place> places,
}) async {
  bool successfullyFetched = true;
  String error = "";
  List<WarnMessage> tempWarnMessageList = [];
  tempWarnMessageList.clear();

  debugPrint("call API");

  await loadMyPlacesList();

  for (Place place in places) {
    var alertIds =
        await alertApi.getAlerts(subscriptionId: place.subscriptionId);
    var warnings = await Future.wait([
      for (var alertId in alertIds) ...[
        alertApi.getAlertDetail(
          alertId: alertId,
          placeSubscriptionId: place.subscriptionId,
        ),
      ],
    ]);

    var updatedWarnings = <WarnMessage>[];
    for (var warning in warnings) {
      updatedWarnings.add(
        warning.copyWith(
          isUpdateOfAlreadyNotifiedWarning: _isAlertAnUpdate(
            existingWarnings: warnings,
            newWarning: warning,
          ),
        ),
      );
    }

    // set flag for updated alerts
    for (var warning in updatedWarnings) {
      if (warning.references == null) continue;

      // the alert contains a reference, so it is an update of an previous alert
      for (var referenceId in warning.references!.identifier) {
        // check all warnings for references
        var alWm =
            warnings.firstWhere((element) => element.identifier == referenceId);
        warnings.updateEntry(
          alWm.copyWith(hideWarningBecauseThereIsANewerVersion: true),
        );
      }
    }

    // Update the state
    warningService.set(updatedWarnings);
  }

  // update status notification if the user wants
  if (userPreferences.showStatusNotification) {
    if (error != "") {
      sendStatusUpdateNotification(successfullyFetched, error);
    } else {
      sendStatusUpdateNotification(successfullyFetched);
    }
  }
}

/// Check if the given alert is an update of a previous alert.
/// Returns the notified status of the original alert if the severity hasn't increased
bool _isAlertAnUpdate({
  required List<WarnMessage> existingWarnings,
  required WarnMessage newWarning,
}) {
  // check if there is a referenced warning
  if (newWarning.references != null) {
    // check if one of the referenced alerts is already in the warnings list
    for (var warning in existingWarnings) {
      if (newWarning.references!.identifier
          .any((identifier) => warning.identifier == identifier)) {
        // if there is a referenced alert, used the same value for notified.
        // use the notified value of the referenced warning, but only if the severity is still the same or lesser
        if (newWarning.info[0].severity.index >=
            warning.info[0].severity.index) {
          return warning.notified;
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

// Thrown if the server response indicates that the subscription is invalid or deleted on serverside
class InvalidSubscriptionError implements Exception {}

/// Thrown when the server indicates something went wrong while registering
class RegisterAreaError implements Exception {
  final String message;
  RegisterAreaError({required this.message});

  @override
  String toString() {
    return "RegisterAreaError: $message";
  }
}

/// Thrown when the server indicates something went wrong while fetching the vapid key
class VapidKeyException implements Exception {}

class ServerSettings {
  final String url;
  final String version;
  final String operator;
  final String privacyNotice;
  final String termsOfService;
  final int congestionState;
  final Map<String, dynamic> supportedPushServices;

  ServerSettings({
    required this.url,
    required this.version,
    required this.operator,
    required this.privacyNotice,
    required this.termsOfService,
    required this.congestionState,
    required this.supportedPushServices,
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

  /// fetch the for webpush needed vapid key from the server
  ///
  /// returns the vapid key as String if it was successfully fetched
  ///
  /// Throws an exception if something went wrong
  Future<String> fetchVapidKeyForWebPush();

  /// Get all alerts for a given place.
  /// Make sure you have registered to the area before you retrieve alerts for it.
  /// [subscriptionId] is the subscription to get alerts for.
  ///
  /// Returns a list of alert ID's.
  Future<List<String>> getAlerts({required String subscriptionId});

  /// Get detail of an alert.
  /// [alertId] is the ID of an alert to retrieve details for.
  /// [placeSubscriptionId] is the ID of the place subscription this alert belongs too.
  ///
  /// Returns a [WarnMessage] containing the detail of the alert.
  Future<WarnMessage> getAlertDetail({
    required String alertId,
    required String placeSubscriptionId,
  });

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
