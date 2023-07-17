import 'dart:convert';
import '../class/class_AlertSwissPlace.dart';
import '../class/class_NinaPlace.dart';
import '../class/class_WarnMessage.dart';
import '../class/class_Area.dart';
import '../class/class_Geocode.dart';
import '../class/abstract_Place.dart';
import 'alertSwiss.dart';
import 'listHandler.dart';
import '../views/SettingsView.dart';
import 'sendStatusNotification.dart';
import 'saveAndLoadSharedPreferences.dart';

import 'package:http/http.dart';

/// call the nina api and load for myPlaces the warnings
Future callAPI() async {
  bool _successfullyFetched = true;
  String _error = "";
  List<WarnMessage> _tempWarnMessageList = [];
  _tempWarnMessageList.clear();
  print("call API");
  String _baseUrl = "https://warnung.bund.de/api31";
  // String geocode = "071110000000"; // just for testing

  await loadSettings();
  await loadMyPlacesList();

  for (Place p in myPlaceList) {
    // if the place is for swiss skip this place
    print(p.getName());
    if (p is AlertSwissPlace) {
      if (!activateAlertSwiss) {
        _successfullyFetched = false;
        _error += "Sie haben einen AlertSwiss Ort hinzugefügt,"
            " aber AlertSwiss nicht als Quelle aktiviert \n";
      }
      continue;
    }
    // it is a nina place
    else if (p is NinaPlace) {
      try {
        Response response; //response var for get request
        var data; //var for response data
        // the warnings are only on kreisebene wo we only care about the first 5
        // letters from the code and fill the rest with 0s
        print(p.getGeocode().getGeocodeNumber());
        String geocode = p.getGeocode().getGeocodeNumber().substring(0, 5) + "0000000";

        await loadSettings();
        await loadETags();

        print("call: " + _baseUrl + "/dashboard/" + geocode + ".json");
        // get overview if warnings exits for myplaces
        response =
            await get(Uri.parse(_baseUrl + "/dashboard/" + geocode + ".json"));

        // check if request was successfully
        if (response.statusCode == 200) {
          data = jsonDecode(utf8.decode(response.bodyBytes));
          _tempWarnMessageList.clear();

          for (int i = 0; i < data.length; i++) {
            String id = data[i]["payload"]["id"];
            String provider = data[i]["payload"]["data"]["provider"];
            print("provider: " + provider);
            var responseDetails =
                await get(Uri.parse(_baseUrl + "/warnings/" + id + ".json"));
            // check if request was successfully
            if (responseDetails.statusCode == 200) {
              var warningDetails =
                  jsonDecode(utf8.decode(responseDetails.bodyBytes));
              WarnMessage? temp =
                  createWarning(warningDetails, provider, p.getName(), p.getGeocode());
              if (temp != null) {
                _tempWarnMessageList.add(temp);
                if (!p.getWarnings()
                    .any((element) => element.identifier == temp.identifier)) {
                  print("add warning to p: " +
                      temp.headline +
                      " " +
                      temp.notified.toString());
                  p.addWarningToList(temp);
                  p.incrementNumberOfWarnings();
                }

                // }  //@todo: fix displaying warnings twice
              }
            } else {
              print("[callAPI] Error: tried calling: " +
                  _baseUrl +
                  "/warnings/" +
                  id +
                  ".json");
            }
          }
          // remove old warnings
          List<WarnMessage> warnMessagesToRemove = [];
          for (WarnMessage msg in p.getWarnings()) {
            if (!_tempWarnMessageList
                .any((tmp) => tmp.identifier == msg.identifier)) {
              warnMessagesToRemove.add(msg);
            }
          }
          for (WarnMessage message in warnMessagesToRemove) {
            p.removeWarningFromList(message);
            p.decrementNumberOfWarnings();
          }

          areWarningsFromCache = false;
          print("Saving myPlacesList with new warnings");
          saveMyPlacesList();
        } else {
          print("could not reach: ");
          _successfullyFetched = false;
          _error += "Failed to get warnings for:  ${p.getName()}"
              " (Statuscode:  ${response.statusCode} ) \n";
        }
      } catch (e) {
        print("Something went wrong while trying to call the NINA API:  $e");
        _successfullyFetched = false;
        areWarningsFromCache = true;
        _error += e.toString() + " \n";
      }
    }
  }
  if (showStatusNotification) {
    if (_error != "") {
      sendStatusUpdateNotification(_successfullyFetched, _error);
    } else {
      sendStatusUpdateNotification(_successfullyFetched);
    }
  }

  // warnMessageList.clear(); //clear List
  // warnMessageList = tempWarnMessageList; // transfer temp List in real list

  // call alert Swiss
  if (activateAlertSwiss) {
    await callAlertSwissAPI();
  }

  //@todo fix
  /* if (warnMessageList.isNotEmpty) {
    cacheWarnings();
  } else if (!successfullyFetched) {
    loadCachedWarnings();
  } else {
    // there are no warnings and no stored
    // warning, so we we have nothing to display
    areWarningsFromCache = false;
  } */

  print("finished calling API");
  return "";
}

/// generate WarnMessage object
WarnMessage? createWarning(
    var data, String provider, String placeName, Geocode geocode) {
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
