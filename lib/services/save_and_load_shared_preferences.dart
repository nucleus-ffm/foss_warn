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
  preferences.setBool(
      "showStatusNotification", userPreferences.showStatusNotification);
  preferences.setDouble(
      "frequencyOfAPICall", userPreferences.frequencyOfAPICall);
  preferences.setString(
      "selectedThemeMode", userPreferences.selectedThemeMode.toString());
  preferences.setInt(
      "selectedLightTheme",
      userPreferences.availableLightThemes
          .indexOf(userPreferences.selectedLightTheme));
  preferences.setInt(
      "selectedDarkTheme",
      userPreferences.availableDarkThemes
          .indexOf(userPreferences.selectedDarkTheme));
  preferences.setBool("showAllWarnings", userPreferences.showAllWarnings);
  preferences.setString("notificationSourceSettings",
      jsonEncode(userPreferences.notificationSourceSettings));
  preferences.setBool("activateAlertSwiss", userPreferences.activateAlertSwiss);
  preferences.setString(
      "fossPublicAlertServerUrl", userPreferences.fossPublicAlertServerUrl);
  preferences.setString(
      "unifiedPushEndpoint", userPreferences.unifiedPushEndpoint);
  preferences.setBool(
      "unifiedPushRegistered", userPreferences.unifiedPushRegistered);
  preferences.setStringList("fossPublicAlertSubscriptionIdsToSubscribe",
      userPreferences.fossPublicAlertSubscriptionIdsToSubscribe);
  preferences.setInt("previousInstalledVersionCode",
      userPreferences.previousInstalledVersionCode);
  preferences.setString("fossPublicAlertServerVersion",
      userPreferences.fossPublicAlertServerVersion);
  preferences.setString("fossPublicAlertServerOperator",
      userPreferences.fossPublicAlertServerOperator);
  preferences.setString("fossPublicAlertServerPrivacyNotice",
      userPreferences.fossPublicAlertServerPrivacyNotice);
  preferences.setString("fossPublicAlertServerTermsOfService",
      userPreferences.fossPublicAlertServerTermsOfService);
  preferences.setInt("fossPublicAlertServerCongestionState",
      userPreferences.fossPublicAlertServerCongestionState);
  preferences.setInt("maxSizeOfSubscriptionBoundingBox",
      userPreferences.maxSizeOfSubscriptionBoundingBox);
  debugPrint("Settings saved");
}

