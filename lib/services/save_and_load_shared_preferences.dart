import 'dart:convert';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/class/class_notification_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import '../class/class_alert_swiss_place.dart';
import '../class/class_nina_place.dart';

import 'list_handler.dart';
import '../main.dart';

// My Places
saveMyPlacesList() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString("MyPlacesListAsJson", jsonEncode(myPlaceList));
}

loadMyPlacesList() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  if (preferences.containsKey("MyPlacesListAsJson")) {
    List<dynamic> data =
        jsonDecode(preferences.getString("MyPlacesListAsJson")!);
    myPlaceList.clear();
    for (int i = 0; i < data.length; i++) {
      debugPrint(data[i].toString());
      if (data[i].toString().contains("geocode")) {
        // print("Nina Place");
        myPlaceList.add(NinaPlace.fromJson(data[i]));
      } else if (data[i].toString().contains("shortName")) {
        //@todo think about better solution
        // print("alert swiss place");
        myPlaceList.add(AlertSwissPlace.fromJson(data[i]));
      } else if (data[i].toString().contains("subscriptionId")) {
        // FPAS Place
        myPlaceList.add(FPASPlace.fromJson(data[i]));
      }
    }
    debugPrint(myPlaceList.toString());
  }
}

saveGeocodes(String jsonFile) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  debugPrint("save geocodes");
  preferences.setString("geocodes", jsonFile);
}

Future<dynamic> loadGeocode() async {
  debugPrint("load geocodes from storage");
  SharedPreferences preferences = await SharedPreferences.getInstance();
  // preferences.remove("geocodes");
  if (preferences.containsKey("geocodes")) {
    debugPrint("we have some geocodes");
    var result = preferences.getString("geocodes")!;
    return jsonDecode(result);
  } else {
    debugPrint("geocodes are not saved");
    return null;
  }
}

/// load the time when the API could be called successfully the last time.
/// used in the status notification
Future<String> loadLastBackgroundUpdateTime() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.containsKey("lastBackgroundUpdateTime")) {
    return preferences.getString("lastBackgroundUpdateTime")!;
  }
  return "";
}

/// saved the time when the API could be called successfully the last time.
/// used in the status notification
void saveLastBackgroundUpdateTime(String time) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString("lastBackgroundUpdateTime", time);
}
