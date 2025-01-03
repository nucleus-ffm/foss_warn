import 'dart:convert';
import 'package:foss_warn/class/class_ErrorLogger.dart';
import 'package:foss_warn/class/class_FPASPlace.dart';
import 'package:foss_warn/main.dart';

import '../class/class_AlertSwissPlace.dart';
import '../class/class_NinaPlace.dart';
import '../class/class_WarnMessage.dart';
import '../class/abstract_Place.dart';
import 'alertSwiss.dart';
import 'listHandler.dart';
import 'sendStatusNotification.dart';
import 'saveAndLoadSharedPreferences.dart';

import 'package:http/http.dart';

/// call the nina api and load for myPlaces the warnings
Future<void> callAPI() async {
  bool _successfullyFetched = true;
  String _error = "";
  List<WarnMessage> _tempWarnMessageList = [];
  _tempWarnMessageList.clear();
  String _baseUrl = "https://warnung.bund.de/api31";
  dynamic _data; //var for response _data
  // String geocode = "071110000000"; // just for testing

  print("call API");

  await loadSettings();
  await loadMyPlacesList();

  for (Place place in myPlaceList) {
    // if the place is for swiss skip this place
    // print(place.name);
    if (place is AlertSwissPlace) {
      if (!userPreferences.activateAlertSwiss) {
        _successfullyFetched = false;
        _error += "Sie haben einen AlertSwiss Ort hinzugefügt,"
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
        Response _response;
        _response = await getDashboard(place, _baseUrl)
            .timeout(userPreferences.networkTimeout);

        // 304 = with etag no change since last request
        if (_response.statusCode == 304) {
          print("Nothing change for: " + place.name);
        }
        // 200 = check if request was successfully
        else if (_response.statusCode == 200) {
          // decode the _data
          _data = jsonDecode(utf8.decode(_response.bodyBytes));
          _tempWarnMessageList.clear();
          // parse the _data into List of Warnings
          _tempWarnMessageList = await parseNinaJsonData(_data, _baseUrl, place)
              .timeout(userPreferences.networkTimeout);

          // remove old warning
          removeOldWarningFromList(place, _tempWarnMessageList);
          userPreferences.areWarningsFromCache = false;
          print("Saving myPlacesList with new warnings");
          // store warning
          saveMyPlacesList();
        }
        // connection error
        else {
          print("could not reach: ");
          _successfullyFetched = false;
          _error += "Failed to get warnings for:  ${place.name}"
              " (Statuscode:  ${_response.statusCode} ) \n";
        }
      } catch (e) {
        print("Something went wrong while trying to call the NINA API:  $e");
        _successfullyFetched = false;
        // set areWarningFrom cache to true to display information
        userPreferences.areWarningsFromCache = true;
        _error += e.toString() + " \n";
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
            print(alWm.identifier);
            if (alWm.identifier.compareTo(id) == 0) {
              // set flag to true to hide the previous alert in the overview
              alWm.hideWarningBecauseThereIsANewerVersion = true;//@todo move to better location
              }
            }
          }
      }
    }


  }
  // update status notification if the user wants
  if (userPreferences.showStatusNotification) {
    if (_error != "") {
      sendStatusUpdateNotification(_successfullyFetched, _error);
    } else {
      sendStatusUpdateNotification(_successfullyFetched);
    }
  }

  // call alert Swiss
  if (userPreferences.activateAlertSwiss) {
    await callAlertSwissAPI();
  }

  print("finished calling API");
}

/// load the map data for the given endpoint
Future<Response> getMapData(String endpoint, String baseUrl) async {
  try {
    return await get(Uri.parse(baseUrl + endpoint)).timeout(userPreferences.networkTimeout);
  } catch (e) {
    print("Error while loading map data for ${endpoint}");
  }
  throw "loadingMapDataException";
}

/// load the details for the given warning id
Future<Response> getWarningDetails(String baseUrl, String id) async {
  try {
    return await get(Uri.parse(baseUrl + "/warnings/" + id + ".json")).timeout(userPreferences.networkTimeout);
  } catch (e) {
    print("Error while loading warning detail for ${id}");
  }
  throw "loadingWarningsDetailsException";
}

