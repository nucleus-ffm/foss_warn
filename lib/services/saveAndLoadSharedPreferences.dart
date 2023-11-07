import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import '../class/class_AlertSwissPlace.dart';
import '../class/class_NinaPlace.dart';

import 'listHandler.dart';
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
      print(data[i].toString());
      if (data[i].toString().contains("geocode")) {
        // print("Nina Place");
        myPlaceList.add(NinaPlace.fromJson(data[i]));
      } else if (data[i].toString().contains("shortName")) {
        //@todo think about better solution
        // print("alert swiss place");
        myPlaceList.add(AlertSwissPlace.fromJson(data[i]));
      }
    }
    print(myPlaceList);
  }
}

saveGeocodes(String jsonFile) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  print("save geocodes");
  preferences.setString("geocodes", jsonFile);
}

Future<dynamic> loadGeocode() async {
  print("load geocodes from storage");
  SharedPreferences preferences = await SharedPreferences.getInstance();
  // preferences.remove("geocodes");
  if (preferences.containsKey("geocodes")) {
    print("we have some geocodes");
    var result = preferences.getString("geocodes")!;
    return jsonDecode(result);
  } else {
    print("geocodes are not saved");
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

// Settings
saveSettings() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setBool(
      "notificationGeneral", userPreferences.shouldNotifyGeneral);
  preferences.setInt("startScreen", userPreferences.startScreen);
  preferences.setBool(
      "showExtendedMetaData", userPreferences.showExtendedMetaData);
  preferences.setDouble("warningFontSize", userPreferences.warningFontSize);
  preferences.setBool("showWelcomeScreen", userPreferences.showWelcomeScreen);
  preferences.setString(
      "sortWarningsBy", userPreferences.sortWarningsBy.toString());
  preferences.setBool("showStatusNotification", userPreferences.showStatusNotification);
  preferences.setDouble(
      "frequencyOfAPICall", userPreferences.frequencyOfAPICall);
  preferences.setString(
      "selectedTheme", userPreferences.selectedTheme.toString());
  preferences.setBool("showAllWarnings", userPreferences.showAllWarnings);
  preferences.setString("notificationEventsSettings",
      jsonEncode(userPreferences.notificationEventsSettings));
  preferences.setBool("activateAlertSwiss", userPreferences.activateAlertSwiss);
  preferences.setBool(
      "warningsForCurrentLocation", userPreferences.warningsForCurrentLocation);
  print("Settings saved");
  preferences.setString("currentPlace", jsonEncode(userPreferences.currentPlace));
}

saveETags() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString("mowasEtag", appState.mowasETag);
  preferences.setString("biwappEtag", appState.biwappETag);
  preferences.setString("katwarnEtag", appState.katwarnETag);
  preferences.setString("dwdEtag", appState.dwdETag);
  preferences.setString("lhpEtag", appState.lhpETag);
  print("etags saved");
}

loadETags() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.containsKey("mowasEtag")) {
    String temp = preferences.getString("mowasEtag")!;
    appState.mowasETag = temp;
  }
  if (preferences.containsKey("biwappEtag")) {
    String temp = preferences.getString("biwappEtag")!;
    appState.biwappETag = temp;
  }
  if (preferences.containsKey("katwarnEtag")) {
    String temp = preferences.getString("katwarnEtag")!;
    appState.katwarnETag = temp;
  }
  if (preferences.containsKey("dwdEtag")) {
    String temp = preferences.getString("dwdEtag")!;
    appState.dwdETag = temp;
  }
  if (preferences.containsKey("lhpEtag")) {
    String temp = preferences.getString("lhpEtag")!;
    appState.lhpETag = temp;
  }
}