saveETags() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setString("mowasEtag", appState.mowasETag);
  preferences.setString("biwappEtag", appState.biwappETag);
  preferences.setString("katwarnEtag", appState.katwarnETag);
  preferences.setString("dwdEtag", appState.dwdETag);
  preferences.setString("lhpEtag", appState.lhpETag);
  debugPrint("etags saved");
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
    saveSettings(); //@todo remove?
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
  if (preferences.containsKey("selectedThemeMode")) {
    String temp = preferences.getString("selectedThemeMode")!;
    switch (temp) {
      case 'ThemeMode.system':
        userPreferences.selectedThemeMode = ThemeMode.system;
        break;
      case 'ThemeMode.dark':
        userPreferences.selectedThemeMode = ThemeMode.dark;
        break;
      case 'ThemeMode.light':
        userPreferences.selectedThemeMode = ThemeMode.light;
        break;
    }
  } else {
    // Default value
    userPreferences.selectedThemeMode = ThemeMode.system;
  }
  if (preferences.containsKey("selectedLightTheme")) {
    int temp = preferences.getInt("selectedLightTheme")!;
    if (temp > userPreferences.availableLightThemes.length - 1 || temp == -1) {
      userPreferences.selectedLightTheme =
          userPreferences.availableLightThemes[0];
    } else {
      userPreferences.selectedLightTheme =
          userPreferences.availableLightThemes[temp];
    }
  }
  if (preferences.containsKey("selectedDarkTheme")) {
    int temp = preferences.getInt("selectedDarkTheme")!;
    if (temp > userPreferences.availableDarkThemes.length - 1 || temp == -1) {
      userPreferences.selectedDarkTheme =
          userPreferences.availableDarkThemes[0];
    } else {
      userPreferences.selectedDarkTheme =
          userPreferences.availableDarkThemes[temp];
    }
  }

  if (preferences.containsKey("showAllWarnings")) {
    userPreferences.showAllWarnings = preferences.getBool("showAllWarnings")!;
  }
  if (preferences.containsKey("notificationSourceSettings")) {
    List<dynamic> data =
        jsonDecode(preferences.getString("notificationSourceSettings")!);
    userPreferences.notificationSourceSettings.clear();
    for (int i = 0; i < data.length; i++) {
      userPreferences.notificationSourceSettings
          .add(NotificationPreferences.fromJson(data[i]));
    }
  }
  if (preferences.containsKey("activateAlertSwiss")) {
    userPreferences.activateAlertSwiss =
        preferences.getBool("activateAlertSwiss")!;
  }

  if (preferences.containsKey("fossPublicAlertServerUrl")) {
    userPreferences.fossPublicAlertServerUrl =
        preferences.getString("fossPublicAlertServerUrl")!;
  }
  if (preferences.containsKey("unifiedPushEndpoint")) {
    userPreferences.unifiedPushEndpoint =
        preferences.getString("unifiedPushEndpoint")!;
  }
  if (preferences.containsKey("unifiedPushRegistered")) {
    userPreferences.unifiedPushRegistered =
        preferences.getBool("unifiedPushRegistered")!;
  }
  if (preferences.containsKey("fossPublicAlertSubscriptionIdsToSubscribe")) {
    userPreferences.fossPublicAlertSubscriptionIdsToSubscribe =
        preferences.getStringList("fossPublicAlertSubscriptionIdsToSubscribe")!;
  }
  if (preferences.containsKey("previousInstalledVersionCode")) {
    userPreferences.previousInstalledVersionCode =
        preferences.getInt("previousInstalledVersionCode")!;
  }
  if (preferences.containsKey("fossPublicAlertServerVersion")) {
    userPreferences.fossPublicAlertServerVersion =
        preferences.getString("fossPublicAlertServerVersion")!;
  }
  if (preferences.containsKey("fossPublicAlertServerOperator")) {
    userPreferences.fossPublicAlertServerOperator =
        preferences.getString("fossPublicAlertServerOperator")!;
  }
  if (preferences.containsKey("fossPublicAlertServerPrivacyNotice")) {
    userPreferences.fossPublicAlertServerPrivacyNotice =
        preferences.getString("fossPublicAlertServerPrivacyNotice")!;
  }
  if (preferences.containsKey("fossPublicAlertServerTermsOfService")) {
    userPreferences.fossPublicAlertServerTermsOfService =
        preferences.getString("fossPublicAlertServerTermsOfService")!;
  }
  if (preferences.containsKey("fossPublicAlertServerCongestionState")) {
    userPreferences.fossPublicAlertServerCongestionState =
        preferences.getInt("fossPublicAlertServerCongestionState")!;
  }
  if (preferences.containsKey("maxSizeOfSubscriptionBoundingBox")) {
    userPreferences.maxSizeOfSubscriptionBoundingBox =
        preferences.getInt("maxSizeOfSubscriptionBoundingBox")!;
  }
}

@Deprecated("")
saveNotificationSettingsImportanceList() async {
  debugPrint("Save saveNotificationSettingsImportanceList");
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

  debugPrint(notificationSettingsImportance.toString());
}

@Deprecated("")
loadNotificationSettingsImportanceList() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  //check if notificationSettingsImportance already exists
  if (preferences.containsKey("notificationSettingsImportance")) {
    debugPrint("notificationSettingsImportance exist - load now");
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
    if (notificationSettingsImportance.contains("Severe") ||
        notificationSettingsImportance.contains("Moderate") ||
        notificationSettingsImportance.contains("Minor")) {
      saveNotificationSettingsImportanceList();
      loadNotificationSettingsImportanceList();
    }
  } else {
    debugPrint("notificationSettingsImportance Key does not exist");
    saveNotificationSettingsImportanceList(); //save init List
    loadNotificationSettingsImportanceList(); // try again
    debugPrint("notificationSettingsImportance should yet exist");
  }
}
