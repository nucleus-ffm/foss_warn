import 'dart:convert';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:foss_warn/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';

// My Places
Future<void> saveMyPlacesList(List<Place> places) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString("MyPlacesListAsJson", jsonEncode(places));
}

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

// Settings
Future<void> saveSettings() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setBool(
    "notificationGeneral",
    userPreferences.shouldNotifyGeneral,
  );
  preferences.setInt("startScreen", userPreferences.startScreen);
  preferences.setBool(
    "showExtendedMetaData",
    userPreferences.showExtendedMetaData,
  );
  preferences.setDouble("warningFontSize", userPreferences.warningFontSize);
  preferences.setBool("showWelcomeScreen", userPreferences.showWelcomeScreen);
  preferences.setString(
    "sortWarningsBy",
    userPreferences.sortWarningsBy.toString(),
  );
  preferences.setBool(
    "showStatusNotification",
    userPreferences.showStatusNotification,
  );
  preferences.setInt("frequencyOfAPICall", userPreferences.frequencyOfAPICall);
  preferences.setString(
    "selectedThemeMode",
    userPreferences.selectedThemeMode.toString(),
  );
  preferences.setInt(
    "selectedLightTheme",
    userPreferences.availableLightThemes
        .indexOf(userPreferences.selectedLightTheme),
  );
  preferences.setInt(
    "selectedDarkTheme",
    userPreferences.availableDarkThemes
        .indexOf(userPreferences.selectedDarkTheme),
  );
  preferences.setBool("showAllWarnings", userPreferences.showAllWarnings);
  preferences.setString(
    "notificationSourceSettings",
    jsonEncode(userPreferences.notificationSourceSetting),
  );
  preferences.setString(
    "fossPublicAlertServerUrl",
    userPreferences.fossPublicAlertServerUrl,
  );
  preferences.setString(
    "unifiedPushEndpoint",
    userPreferences.unifiedPushEndpoint,
  );
  preferences.setBool(
    "unifiedPushRegistered",
    userPreferences.unifiedPushRegistered,
  );
  preferences.setStringList(
    "fossPublicAlertSubscriptionIdsToSubscribe",
    userPreferences.fossPublicAlertSubscriptionIdsToSubscribe,
  );
  preferences.setInt(
    "previousInstalledVersionCode",
    userPreferences.previousInstalledVersionCode,
  );
  preferences.setString(
    "fossPublicAlertServerOperator",
    userPreferences.fossPublicAlertServerOperator,
  );
  preferences.setString(
    "fossPublicAlertServerPrivacyNotice",
    userPreferences.fossPublicAlertServerPrivacyNotice,
  );
  preferences.setString(
    "fossPublicAlertServerTermsOfService",
    userPreferences.fossPublicAlertServerTermsOfService,
  );
  preferences.setInt(
    "maxSizeOfSubscriptionBoundingBox",
    userPreferences.maxSizeOfSubscriptionBoundingBox,
  );
  debugPrint("Settings saved");
}