loadSettings() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  if (preferences.containsKey("notificationGeneral")) {
    userPreferences.shouldNotifyGeneral =
        preferences.getBool("notificationGeneral")!;
  }
  if (preferences.containsKey("startScreen")) {
    userPreferences.startScreen = preferences.getInt("startScreen")!;
  }
  if (preferences.containsKey("showExtendedMetaData")) {
    userPreferences.showExtendedMetaData =
        preferences.getBool("showExtendedMetaData")!;
  } else {
    userPreferences.showExtendedMetaData = false;
  }
  if (preferences.containsKey("warningFontSize")) {
    userPreferences.warningFontSize = preferences.getDouble("warningFontSize")!;
  } else {
    saveSettings();
    loadSettings();
  }
  if (preferences.containsKey("showWelcomeScreen")) {
    userPreferences.showWelcomeScreen =
        preferences.getBool("showWelcomeScreen")!;
  }
  if (preferences.containsKey("sortWarningsBy")) {
    String temp = preferences.getString("sortWarningsBy")!;
    userPreferences.sortWarningsBy = temp;
  }
  if (preferences.containsKey("showStatusNotification")) {
    userPreferences.showStatusNotification =
        preferences.getBool("showStatusNotification")!;
  }
  if (preferences.containsKey("updateAvailable")) {
    userPreferences.updateAvailable = preferences.getBool("updateAvailable")!;
  }

  if (preferences.containsKey("frequencyOfAPICall")) {
    userPreferences.frequencyOfAPICall =
        preferences.getDouble("frequencyOfAPICall")!;
  }
  if (preferences.containsKey("selectedTheme")) {
    String temp = preferences.getString("selectedTheme")!;
    switch (temp) {
      case 'ThemeMode.system':
        userPreferences.selectedTheme = ThemeMode.system;
        break;
      case 'ThemeMode.dark':
        userPreferences.selectedTheme = ThemeMode.dark;
        break;
      case 'ThemeMode.light':
        userPreferences.selectedTheme = ThemeMode.light;
        break;
    }
  } else {
    // Default value
    userPreferences.selectedTheme = ThemeMode.system;
  }
  if (preferences.containsKey("showAllWarnings")) {
    userPreferences.showAllWarnings = preferences.getBool("showAllWarnings")!;
  }
  if (preferences.containsKey("notificationEventsSettings")) {
    String temp = preferences.getString("notificationEventsSettings")!;
    userPreferences.notificationEventsSettings =
        Map<String, bool>.from(jsonDecode(temp));
  }
  if (preferences.containsKey("activateAlertSwiss")) {
    userPreferences.activateAlertSwiss =
        preferences.getBool("activateAlertSwiss")!;
  }
  if (preferences.containsKey("warningsForCurrentLocation")) {
    userPreferences.warningsForCurrentLocation =
        preferences.getBool("warningsForCurrentLocation")!;
  }
  if (preferences.containsKey("currentPlace")) {
    String? temp = preferences.getString("currentPlace");
    if(temp != "null") {
      userPreferences.currentPlace =
          NinaPlace.fromJson(jsonDecode(temp!));
    } else {
      userPreferences.currentPlace = null;
    }
  }
}

saveNotificationSettingsImportanceList() async {
  print("Save saveNotificationSettingsImportanceList");
  notificationSettingsImportance.clear();
  if (userPreferences.notificationWithExtreme) {
    notificationSettingsImportance.add("extreme");
  }
  if (userPreferences.notificationWithSevere) {
    notificationSettingsImportance.add("severe");
  }
  if (userPreferences.notificationWithModerate) {
    notificationSettingsImportance.add("moderate");
  }
  if (userPreferences.notificationWithMinor) {
    notificationSettingsImportance.add("minor");
  }
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setStringList(
      'notificationSettingsImportance', notificationSettingsImportance);

  print(notificationSettingsImportance);
}

loadNotificationSettingsImportanceList() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  //check if notificationSettingsImportance already exists
  if (preferences.containsKey("notificationSettingsImportance")) {
    print("notificationSettingsImportance exist - load now");
    notificationSettingsImportance.clear();
    notificationSettingsImportance =
        preferences.getStringList('notificationSettingsImportance')!;
    userPreferences.notificationWithSevere = false;
    userPreferences.notificationWithModerate = false;
    userPreferences.notificationWithMinor = false;
    for (String i in notificationSettingsImportance) {
      switch (i.toLowerCase()) {
        case "severe":
          userPreferences.notificationWithSevere = true;
          continue;
        case "moderate":
          userPreferences.notificationWithModerate = true;
          continue;
        case "minor":
          userPreferences.notificationWithMinor = true;
          continue;
      }
    }
    // fix legacy
    if (notificationSettingsImportance
        .contains(["Severe", "Moderate", "Minor"])) {
      saveNotificationSettingsImportanceList();
      loadNotificationSettingsImportanceList();
    }
  } else {
    print("notificationSettingsImportance Key does not exist");
    saveNotificationSettingsImportanceList(); //save init List
    loadNotificationSettingsImportanceList(); // try again
    print("notificationSettingsImportance should yet exist");
  }
}
