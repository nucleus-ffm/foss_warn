import 'dart:convert';

import 'package:foss_warn/main.dart';

import '../class/class_AlertSwissPlace.dart';
import '../class/abstract_Place.dart';
import '../class/class_ErrorLogger.dart';
import '../class/class_WarnMessage.dart';
import '../class/class_Area.dart';
import 'listHandler.dart';
import 'saveAndLoadSharedPreferences.dart';

import 'package:http/http.dart';

Future callAlertSwissAPI() async {
  String url =
      "https://www.alert.swiss/content/alertswiss-internet/en/home/_jcr_content/polyalert.alertswiss_alerts.actual.json";

  try {
    Response response; // response var for get request
    var data; // var for response data

    List<WarnMessage> tempWarnMessageList = [];
    tempWarnMessageList.clear();

    await loadSettings();
    await loadETags();

    // get overview if warnings exits for myplaces
    response =
        await get(Uri.parse(url)).timeout(userPreferences.networkTimeout);

    // check if request was sucsessfully
    if (response.statusCode == 200) {
      print("alert swiss status code 200");
      data = jsonDecode(utf8.decode(response.bodyBytes));
      var alerts = data["alerts"];

      for (int i = 0; i < alerts.length; i++) {
        WarnMessage? temp = createWarning(alerts[i]);
        if (temp != null) {
          tempWarnMessageList.add(temp);
        }
      }

      // store warnings in places //@todo testing
      for (Place p in myPlaceList) {
        if (!(p is AlertSwissPlace)) continue;

        for (WarnMessage msg in tempWarnMessageList) {
          for (Area a in msg.info[0].area) {
              if (a.region != null && a.region == p.shortName) {
                if (!p.warnings.any((w) => w.identifier == msg.identifier)) {
                  p.addWarningToList(msg);
                }
              }
          }
        }
      }
    }
  } catch (e) {
    print("Something went wrong: " + e.toString());
    // write to logfile
    ErrorLogger.writeErrorLog(
        "alertSwiss.dart", "Error while calling alertSwiss API}", e.toString()
    );
    appState.error = true;
  }
}

WarnMessage? createWarning(var data) {
  print("add warning");

  /// generate the instruction
  String generateInstruction(var instructions) {
    String result = "";
    for (int i = 0; i < instructions.length; i++) {
      result += instructions[i]["text"] + "\n \n";
    }
    return result;
  }

  /// generate area List
  List<Area> generateAreaList(var data) {
    List<Area> tempAreaList = [];
    for (int i = 0; i < data.length; i++) {
      tempAreaList.add(
        Area.withRegion(
          areaDesc: data[i]["description"]["description"],
          region: data[i]["regions"][0]["region"],
          geoJson: "{}" //[GeoJsonFeature(type: "alertSwissPolygon", coordinates: [], properties: {} )],  //@todo parse data[i]["areas"][0]["polygons"][0]["coordinates"]
        ),
      );
    }
    return tempAreaList;
  }

  try {
    // don't display tech test alerts
    if (data["technicalTestAlert"] == "true") {
      return null;
    }
    return WarnMessage.fromJsonAlertSwiss(
      data,
      generateAreaList(data["areas"]),
      generateInstruction(data["instruction"] ?? []),
      "${data["publisherName"] ?? ""} \nQuelle: www.alertswiss.ch (CC BY-NC-SA 2.5 CH)",
    );
  } catch (e) {
    print(
        "something went wrong while paring alert swiss data: " + e.toString());
    // write to logfile
    ErrorLogger.writeErrorLog("alertSwiss.dart",
        "something went wrong while paring alert swiss data", e.toString());
  }

  return null;
}
