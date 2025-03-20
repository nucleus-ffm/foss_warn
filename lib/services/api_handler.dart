import 'package:foss_warn/class/class_bounding_box.dart';

import '../class/class_warn_message.dart';

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
