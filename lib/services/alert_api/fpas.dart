import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_bounding_box.dart';
import 'package:foss_warn/class/class_warn_message.dart';
import 'package:foss_warn/constants.dart' as constants;
import 'package:foss_warn/main.dart';
import 'package:foss_warn/services/api_handler.dart';
import 'package:http/http.dart' as http;
import 'package:xml2json/xml2json.dart';

final alertApiProvider = Provider(
  (ref) => FPASApi(serverUrl: userPreferences.fossPublicAlertServerUrl),
);

class FPASApi implements AlertAPI {
  // TODO(PureTryOut): make use of this once userPreferences is a StateProvider which we can listen to updates for
  final String _baseUrl;

  const FPASApi({required String serverUrl}) : _baseUrl = serverUrl;

  @override
  Future<ServerSettings> fetchServerSettings({String? overrideUrl}) async {
    var url = Uri.parse(
      "${overrideUrl ?? userPreferences.fossPublicAlertServerUrl}/config/server_status",
    );
    var response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'user-agent': constants.httpUserAgent,
      },
    );

    if (response.statusCode != 200) {
      throw UnreachableServerError();
    }

    Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

    return ServerSettings(
      url: overrideUrl ?? _baseUrl,
      version: data["server_version"],
      operator: data["server_operator"],
      privacyNotice: data["privacy_notice"],
      termsOfService: data["terms_of_service"],
      congestionState: data["congestion_state"],
      supportedPushServices: data["supported_push_services"],
    );
  }

  @override
  Future<List<AlertApiResult>> getAlerts({
    required String subscriptionId,
  }) async {
    var url = Uri.parse(
      "${userPreferences.fossPublicAlertServerUrl}/alert/all?subscription_id=$subscriptionId",
    );

    var response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'User-Agent': constants.httpUserAgent,
      },
    );

    switch (response.statusCode) {
      case 200: //nothing to do
        break;
      case 400:
        throw InvalidSubscriptionError();
      default:
        throw UndefinedServerError(
          statusCode: response.statusCode,
          message: response.body,
        );
    }

    var alerts = List<String>.from(jsonDecode(utf8.decode(response.bodyBytes)));
    return alerts
        .map((e) => (subscriptionId: subscriptionId, alertId: e))
        .toList();
  }

  @override
  Future<WarnMessage> getAlertDetail({
    required String alertId,
    required String placeSubscriptionId,
  }) async {
    var url =
        Uri.parse("${userPreferences.fossPublicAlertServerUrl}/alert/$alertId");

    var response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'User-Agent': constants.httpUserAgent,
      },
    );

    switch (response.statusCode) {
      case 200: // nothing to do
        break;
      default:
        throw UndefinedServerError(
          message: response.body,
          statusCode: response.statusCode,
        );
    }

    var xml2jsonTransformer = Xml2Json();
    xml2jsonTransformer.parse(utf8.decode(response.bodyBytes));

    var json = xml2jsonTransformer.toParker();
    var alert = jsonDecode(json) as Map<String, dynamic>;

    return WarnMessage.fromJson(
      alert["alert"],
      fpasId: alertId,
      placeSubscriptionId: placeSubscriptionId,
    );
  }

  @override
  Future<void> sendHeartbeat({required String subscriptionId}) async {
    var url = Uri.parse(
      "${userPreferences.fossPublicAlertServerUrl}/subscription/?subscription_id=$subscriptionId",
    );

    var response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        'User-Agent': constants.httpUserAgent,
      },
    );

    if (response.statusCode != 200) {
      throw PlaceSubscriptionError();
    }
  }

  @override
  Future<String> registerArea({
    required BoundingBox boundingBox,
    required String unifiedPushEndpoint,
  }) async {
    var url =
        Uri.parse("${userPreferences.fossPublicAlertServerUrl}/subscription/");

    ServerSettings serverSettings = await fetchServerSettings();
    // check if webpush / encrypted UP is supported
    bool isEncryptedUnifiedPushSupported =
        serverSettings.supportedPushServices["UNIFIED_PUSH_ENCRYPTED"] ?? false;

    // use new webpush (aka encrypted unifiedPush) if possible and use
    // unencrypted unifiedPush as fallback
    String pushService = "";
    if (userPreferences.webPushVapidKey != null &&
        userPreferences.webPushAuthKey != null &&
        userPreferences.webPushPublicKey != null &&
        isEncryptedUnifiedPushSupported) {
      pushService = "UNIFIED_PUSH_ENCRYPTED";
    } else {
      pushService = "UNIFIED_PUSH";
    }

    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        'User-Agent': constants.httpUserAgent,
      },
      body: jsonEncode({
        'token': unifiedPushEndpoint,
        'push_service': pushService,
        'min_lat': boundingBox.minLatLng.latitude.toString(),
        'max_lat': boundingBox.maxLatLng.latitude.toString(),
        'min_lon': boundingBox.minLatLng.longitude.toString(),
        'max_lon': boundingBox.maxLatLng.longitude.toString(),
        'p256dh_key': userPreferences.webPushPublicKey,
        'auth_key': userPreferences.webPushAuthKey,
      }),
    );

    if (response.statusCode != 200) {
      throw RegisterAreaError(
        statusCode: response.statusCode,
        message: response.body,
      );
    }

    Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data["subscription_id"];
  }

  @override
  Future<void> unregisterArea({required String subscriptionId}) async {
    var url = Uri.parse(
      "${userPreferences.fossPublicAlertServerUrl}/subscription/?subscription_id=$subscriptionId",
    );

    try {
      var response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          'User-Agent': constants.httpUserAgent,
        },
      );
      switch (response.statusCode) {
        case 200: // successfully unsubscribed
          break;
        case 400: // invalid subscription id. Subscriptions was already deleted
          break;
        default:
          throw UnregisterAreaError();
      }
    } on SocketException {
      throw UnregisterAreaError();
    }
  }

  @override
  Future<String> fetchVapidKeyForWebPush() async {
    var url = Uri.parse(
      "${userPreferences.fossPublicAlertServerUrl}/subscription/?type=webpush",
    );

    var response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'User-Agent': constants.httpUserAgent,
      },
    );

    if (response.statusCode != 200) {
      throw VapidKeyException();
    }

    Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data['vapid-key'];
  }
}
