import 'package:flutter/material.dart';

class UserPreferences {
  bool notificationWithExtreme = true;
  bool notificationWithSevere = true;
  bool notificationWithModerate = true;
  bool notificationWithMinor = false;

  bool shouldNotifyGeneral = true;

  bool showStatusNotification = true;

  Map<String, bool> notificationEventsSettings = new Map();

  bool showExtendedMetaData = false; // show more tags in WarningDetailView
  ThemeMode selectedTheme = ThemeMode.system;
  double frequencyOfAPICall = 15;

  int startScreen = 0;
  double warningFontSize = 14;
  bool showWelcomeScreen = true;
  String sortWarningsBy = "severity";
  bool updateAvailable = false;
  bool showAllWarnings = false;
  bool areWarningsFromCache = false;

  String versionNumber = "0.5.1"; // shown in the about view
  // String githubVersionNumber = versionNumber; // used in the update check
  // bool gitHubRelease =  false; // if true, there the check for update Button is shown

  bool activateAlertSwiss = false;
  bool isFirstStart = true;
}