import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_error_logger.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/main.dart';

import '../class/class_alert_swiss_place.dart';
import '../class/class_nina_place.dart';
import '../class/class_warn_message.dart';
import '../class/abstract_place.dart';
import 'alert_swiss.dart';
import 'list_handler.dart';
import 'send_status_notification.dart';
import 'save_and_load_shared_preferences.dart';

import 'package:http/http.dart';

/// call the nina api and load for myPlaces the warnings
Future<void> callAPI() async {
  bool successfullyFetched = true;
  String error = "";
  List<WarnMessage> tempWarnMessageList = [];
  tempWarnMessageList.clear();
  String baseUrl = "https://warnung.bund.de/api31";
  dynamic data; //var for response _data
  // String geocode = "071110000000"; // just for testing

  debugPrint("call API");

  await loadSettings();
  await loadMyPlacesList();

  for (Place place in myPlaceList) {
    // if the place is for swiss skip this place
    // print(place.name);
    if (place is AlertSwissPlace) {
      if (!userPreferences.activateAlertSwiss) {
        successfullyFetched = false;
        error += "Sie haben einen AlertSwiss Ort hinzugefügt,"
            " aber AlertSwiss nicht als Quelle aktiviert \n";
      }
      continue;
    }
    // FPAS Place
    else if (place is FPASPlace) {
      await place.callAPI();
    }
    // it is a nina place
    else if (place is NinaPlace) {
      try {
        Response response;
        response = await getDashboard(place, baseUrl)
            .timeout(userPreferences.networkTimeout);

        // 304 = with etag no change since last request
        if (response.statusCode == 304) {
          debugPrint("Nothing change for: ${place.name}");
        }
        // 200 = check if request was successfully
        else if (response.statusCode == 200) {
          // decode the _data
          data = jsonDecode(utf8.decode(response.bodyBytes));
          tempWarnMessageList.clear();
          // parse the _data into List of Warnings
          tempWarnMessageList = await parseNinaJsonData(data, baseUrl, place)
              .timeout(userPreferences.networkTimeout);

          // remove old warning
          removeOldWarningFromList(place, tempWarnMessageList);
          userPreferences.areWarningsFromCache = false;
          debugPrint("Saving myPlacesList with new warnings");
          // store warning
          saveMyPlacesList();
        }
        // connection error
        else {
          debugPrint("could not reach: ");
          successfullyFetched = false;
          error += "Failed to get warnings for:  ${place.name}"
              " (Statuscode:  ${response.statusCode} ) \n";
        }
      } catch (e) {
        debugPrint(
            "Something went wrong while trying to call the NINA API:  $e");
        successfullyFetched = false;
        // set areWarningFrom cache to true to display information
        userPreferences.areWarningsFromCache = true;
        error += "$e \n";
        // write to log
        await ErrorLogger.writeErrorLog(
            "apiHandler.dart",
            "Something went wrong while trying to call the NINA API}",
            e.toString());
      }
    }

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

  // call alert Swiss
  if (userPreferences.activateAlertSwiss) {
    await callAlertSwissAPI();
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

/// call the dashboard for the given place and return the response
/// uses etag to only fetch the site if there are changes
Future<Response> getDashboard(NinaPlace place, String baseUrl) async {
  Response response; //response var for get request

  // the warnings are only on kreisebene wo we only care about the first 5
  // letters from the code and fill the rest with 0s
  debugPrint(place.geocode.geocodeNumber);
  String geocode = "${place.geocode.geocodeNumber.substring(0, 5)}0000000";
  Uri urlDashboard = Uri.parse("$baseUrl/dashboard/$geocode.json");

  debugPrint("call: $baseUrl/dashboard/$geocode.json");
  // get overview if warnings exits for myplaces
  debugPrint("Etag for: ${place.name} is ${place.eTag}");

  response = await get(urlDashboard, headers: {'If-None-Match': place.eTag});

  place.eTag = response.headers["etag"]!;
  debugPrint("new etag for: ${place.name} is:  ${response.headers["etag"]}");
  return response;
}

void _checkIFAlertIsUpdate(WarnMessage newAlert, NinaPlace place) {
  // check if there is a referenced warning
  if (newAlert.references != null) {
    // check if one of the referenced alerts is already in the warnings list
    for (WarnMessage warnMessage in place.warnings) {
      if (newAlert.references!.identifier
          .any((element) => warnMessage.identifier == element)) {
        // if there is a referenced alert, used the same value for notified.

        // use the notified value of the referenced warning, but only if the severity is still the same or lesser
        if (newAlert.info[0].severity.index >=
            warnMessage.info[0].severity.index) {
          newAlert.isUpdateOfAlreadyNotifiedWarning = warnMessage.notified;
        }

        //@todo display warning, if original warning is older then 24h
      }
    }
  }
}

/// crate from the given data a new List<WarnMessage and return the list
Future<List<WarnMessage>> parseNinaJsonData(
    dynamic data, String baseUrl, NinaPlace place) async {
  List<WarnMessage> tempWarnMessageList = [];
  for (int i = 0; i < data.length; i++) {
    String id = data[i]["payload"]["id"];
    String provider = data[i]["payload"]["data"]["provider"];
    debugPrint("provider: $provider");
    Response responseDetails = await getWarningDetails(baseUrl, id);
    // check if request was successfully
    if (responseDetails.statusCode == 200) {
      // load coordinates from tge geocode API
      dynamic geoJsonRaw =
          utf8.decode((await getGeoJson(id, baseUrl)).bodyBytes);

      String geoJson = geoJsonRaw.toString();

      var warningDetails = jsonDecode(utf8.decode(responseDetails.bodyBytes));
      // create the new WarnMessage
      WarnMessage? temp = createWarning(warningDetails, provider, geoJson);
      if (temp != null) {
        tempWarnMessageList.add(temp);
        // check if new warnings isn't already in the list
        if (!place.warnings
            .any((element) => element.identifier == temp.identifier)) {
          _checkIFAlertIsUpdate(temp, place);

          /*print("add warning to p: " +
              temp.info[0].headline +
              "" +
              " " +
              temp.notified.toString()); */
          place.addWarningToList(temp);
        }

        // //@todo: fix displaying warnings twice
      }
    } else {
      debugPrint("[callAPI] Error: tried calling: $baseUrl/warnings/$id.json");
    }
  }
  return tempWarnMessageList;
}

/// check if stored warnings are still up-to-date and remove if not
void removeOldWarningFromList(
    NinaPlace place, List<WarnMessage> tempWarnMessageList) {
  // remove old warnings
  List<WarnMessage> warnMessagesToRemove = [];
  for (WarnMessage msg in place.warnings) {
    // remove the msg if it is no longer in the list of new warnings
    if (!tempWarnMessageList.any((tmp) => tmp.identifier == msg.identifier)) {
      warnMessagesToRemove.add(msg);
    }
  }
  for (WarnMessage message in warnMessagesToRemove) {
    place.removeWarningFromList(message);
  }
}

// void markUpdatesOfNotifiedWarningsAsNotified() {} @todo

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
