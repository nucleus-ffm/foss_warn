import 'package:flutter/foundation.dart' as foundation;

import 'package:flutter/material.dart';
import 'package:foss_warn/enums/sorting_categories.dart';
import 'package:foss_warn/themes/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../enums/severity.dart';
import 'class_notification_preferences.dart';

/// handle user preferences. The values written here are default values
/// the correct values are loaded in loadSettings() from sharedPreferences
class UserPreferences {
  late final SharedPreferencesWithCache _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
  }

  final bool _shouldNotifyGeneral = true;
  bool get shouldNotifyGeneral {
    bool? data = _preferences.getBool("shouldNotifyGeneral");
    if (data == null) {
      return _shouldNotifyGeneral;
    } else {
      return data;
    }
  }

  set shouldNotifyGeneral(bool newValue) {
    _preferences.setBool("shouldNotifyGeneral", newValue);
  }

  final bool _showStatusNotification = false;
  bool get showStatusNotification {
    bool? data = _preferences.getBool("showStatusNotification");
    if (data == null) {
      return _showStatusNotification;
    } else {
      return data;
    }
  }

  set showStatusNotification(bool newValue) {
    _preferences.setBool("showStatusNotification", newValue);
  }

  // to save the user settings for which source
  // the user would like to be notified
  NotificationPreferences notificationSourceSetting =
      NotificationPreferences(notificationLevel: Severity.moderate);

  // if true show more tags in WarningDetailView
  final bool _showExtendedMetaData = false;
  bool get showExtendedMetaData {
    bool? data = _preferences.getBool("showExtendedMetaData");
    if (data == null) {
      return _showExtendedMetaData;
    } else {
      return data;
    }
  }

  set showExtendedMetaData(bool newValue) {
    _preferences.setBool("showExtendedMetaData", newValue);
  }

  final ThemeMode _selectedThemeMode = ThemeMode.system;

  ThemeMode get selectedThemeMode {
    String? data = _preferences.getString("selectedThemeMode");

    if (data == null) {
      return _selectedThemeMode;
    } else {
      switch (data) {
        case 'ThemeMode.system':
          return selectedThemeMode = ThemeMode.system;
        case 'ThemeMode.dark':
          return ThemeMode.dark;
        case 'ThemeMode.light':
          return ThemeMode.light;
        default:
          return ThemeMode.system;
      }
    }
  }

  set selectedThemeMode(ThemeMode value) {
    debugPrint("set new theme mode ${value.name}");
    _preferences.setString("selectedThemeMode", value.toString());
  }

  final ThemeData _selectedLightTheme = greenLightTheme;
  ThemeData get selectedLightTheme {
    int? data = _preferences.getInt("selectedLightTheme");
    if (data != null && data > -1 && data < availableLightThemes.length) {
      return availableLightThemes[data];
    } else {
      return _selectedLightTheme;
    }
  }

  set selectedLightTheme(ThemeData newTheme) {
    _preferences.setInt(
        "selectedLightTheme", availableLightThemes.indexOf(newTheme));
  }

  final ThemeData _selectedDarkTheme = greenDarkTheme;
  ThemeData get selectedDarkTheme {
    int? data = _preferences.getInt("selectedDarkTheme");
    if (data != null && data > -1 && data < availableDarkThemes.length) {
      return availableDarkThemes[data];
    } else {
      return _selectedDarkTheme;
    }
  }

  set selectedDarkTheme(ThemeData newTheme) {
    _preferences.setInt(
        "selectedDarkTheme", availableDarkThemes.indexOf(newTheme));
  }

  final int _startScreen = 0;
  int get startScreen {
    int? data = _preferences.getInt("startScreen");
    return data ?? _startScreen;
  }

  set startScreen(int newValue) {
    _preferences.setInt("startScreen", newValue);
  }

  final double _warningFontSize = 14;
  double get warningFontSize {
    double? data = _preferences.getDouble("warningFontSize");
    return data ?? _warningFontSize;
  }

  set warningFontSize(double value) {
    _preferences.setDouble("warningFontSize", value);
  }

  final bool _showWelcomeScreen = true;
  bool get showWelcomeScreen {
    bool? data = _preferences.getBool("showWelcomeScreen");
    return data ?? _showWelcomeScreen;
  }

  set showWelcomeScreen(bool value) {
    _preferences.setBool("showWelcomeScreen", value);
  }

  final SortingCategories _sortWarningsBy = SortingCategories.severity;
  SortingCategories get sortWarningsBy {
    int? data = _preferences.getInt("sortWarningBy");
    if (data != null) {
      return SortingCategories.values.elementAt(data);
    } else {
      return _sortWarningsBy;
    }
  }

  set sortWarningsBy(SortingCategories newValue) {
    _preferences.setInt("sortWarningBy", newValue.index);
  }

  final bool _showAllWarnings = false;
  bool get showAllWarnings {
    bool? data = _preferences.getBool("showAllWarnings");
    return data ?? _showAllWarnings;
  }

  set showAllWarnings(bool newValue) {
    _preferences.setBool("showAllWarnings", newValue);
  }

  final String _versionNumber = "0.8.0"; // shown in the about view
  String get versionNumber {
    return _versionNumber;
  }

  final int _currentVersionCode = 32;
  int get currentVersionCode {
    return _currentVersionCode;
  }

  final int _previousInstalledVersionCode = -1;
  int get previousInstalledVersionCode {
    int? data = _preferences.getInt("previousInstalledVersionCode");
    return data ?? _previousInstalledVersionCode;
  }

  set previousInstalledVersionCode(int newValue) {
    _preferences.setInt("previousInstalledVersionCode", newValue);
  }

  final bool _isFirstStart = true;
  bool get isFirstStart {
    bool? data = _preferences.getBool("isFirstStart");
    return data ?? _isFirstStart;
  }

  set isFirstStart(bool newValue) {
    _preferences.setBool("isFirstStart", newValue);
  }

  final Duration networkTimeout = Duration(seconds: 8);

  final List<ThemeData> availableLightThemes = [
    greenLightTheme,
    orangeLightTheme,
    purpleLightTheme,
    blueLightTheme,
    yellowLightTheme,
    indigoLightTheme
  ];
  final List<ThemeData> availableDarkThemes = [
    greenDarkTheme,
    orangeDarkTheme,
    purpleDarkTheme,
    yellowDarkTheme,
    blueDarkTheme,
    greyDarkTheme
  ];

  /// the path and filename where the error log is saved
  final String errorLogPath = "errorLog.txt";

  /// Dark mode colors for the map.
  /// invert(100%), hue-rotate(180deg), brightness(95%), contrast(90%)
  final ColorFilter mapDarkMode = ColorFilter.matrix(<double>[
    -0.574,
    -1.43,
    -0.144,
    0,
    255,
    -0.426,
    -0.43,
    -0.144,
    0,
    255,
    -0.426,
    -1.43,
    0.856,
    0,
    255,
    0,
    0,
    0,
    1,
    0,
  ]);

  /// Light mode for the map
  /// original colors from OSM
  final ColorFilter mapLightMode = ColorFilter.matrix(<double>[
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);

  final frequencyOfAPICall = 15;
  final bool _areWarningsFromCache = false;
  bool get areWarningsFromCache {
    bool? data = _preferences.getBool("areWarningsFromCache");
    return data ?? _areWarningsFromCache;
  }

  set areWarningsFromCache(bool value) {
    _preferences.setBool("areWarningsFromCache", value);
  }

  // unified Push settings
  // the server url can be overwritten by the user
  final String _fossPublicAlertServerUrl = "https://alerts.kde.org";
  String get fossPublicAlertServerUrl {
    String? data = _preferences.getString("fossPublicAlertServerUrl");
    if (foundation.kReleaseMode) {
      return data ?? _fossPublicAlertServerUrl;
    } else {
      // in DEBUG mode set to local server but also
      // allow to change the default server
      return data ?? "http://10.0.2.2:8000";
    }
  }

  set fossPublicAlertServerUrl(String newValue) {
    _preferences.setString("fossPublicAlertServerUrl", newValue);
  }

  final String _fossPublicAlertServerVersion = "";
  String get fossPublicAlertServerVersion {
    String? data = _preferences.getString("fossPublicAlertServerVersion");
    return data ?? _fossPublicAlertServerVersion;
  }

  set fossPublicAlertServerVersion(String value) {
    _preferences.setString(fossPublicAlertServerVersion, value);
  }

  final String _fossPublicAlertServerOperator = "";
  String get fossPublicAlertServerOperator {
    String? data = _preferences.getString("fossPublicAlertServerOperator");
    return data ?? _fossPublicAlertServerOperator;
  }

  set fossPublicAlertServerOperator(String value) {
    _preferences.setString("fossPublicAlertServerOperator", value);
  }

  final String _fossPublicAlertServerPrivacyNotice = "";
  String get fossPublicAlertServerPrivacyNotice {
    String? data = _preferences.getString("fossPublicAlertServerPrivacyNotice");
    return data ?? _fossPublicAlertServerPrivacyNotice;
  }

  set fossPublicAlertServerPrivacyNotice(String value) {
    _preferences.setString("fossPublicAlertServerPrivacyNotice", value);
  }

  final String _fossPublicAlertServerTermsOfService = "";
  String get fossPublicAlertServerTermsOfService {
    String? data =
        _preferences.getString("_fossPublicAlertServerTermsOfService");
    return data ?? _fossPublicAlertServerTermsOfService;
  }

  set fossPublicAlertServerTermsOfService(String value) {
    _preferences.setString("fossPublicAlertServerTermsOfService", value);
  }

  final int _fossPublicAlertServerCongestionState = -1;
  int get fossPublicAlertServerCongestionState {
    int? data = _preferences.getInt("fossPublicAlertServerCongestionState");
    return data ?? _fossPublicAlertServerCongestionState;
  }

  set fossPublicAlertServerCongestionState(int value) {
    _preferences.setInt("fossPublicAlertServerCongestionState", value);
  }

  final String _unifiedPushEndpoint = "";
  String get unifiedPushEndpoint {
    String? data = _preferences.getString("unifiedPushEndpoint");
    return data ?? _unifiedPushEndpoint;
  }

  set unifiedPushEndpoint(String value) {
    _preferences.setString("unifiedPushEndpoint", value);
  }

  final bool _unifiedPushRegistered = false;
  bool get unifiedPushRegistered {
    bool? data = _preferences.getBool("unifiedPushRegistered");
    return data ?? _unifiedPushRegistered;
  }

  set unifiedPushRegistered(bool value) {
    _preferences.setBool("unifiedPushRegistered", value);
  }

  final List<String> _fossPublicAlertSubscriptionIdsToSubscribe = [];
  List<String> get fossPublicAlertSubscriptionIdsToSubscribe {
    List<String>? data =
        _preferences.getStringList("fossPublicAlertSubscriptionIdsToSubscribe");
    return data ?? _fossPublicAlertSubscriptionIdsToSubscribe;
  }

  set fossPublicAlertSubscriptionIdsToSubscribe(List<String> value) {
    _preferences.setStringList(
        "fossPublicAlertSubscriptionIdsToSubscribe", value);
  }

  final int _maxSizeOfSubscriptionBoundingBox = 20;
  int get maxSizeOfSubscriptionBoundingBox {
    int? data = _preferences.getInt("maxSizeOfSubscriptionBoundingBox");
    return data ?? _maxSizeOfSubscriptionBoundingBox;
  }

  set maxSizeOfSubscriptionBoundingBox(int value) {
    _preferences.setInt("maxSizeOfSubscriptionBoundingBox", value);
  }

  final String unifiedPushInstance = "FOSSWarn";
  final String httpUserAgent = "de.nucleus.foss_warn";
  final String osmTileServerULR =
      "https://tile.openstreetmap.org/{z}/{x}/{y}.png";
}
