import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_error_logger.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/main.dart';

import '../class/class_warn_message.dart';
import 'list_handler.dart';
import 'send_status_notification.dart';
import 'save_and_load_shared_preferences.dart';

import 'package:http/http.dart';

/// call the FPAS api and load for myPlaces the warnings
Future<void> callAPI() async {
  bool successfullyFetched = true;
  String error = "";
  List<WarnMessage> tempWarnMessageList = [];
  tempWarnMessageList.clear();

  debugPrint("call API");

  await loadMyPlacesList();

  for (Place place in myPlaceList) {
    await place.callAPI();

    // set flag for updated alerts
    for (WarnMessage wm in place.warnings) {
      if (wm.references != null) {
        // the alert contains a reference, so it is an update of an previous alert
        // we search for the alert and add it to the update thread

        for (String id in wm.references!.identifier) {
          // check all warnings for references
          for (WarnMessage alWm in place.warnings) {
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

/// load the map data for the given endpoint
Future<Response> getMapData(String endpoint, String baseUrl) async {
  try {
    return await get(Uri.parse(baseUrl + endpoint))
        .timeout(userPreferences.networkTimeout);
  } catch (e) {
    debugPrint("Error while loading map data for $endpoint");
  }
  throw "loadingMapDataException";
}

/// load the details for the given warning id
Future<Response> getWarningDetails(String baseUrl, String id) async {
  try {
    return await get(Uri.parse("$baseUrl/warnings/$id.json"))
        .timeout(userPreferences.networkTimeout);
  } catch (e) {
    debugPrint("Error while loading warning detail for $id");
  }
  throw "loadingWarningsDetailsException";
}

/// load the geojson file fo
Future<Response> getGeoJson(String id, String baseUrl) async {
  try {
    Response response;
    Uri urlGeoJson = Uri.parse("$baseUrl/warnings/$id.geojson");
    response = await get(
      urlGeoJson,
    ); // headers: {'If-None-Match': place.eTag}
    return response;
  } catch (e) {
    debugPrint("Error while loading warning detail for $id");
  }
  throw "loadingWarningsGeoJsonException";
}

/// generate WarnMessage object
WarnMessage? createWarning(dynamic data, String provider, String geoJson) {
  /// generate empty list as placeholder

  //@todo how can this work??
  String findPublisher(var parameter) {
    for (int i = 0; i < parameter.length; i++) {
      if (parameter[i]["valueName"] == "sender_langname") {
        return parameter[i]["value"];
      }
    }
    return "Deutscher Wetterdienst";
  }

  try {
    return WarnMessage.fromJsonWithAPIData(
        data, provider, findPublisher(data["info"][0]["parameter"]), geoJson);
  } catch (e) {
    debugPrint(
        "[API Handler] Error while parsing warning: ${data["identifier"]} error: ${e.toString()}");
    // write to logfile
    ErrorLogger.writeErrorLog(
        "apiHandler.dart",
        "Error while parsing warning with ID  ${data["identifier"]}",
        e.toString());
    appState.error = true; // display error message
  }
  return null;
}

Future<void> callMapAPI() async {
  String baseUrl = "https://warnung.bund.de/api31";
  dynamic data;
  mapWarningsList.clear();

  List<List<String>> mapApis = [
    [
      "Mowas",
      "/mowas/mapData.json",
    ],
    ["Katwarn", "/katwarn/mapData.json"],
    ["Dwd", "/dwd/mapData.json"],
    ["Biwapp", "/biwapp/mapData.json"],
    ["Lhp", "/lhp/mapData.json"],
    ["police", "/police/mapData.json"],
  ];

  for (int i = 0; i < mapApis.length; i++) {
    try {
      Response response;
      response = await getMapData(mapApis[i][1], baseUrl);

      // 304 = with etag no change since last request
      if (response.statusCode == 304) {
        debugPrint("Nothing change for: ${mapApis[i][1]}");
      }
      // 200 = check if request was successfully
      else if (response.statusCode == 200) {
        // decode the _data
        data = jsonDecode(utf8.decode(response.bodyBytes));
        // parse the _data into List of Warnings
        mapWarningsList
            .addAll(await parseMapApiData(data, baseUrl, mapApis[i][0]));
      }
    } catch (e) {
      debugPrint(
          "[API Handler] Error while parsing map api data for ${mapApis[i][0]}. error: ${e.toString()}");
      // write to logfile
      appState.error = true;
      ErrorLogger.writeErrorLog(
          "apiHandler.dart",
          "Error while parsing map api data for ${mapApis[i][0]}",
          e.toString());
    }
  }
}

/// parse the map data, load the warning details and return a list of warnings
Future<List<WarnMessage>> parseMapApiData(
    dynamic data, String baseUrl, String provider) async {
  List<WarnMessage> result = [];
  for (int i = 0; i < data.length; i++) {
    String id = data[i]["id"];
    // load warning details
    Response responseDetails = await getWarningDetails(baseUrl, id);
    // check if request was successfully
    if (responseDetails.statusCode == 200) {
      // load coordinates from tge geocode API
      dynamic coordinatesRaw =
          utf8.decode((await getGeoJson(id, baseUrl)).bodyBytes);
      String geoJson = coordinatesRaw.toString();
      /*List<dynamic> coordinates =
          coordinatesRaw["features"][0]["geometry"]["coordinates"][0];*/
      var warningDetails = jsonDecode(utf8.decode(responseDetails.bodyBytes));
      // create the new WarnMessage
      WarnMessage? temp = createWarning(warningDetails, provider, geoJson);
      if (temp != null) {
        result.add(temp);
      }
    }
  }
  return result;
}
