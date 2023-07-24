import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import '../class/class_AlertSwissPlace.dart';
import '../class/class_NinaPlace.dart';
import '../class/class_WarnMessage.dart';

import 'listHandler.dart';
import '../main.dart';

//My Places
saveMyPlacesList() async {
  //List<String> myPlaceListAsString = myPlaceList.map((i) => i.name).toList();
  SharedPreferences preferences = await SharedPreferences.getInstance();
  // preferences.setStringList('myPlaceListAsString', myPlaceListAsString);
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

//Settings

saveSettings() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString(
      "notificationGeneral", userPreferences.shouldNotifyGeneral.toString());
  preferences.setString("startScreen", userPreferences.startScreen.toString());
  preferences.setString(
      "showExtendedMetaData", userPreferences.showExtendedMetaData.toString());
  preferences.setString(
      "warningFontSize", userPreferences.warningFontSize.toString());
  preferences.setString(
      "showWelcomeScreen", userPreferences.showWelcomeScreen.toString());
  preferences.setString(
      "sortWarningsBy", userPreferences.sortWarningsBy.toString());
  preferences.setString("showStatusNotification",
      userPreferences.showStatusNotification.toString());
  preferences.setString(
      "updateAvailable", userPreferences.updateAvailable.toString());
  // @todo remove if not needed anymore preferences.setString("githubVersionNumber", userPreferences.githubVersionNumber.toString());
  preferences.setString(
      "frequencyOfAPICall", userPreferences.frequencyOfAPICall.toString());
  preferences.setString(
      "selectedTheme", userPreferences.selectedTheme.toString());
  preferences.setString(
      "showAllWarnings", userPreferences.showAllWarnings.toString());
  preferences.setString("notificationEventsSettings",
      jsonEncode(userPreferences.notificationEventsSettings));
  preferences.setBool("activateAlertSwiss", userPreferences.activateAlertSwiss);
  print("Settings saved");
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
    String temp = preferences.getString("notificationGeneral")!;
    if (temp == "true") {
      userPreferences.shouldNotifyGeneral = true;
    } else {
      userPreferences.shouldNotifyGeneral = false;
    }
  } else {
    userPreferences.shouldNotifyGeneral = true;
  }
  if (preferences.containsKey("startScreen")) {
    String temp = preferences.getString("startScreen")!;
    userPreferences.startScreen = int.parse(temp);
    print("Start Screen is: ${userPreferences.startScreen}");
  }
  if (preferences.containsKey("showExtendedMetaData")) {
    String temp = preferences.getString("showExtendedMetaData")!;
    if (temp == "true") {
      userPreferences.showExtendedMetaData = true;
    } else {
      userPreferences.showExtendedMetaData = false;
    }
  } else {
    userPreferences.showExtendedMetaData = false;
  }
  if (preferences.containsKey("warningFontSize")) {
    String temp = preferences.getString("warningFontSize")!;
    userPreferences.warningFontSize = double.parse(temp);
    print("warningFontSize: ${userPreferences.warningFontSize}");
  } else {
    saveSettings();
    loadSettings();
  }
  if (preferences.containsKey("showWelcomeScreen")) {
    String temp = preferences.getString("showWelcomeScreen")!;
    if (temp == "true") {
      userPreferences.showWelcomeScreen = true;
    } else {
      userPreferences.showWelcomeScreen = false;
    }
  } else {
    userPreferences.showWelcomeScreen = true;
  }
  if (preferences.containsKey("sortWarningsBy")) {
    String temp = preferences.getString("sortWarningsBy")!;
    userPreferences.sortWarningsBy = temp;
    //print("warningFontSize: $warningFontSize");
  } else {
    saveSettings();
    loadSettings();
  }
  if (preferences.containsKey("showStatusNotification")) {
    String temp = preferences.getString("showStatusNotification")!;
    if (temp == "true") {
      userPreferences.showStatusNotification = true;
    } else {
      userPreferences.showStatusNotification = false;
    }
  } else {
    userPreferences.showStatusNotification = true;
  }
  if (preferences.containsKey("updateAvailable")) {
    String temp = preferences.getString("updateAvailable")!;
    if (temp == "true") {
      userPreferences.updateAvailable = true;
    } else {
      userPreferences.updateAvailable = false;
    }
  } else {
    userPreferences.updateAvailable = false;
  }

  /* @todo: remove if not needed anymore
   if (preferences.containsKey("githubVersionNumber")) {
    String temp = preferences.getString("githubVersionNumber")!;
    userPreferences.githubVersionNumber = temp;
    //print("warningFontSize: $warningFontSize");
  } */

  if (preferences.containsKey("frequencyOfAPICall")) {
    userPreferences.frequencyOfAPICall =
        double.parse(preferences.getString("frequencyOfAPICall")!);
    //true;
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
    String temp = preferences.getString("showAllWarnings")!;
    if (temp == "true") {
      userPreferences.showAllWarnings = true;
    } else {
      userPreferences.showAllWarnings = false;
    }
  } else {
    userPreferences.showAllWarnings = false;
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

cacheWarnings() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString("cachedWarnings", jsonEncode(warnMessageList));
  print("warnings cached");
  userPreferences.areWarningsFromCache = false;
}

loadCachedWarnings() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  if (preferences.containsKey("cachedWarnings")) {
    var data = jsonDecode(preferences.getString("cachedWarnings")!)!;
    // print(data);
    for (int i = 0; i < data.length; i++) {
      // print(data[i]);
      warnMessageList.add(WarnMessage.fromJson(data[i]));
    }
    userPreferences.areWarningsFromCache = true;
  } else {
    print("there are no saved warnings");
  }
}
