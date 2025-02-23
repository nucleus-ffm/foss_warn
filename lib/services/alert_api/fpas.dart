import 'dart:convert';

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
    );
  }

  @override
  Future<List<String>> getAlerts({required String subscriptionId}) async {
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

    return List<String>.from(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  @override
  Future<WarnMessage> getAlertDetail({required String alertId}) async {
    var url =
        Uri.parse("${userPreferences.fossPublicAlertServerUrl}/alert/$alertId");

    var response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        'User-Agent': constants.httpUserAgent,
      },
    );

    var xml2jsonTransformer = Xml2Json();
    xml2jsonTransformer.parse(utf8.decode(response.bodyBytes));

    var json = xml2jsonTransformer.toParker();
    Map<String, dynamic> alert = jsonDecode(json);

    return WarnMessage.fromJsonFPAS(alert["alert"]);
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

    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        'User-Agent': constants.httpUserAgent,
      },
      body: jsonEncode({
        'token': unifiedPushEndpoint,
        'push_service': "UNIFIED_PUSH",
        'min_lat': boundingBox.minLatLng.latitude.toString(),
        'max_lat': boundingBox.maxLatLng.latitude.toString(),
        'min_lon': boundingBox.minLatLng.longitude.toString(),
        'max_lon': boundingBox.maxLatLng.longitude.toString(),
      }),
    );

    if (response.statusCode != 200) {
      throw RegisterAreaError();
    }

    Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data["subscription_id"];
  }

  @override
  Future<void> unregisterArea({required String subscriptionId}) async {
    var url = Uri.parse(
      "${userPreferences.fossPublicAlertServerUrl}/subscription/?subscription_id=$subscriptionId",
    );

    var response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
        'User-Agent': constants.httpUserAgent,
      },
    );

    if (response.statusCode != 200) {
      throw UnregisterAreaError();
    }
  }
}
