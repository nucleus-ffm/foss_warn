import 'package:flutter/material.dart';
import 'package:foss_warn/themes/themes.dart';

import '../enums/Severity.dart';
import '../enums/WarningSource.dart';
import 'class_notificationPreferences.dart';

/// handle user preferences. The values written here are default values
/// the correct values are loaded in loadSettings() from sharedPreferences
class UserPreferences {
  @deprecated
  bool notificationWithExtreme = true;
  @deprecated
  bool notificationWithSevere = true;
  @deprecated
  bool notificationWithModerate = true;
  @deprecated
  bool notificationWithMinor = false;

  bool shouldNotifyGeneral = true;

  bool showStatusNotification = true;

  @deprecated
  Map<String, bool> notificationEventsSettings = new Map();
  // to save the user settings for which source
  // the user would like to be notified
  List<NotificationPreferences> notificationSourceSettings = _getDefaultValueForNotificationSourceSettings();

  static List<NotificationPreferences> _getDefaultValueForNotificationSourceSettings() {
    List<NotificationPreferences> temp = [];

    for(WarningSource source in WarningSource.values) {
      if(source == WarningSource.dwd || source == WarningSource.lhp) {
        temp.add(NotificationPreferences(
            warningSource: source,
            notificationLevel: Severity.severe));
      } else {
        temp.add(NotificationPreferences(
            warningSource: source,
            notificationLevel: Severity.minor));
      }
    }

    return temp;
  }

  bool showExtendedMetaData = false; // show more tags in WarningDetailView
  ThemeMode selectedThemeMode = ThemeMode.system;
  ThemeData selectedLightTheme = greenLightTheme;
  ThemeData selectedDarkTheme = greenDarkTheme;
  double frequencyOfAPICall = 15;

  int startScreen = 0;
  double warningFontSize = 14;
  bool showWelcomeScreen = true;
  String sortWarningsBy = "severity";
  bool updateAvailable = false;
  bool showAllWarnings = false;
  bool areWarningsFromCache = false;

  String versionNumber = "0.6.2"; // shown in the about view

  bool activateAlertSwiss = false;
  bool isFirstStart = true;

  Duration networkTimeout = Duration(seconds: 8);

  List<ThemeData> availableLightThemes = [greenLightTheme, orangeLightTheme, purpleLightTheme, blueLightTheme, yellowLightTheme, indigoLightTheme];
  List<ThemeData> availableDarkThemes = [greenDarkTheme, orangeDarkTheme, purpleDarkTheme, yellowDarkTheme, blueDarkTheme, greyDarkTheme];
}