/// load the geojson file fo
Future<Response> getGeoJson(String id, String baseUrl) async {
  try {
    Response _response;
    Uri _urlGeoJson = Uri.parse(baseUrl + "/warnings/" + id + ".geojson");
    _response = await get(
      _urlGeoJson,
    ); // headers: {'If-None-Match': place.eTag}
    return _response;
  } catch (e) {
    print("Error while loading warning detail for ${id}");
  }
  throw "loadingWarningsGeoJsonException";

}

/// generate WarnMessage object
WarnMessage? createWarning(
    dynamic data, String provider, String geoJson) {
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
    return WarnMessage.fromJsonWithAPIData(data, provider,
        findPublisher(data["info"][0]["parameter"]), geoJson);
  } catch (e) {
    print(
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
  Response _response; //response var for get request

  // the warnings are only on kreisebene wo we only care about the first 5
  // letters from the code and fill the rest with 0s
  print(place.geocode.geocodeNumber);
  String geocode = place.geocode.geocodeNumber.substring(0, 5) + "0000000";
  Uri _urlDashboard = Uri.parse(baseUrl + "/dashboard/" + geocode + ".json");

  print("call: " + baseUrl + "/dashboard/" + geocode + ".json");
  // get overview if warnings exits for myplaces
  print("Etag for: ${place.name} is ${place.eTag}");

  _response = await get(_urlDashboard, headers: {'If-None-Match': place.eTag});

  place.eTag = _response.headers["etag"]!;
  print("new etag for: ${place.name} is:  ${_response.headers["etag"]}");
  return _response;
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
  List<WarnMessage> _tempWarnMessageList = [];
  for (int i = 0; i < data.length; i++) {
    String id = data[i]["payload"]["id"];
    String provider = data[i]["payload"]["data"]["provider"];
    print("provider: " + provider);
    Response responseDetails = await getWarningDetails(baseUrl, id);
    // check if request was successfully
    if (responseDetails.statusCode == 200) {
      // load coordinates from tge geocode API
      dynamic geoJsonRaw =
          utf8.decode((await getGeoJson(id, baseUrl)).bodyBytes);

      String geoJson = geoJsonRaw.toString();

      //@todo find a cleaner solution later
      // geoJson from dwd can contain coordinates that are no doubles.
      // This results in an error when we try to convert it to a geoJson object
      // therefore, we replace every int coordinate with a double representation
      // of it by just adding .0
      geoJson = geoJson.replaceAllMapped(RegExp(r'\[\d+\,'), (Match m) => "[${m.group(0)?.replaceAll("[", "").replaceAll(",", "")}.0,");
      geoJson = geoJson.replaceAllMapped(RegExp(r'\s\d+]'), (Match m) => "${m.group(0)?.replaceAll("]", "").replaceAll(",", "")}.0]");


      var warningDetails = jsonDecode(utf8.decode(responseDetails.bodyBytes));
      // create the new WarnMessage
      WarnMessage? temp = createWarning(warningDetails, provider, geoJson);
      if (temp != null) {
        _tempWarnMessageList.add(temp);
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
      print("[callAPI] Error: tried calling: " +
          baseUrl +
          "/warnings/" +
          id +
          ".json");
    }
  }
  return _tempWarnMessageList;
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
  String _baseUrl = "https://warnung.bund.de/api31";
  dynamic _data;
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
      Response _response;
      _response = await getMapData(mapApis[i][1], _baseUrl);

      // 304 = with etag no change since last request
      if (_response.statusCode == 304) {
        print("Nothing change for: ${mapApis[i][1]}");
      }
      // 200 = check if request was successfully
      else if (_response.statusCode == 200) {
        // decode the _data
        _data = jsonDecode(utf8.decode(_response.bodyBytes));
        // parse the _data into List of Warnings
        mapWarningsList.addAll(
            await parseMapApiData(_data, _baseUrl, mapApis[i][0]));
      }
    } catch (e) {
      print(
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
