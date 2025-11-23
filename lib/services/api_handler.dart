import 'package:foss_warn/class/class_bounding_box.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';

import '../class/class_app_state.dart';
import '../class/class_warn_message.dart';

/// Indicates the server was unable to be reached
class UnreachableServerError implements Exception {}

/// Indicates the server answered in an unexpected way with an error message
class UndefinedServerError implements Exception {
  final int statusCode;
  final String message;
  UndefinedServerError({required this.message, required this.statusCode});

  @override
  String toString() {
    return "UndefinedServerError: status code: $statusCode, message: $message";
  }
}

/// Indicates the subscription for a given place has ran out and needs to be registered again
class PlaceSubscriptionError implements Exception {}

/// Thrown when the server indicates something went wrong while unregistering
class UnregisterAreaError implements Exception {}

// Thrown when the server response indicates that the subscription is invalid or deleted
class InvalidSubscriptionError implements Exception {}

// Thrown when the requested alert is not available on the server anymore
class AlertUnavailableError implements Exception {}

typedef AlertApiResult = ({String subscriptionId, String alertId});

typedef SubscriptionApiResult = ({
  String subscriptionId,
  String confirmationId
});

/// Thrown when the server indicates something went wrong while registering
class RegisterAreaError implements Exception {
  final int statusCode;
  final String message;
  RegisterAreaError({required this.statusCode, required this.message});

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

  /// Fetch the for WebPush needed vapid key from the server
  ///
  /// Returns the vapid key as String if it was successfully fetched
  ///
  /// Throws an VapidKeyException if something went wrong
  Future<String> fetchVapidKeyForWebPush();

  /// Get all alerts for a given place.
  /// Make sure you have registered to the area before you retrieve alerts for it.
  /// [subscriptionId] is the subscription to get alerts for.
  ///
  /// Returns a list of alert ID's.
  ///
  /// Throws an [InvalidSubscriptionError] if the subscription is not valid
  ///
  /// Throws an [UndefinedServerError] if the server responded in an unexpected way
  Future<List<AlertApiResult>> getAlerts({
    required String subscriptionId,
    required AppState appState,
  });

  /// Get all alerts for a given area without subscription
  /// This does not require to subscribe beforehand and allows to display alert details
  /// of alerts on the map
  ///
  /// Returns a list of Alert ID's
  ///
  /// Throws an [UndefinedServerError] if the server responded in an unexpected way
  Future<List<AlertApiResult>> getAlertsForArea({
    required BoundingBox boundingBox,
  });

  /// Get detail of an alert.
  /// [alertId] is the ID of an alert to retrieve details for.
  /// [placeSubscriptionId] is the ID of the place subscription this alert belongs too.
  ///
  /// Returns a [WarnMessage] containing the detail of the alert.
  Future<WarnMessage> getAlertDetail({
    required String alertId,
    required String placeSubscriptionId,
  });

  /// Update the subscriptions at every app startup to prevent the given subscription to be deleted.
  /// [subscriptionId] is the ID of the subscription to send a heartbeat for.
  ///
  /// Throws a [PlaceSubscriptionError] when the server doesn't know the subscription.
  Future<void> updateSubscription({required String subscriptionId});

  /// Subscribe to alerts from a specific area.
  /// Make sure the application has been registered to UnifiedPush first as the server requires it.
  /// [boundingBox] is the area to register to receive alerts for.
  ///
  /// Returns a [String] containing the subscription ID
  ///
  /// Throws an [RegisterAreaError] if the registration was not successful
  Future<SubscriptionApiResult> registerArea({
    required BoundingBox boundingBox,
    required String unifiedPushEndpoint,
  });

  /// Unregister from a given subscription.
  /// [subscriptionId] is the ID of the subscription to unregister for.
  Future<void> unregisterArea({required String subscriptionId});

  /// Fetch the map style used to display all alerts on a map
  Future<Style> getMapStyle();
}
