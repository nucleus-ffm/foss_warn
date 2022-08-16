import 'dart:convert';
import 'package:foss_warn/services/allPlacesList.dart';

import '../class/class_Place.dart';
import '../class/class_WarnMessage.dart';
import '../class/class_Area.dart';
import '../class/class_Geocode.dart';
import 'alertSwiss.dart';
import 'listHandler.dart';
//import 'markWarningsAsRead.dart';
import '../views/SettingsView.dart';
import 'sendStatusNotification.dart';
import 'saveAndLoadSharedPreferences.dart';

import 'package:http/http.dart';

/// call the nina api and load for myPlaces the warnings
Future callAPI()  async {
  bool successfullyFetched = true;
  String error = "";
  print("call API");
  String baseUrl = "https://warnung.bund.de/api31";
  // String geocode = "071110000000"; // just for testing
  List<WarnMessage> tempWarnMessageList = [];
  tempWarnMessageList.clear();
  await loadSettings();

  for(Place p in myPlaceList) {
    // if the place is for swiss skip this place
    print(p.name);
    if(alertSwissPlacesList.contains(p.name)) {
      if(!activateAlertSwiss) {
        successfullyFetched = false;
        error += "Sie haben einen AlertSwiss Ort hinzugefügt,"
            " aber AlertSwiss nicht als Quelle aktiviert \n";
      }
      break;
    }
    try {
      Response response; //response var for get request
      var data; //var for response data
      // the warnings are only on kreisebene wo we only care about the first 5
      // letters from the code and fill the rest with 0s
      String geocode = p.geocode.substring(0, 5) + "0000000";

      await loadSettings();
      await loadEtags();

      print("call: " + baseUrl + "/dashboard/" + geocode +".json");
      // get overview if warnings exits for myplaces
      response = await get(Uri.parse(baseUrl + "/dashboard/" + geocode +".json"));

      // check if request was sucsessfully
      if (response.statusCode == 200) {
        data = jsonDecode(utf8.decode(response.bodyBytes));

        for(int i = 0; i < data.length; i++) {
          String id = data[i]["payload"]["id"];
          String provider = data[i]["payload"]["data"]["provider"];
          print("provider: " + provider);
          var responseDetails = await get(Uri.parse(baseUrl + "/warnings/" + id +".json"));
          // check if request was successfully
          if (responseDetails.statusCode == 200) {
            var warningDetails = jsonDecode(utf8.decode(responseDetails.bodyBytes));
            WarnMessage? temp = createWarning(warningDetails, provider,
                p.name, p.geocode, tempWarnMessageList);
            if(temp != null) {
              tempWarnMessageList.add(temp);
            }
          } else {
            print("[callAPI] Error: tried calling: " + baseUrl + "/warnings/" + id +".json");
          }
        }

        //@todo: is this api for all warning sources? or is it just Mowas?
        // i think it is for all (katwarn confirmed)
      } else {
        print("could not reach: ");
      }

    } catch (e) {
      print("Something went wrong: " + e.toString());
      successfullyFetched = false;
      error += e.toString() + " \n";
    }
  }
  if (showStatusNotification) {
    if(error != "") {
      sendStatusUpdateNotification(successfullyFetched, error);
    } else {
      sendStatusUpdateNotification(successfullyFetched);
    }
  }

  warnMessageList.clear(); //clear List
  warnMessageList = tempWarnMessageList; // transfer temp List in real list

  if(activateAlertSwiss) {
    await callAlertSwissAPI();
  }

  print("finished calling API");
  return "";
}

WarnMessage? createWarning(var data, String provider, String placeName, String geocode, List<WarnMessage> tempWarnMessageList) {
  /// generate empty list as placeholder
  List<Area> generateAreaList(int i) {
    List<Area> tempAreaList = [];
    tempAreaList.add(Area(areaDesc: placeName, geocodeList: [Geocode(
        geocodeName: placeName,
        geocodeNumber: geocode),]
      ),
    );
    return tempAreaList;
  }
  String findPublisher(var parameter) {
    for(int i=0; i<parameter.length; i++) {
      if(parameter[i]["valueName"] == "sender_langname") {
        return parameter[i]["value"];
      }
    }
    return "not found";
  }

  try {
    WarnMessage tempWarnMessage = WarnMessage(
      source: provider,
      identifier: data["identifier"] ?? "?",
      sender: data["sender"] ?? "?",
      sent: data["sent"] ?? "?",
      status: data["status"] ?? "?",
      messageTyp: data["msgType"] ?? "?",
      scope: data["scope"] ?? "?",
      category: data["info"][0]["category"][0] ?? "?",
      event: data["info"][0]["event"] ?? "?",
      urgency: data["info"][0]["urgency"] ?? "?",
      severity: data["info"][0]["severity"].toString().toLowerCase(),
      certainty: data["info"][0]["certainty"] ?? "?",
      effective: data["info"][0]["effective"] ?? "",
      onset: data["info"][0]["onset"] ?? "",
      expires: data["info"][0]["expires"] ?? "",
      headline: data["info"][0]["headline"] ?? "?",
      description: data["info"][0]["description"] ?? "",
      instruction: data["info"][0]["instruction"] ?? "",
      publisher: findPublisher(data["info"][0]["parameter"]),
      contact: data["info"][0]["contact"] ?? "",
      web: data["info"][0]["web"] ?? "",
      areaList: generateAreaList(1),
    );
    return tempWarnMessage;
  } catch (e) {
    print("something went wrong while parsing warning: " +
        data["identifier"] + " -> " + e.toString());
  }
  return null;
}

