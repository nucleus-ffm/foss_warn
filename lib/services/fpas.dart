import 'dart:convert';
import 'dart:io';

import 'package:foss_warn/main.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class UnreachableServerError implements Exception {}

class ConnectionError implements Exception {}

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

/// Fetch the server settings from the given FPAS server. This sets in the
/// preferences the link to the privacy police, the terms of use and
/// the faps server url
///
/// [newUrl] the url of the new FPAS server
///
/// returns ServerSettings if the data was successfully fetched,
/// throws an exception if the url is not a valid FPAS server url or something
/// else went wrong
Future<ServerSettings> fetchFPASServerSettings(String url) async {
  Uri fpasUri = Uri.parse("$url/config/server_status");
  Response response;
  try {
    response = await http.get(
      fpasUri,
      headers: {
        "Content-Type": "application/json",
        'user-agent': userPreferences.httpUserAgent
      },
    );
  } on SocketException {
    throw ConnectionError();
  }

  if (response.statusCode != 200) {
    throw UnreachableServerError();
  }

  Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

  return ServerSettings(
    url: url,
    version: data["server_version"],
    operator: data["server_operator"],
    privacyNotice: data["privacy_notice"],
    termsOfService: data["terms_of_service"],
    congestionState: data["congestion_state"],
  );
}
