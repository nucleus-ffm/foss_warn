import 'dart:convert';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

// My Places
// TODO(PureTryOut): remove once everything uses cachedPlacesProvider
Future<List<Place>> loadMyPlacesList() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  if (preferences.containsKey("MyPlacesListAsJson")) {
    List<dynamic> data =
        jsonDecode(preferences.getString("MyPlacesListAsJson")!);

    List<Place> newPlaces = [];
    for (int i = 0; i < data.length; i++) {
      debugPrint(data[i].toString());
      // FPAS Place
      newPlaces.add(Place.fromJson(data[i]));
    }

    return newPlaces;
  }

  return [];
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
Future<void> saveLastBackgroundUpdateTime(String time) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString("lastBackgroundUpdateTime", time);
}
