import 'dart:convert';
import 'package:foss_warn/main.dart';

import '../class/class_AlertSwissPlace.dart';
import '../class/class_NinaPlace.dart';
import '../class/class_WarnMessage.dart';
import '../class/class_Area.dart';
import '../class/class_Geocode.dart';
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
    // it is a nina place
    else if (place is NinaPlace) {
      try {
        Response _response;
        _response =
            await getDashboard(place, _baseUrl).timeout(userPreferences.networkTimeout);

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

/// generate WarnMessage object
WarnMessage? createWarning(
    dynamic data, String provider, String placeName, Geocode geocode) {
  /// generate empty list as placeholder
  /// @todo fill with real data
  List<Area> generateAreaList(int i) {
    List<Area> tempAreaList = [];
    tempAreaList.add(
      Area(areaDesc: placeName, geocodeList: [
        geocode,
      ]),
    );
    return tempAreaList;
  }

  String findPublisher(var parameter) {
    for (int i = 0; i < parameter.length; i++) {
      if (parameter[i]["valueName"] == "sender_langname") {
        return parameter[i]["value"];
      }
    }
    return "Deutscher Wetterdienst";
  }

  try {
    return WarnMessage.fromJsonTemp(data, provider,
        findPublisher(data["info"][0]["parameter"]), generateAreaList(1));
  } catch (e) {
    print("Error parsing warning: ${data["identifier"]} -> ${e.toString()}");
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

/// crate from the given data a new List<WarnMessage and return the list
Future<List<WarnMessage>> parseNinaJsonData(
    dynamic data, String baseUrl, NinaPlace place) async {
  List<WarnMessage> _tempWarnMessageList = [];
  for (int i = 0; i < data.length; i++) {
    String id = data[i]["payload"]["id"];
    String provider = data[i]["payload"]["data"]["provider"];
    print("provider: " + provider);
    Response responseDetails =
        await get(Uri.parse(baseUrl + "/warnings/" + id + ".json"));
    // check if request was successfully
    if (responseDetails.statusCode == 200) {
      var warningDetails = jsonDecode(utf8.decode(responseDetails.bodyBytes));
      WarnMessage? temp =
          createWarning(warningDetails, provider, place.name, place.geocode);
      if (temp != null) {
        _tempWarnMessageList.add(temp);
        if (!place.warnings
            .any((element) => element.identifier == temp.identifier)) {
          print("add warning to p: " +
              temp.headline +
              " " +
              temp.notified.toString());
          place.addWarningToList(temp);
        }

        // }  //@todo: fix displaying warnings twice
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
    if (!tempWarnMessageList.any((tmp) => tmp.identifier == msg.identifier)) {
      warnMessagesToRemove.add(msg);
    }
  }
  for (WarnMessage message in warnMessagesToRemove) {
    place.removeWarningFromList(message);
  }
}
