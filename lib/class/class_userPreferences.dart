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
            notificationLevel: Severity.Severe));
      } else {
        temp.add(NotificationPreferences(
            warningSource: source,
            notificationLevel: Severity.Minor));
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

  String versionNumber = "0.8.0"; // shown in the about view
  int currentVersionCode = 32;
  int previousInstalledVersionCode = -1;  // @todo load from storage update version after legacy handler

  bool activateAlertSwiss = false;
  bool isFirstStart = true;

  Duration networkTimeout = Duration(seconds: 8);

  List<ThemeData> availableLightThemes = [greenLightTheme, orangeLightTheme, purpleLightTheme, blueLightTheme, yellowLightTheme, indigoLightTheme];
  List<ThemeData> availableDarkThemes = [greenDarkTheme, orangeDarkTheme, purpleDarkTheme, yellowDarkTheme, blueDarkTheme, greyDarkTheme];

  /// the path and filename where the error log is saved
  String errorLogPath = "errorLog.txt";

  /// Dark mode colors for the map.
  /// invert(100%), hue-rotate(180deg), brightness(95%), contrast(90%)
  ColorFilter mapDarkMode = ColorFilter.matrix(<double>[
  -0.574, -1.43,  -0.144, 0, 255,
  -0.426, -0.43,  -0.144, 0, 255,
  -0.426, -1.43,  0.856,  0, 255,
  0,      0,      0,      1, 0,
  ]);

  /// Light mode for the map
  /// original colors from OSM
  ColorFilter mapLightMode =  ColorFilter.matrix(<double>[
  1,  0,  0, 0, 0,
  0,  1,  0, 0, 0,
  0,  0,  1, 0, 0,
  0,  0,  0, 1, 0,
  ]);

  // unified Push settings
  String fossPublicAlertServerUrl = "http://10.0.2.2:8000"; //"http://127.0.0.1:8000";
  String unifiedPushEndpoint = "";
  bool unifiedPushRegistered = false;
  String unifiedPushInstance = "FOSSWarn";
  List<String> fossPublicAlertSubscriptionIdsToSubscribe = [];
  String httpUserAgent = "de.nucleus.foss_warn";
  String osmTileServerULR = "https://tile.openstreetmap.org/{z}/{x}/{y}.png";
}