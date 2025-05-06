import 'dart:convert';

import 'package:flutter/foundation.dart' as foundation;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/enums/sorting_categories.dart';
import 'package:foss_warn/main.dart';
import 'package:foss_warn/themes/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foss_warn/constants.dart' as constants;

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
  final NotificationPreferences _notificationSourceSetting =
      NotificationPreferences(notificationLevel: Severity.moderate);

  set notificationSourceSetting(NotificationPreferences newSetting) {
    _preferences.setString(
      "notificationSourceSettings",
      jsonEncode(newSetting),
    );
  }

  NotificationPreferences get notificationSourceSetting {
    String? data = _preferences.getString("notificationSourceSettings");
    if (data == null) {
      return _notificationSourceSetting;
    } else {
      return NotificationPreferences.fromJson(jsonDecode(data));
    }
  }

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

  final String _versionNumber = "1.0.0-alpha_1"; // shown in the about view
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

  final Duration networkTimeout = const Duration(seconds: 8);

  final List<ThemeData> availableLightThemes = [
    greenLightTheme,
    orangeLightTheme,
    purpleLightTheme,
    blueLightTheme,
    yellowLightTheme,
    indigoLightTheme,
  ];
  final List<ThemeData> availableDarkThemes = [
    greenDarkTheme,
    orangeDarkTheme,
    purpleDarkTheme,
    yellowDarkTheme,
    blueDarkTheme,
    greyDarkTheme,
  ];

  /// the path and filename where the error log is saved
  final String errorLogPath = "errorLog.txt";

  /// Dark mode colors for the map.
  /// invert(100%), hue-rotate(180deg), brightness(95%), contrast(90%)
  final ColorFilter mapDarkMode = const ColorFilter.matrix(<double>[
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
  final ColorFilter mapLightMode = const ColorFilter.matrix(<double>[
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
  String get fossPublicAlertServerUrl {
    String? data = _preferences.getString("fossPublicAlertServerUrl");
    if (foundation.kReleaseMode) {
      return data ?? constants.defaultFPASServerUrl;
    } else {
      // in DEBUG mode set to local server but also
      // allow to change the default server
      return data ?? "http://10.0.2.2:8000";
    }
  }

  set fossPublicAlertServerUrl(String newValue) {
    _preferences.setString("fossPublicAlertServerUrl", newValue);
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
        _preferences.getString("fossPublicAlertServerTermsOfService");
    return data ?? _fossPublicAlertServerTermsOfService;
  }

  set fossPublicAlertServerTermsOfService(String value) {
    _preferences.setString("fossPublicAlertServerTermsOfService", value);
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

  final List<String> _fossPublicAlertSubscriptionIdsToSubscribe =
      []; //@TODO(nucleus): there is the "server" missing in the name
  List<String> get fossPublicAlertSubscriptionIdsToSubscribe {
    List<String>? data =
        _preferences.getStringList("fossPublicAlertSubscriptionIdsToSubscribe");
    return data ?? _fossPublicAlertSubscriptionIdsToSubscribe;
  }

  set fossPublicAlertSubscriptionIdsToSubscribe(List<String> value) {
    _preferences.setStringList(
      "fossPublicAlertSubscriptionIdsToSubscribe",
      value,
    );
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

  String? get webPushVapidKey {
    String? data = _preferences.getString("webPushVapidKey");
    return data;
  }

  set webPushVapidKey(String? value) {
    if (value == null) {
      _preferences.remove("webPushVapidKey");
    } else {
      _preferences.setString("webPushVapidKey", value);
    }
  }

  String? get webPushAuthKey {
    String? data = _preferences.getString("webPushAuthKey");
    return data;
  }

  set webPushAuthKey(String? value) {
    if (value == null) {
      _preferences.remove("webPushAuthKey");
    } else {
      _preferences.setString("webPushAuthKey", value);
    }
  }

  String? get webPushPublicKey {
    String? data = _preferences.getString("webPushPublicKey");
    return data;
  }

  set webPushPublicKey(String? value) {
    if (value == null) {
      _preferences.remove("webPushPublicKey");
    } else {
      _preferences.setString("webPushPublicKey", value);
    }
  }
}

/// handle user preferences that need a provider like color theme settings
class UserPreferencesNotifier extends StateNotifier<UserPreferencesState> {
  UserPreferencesNotifier() : super(UserPreferencesState());

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );

    state = state.copyWith(
      shouldNotifyGeneral:
          prefs.getBool("shouldNotifyGeneral") ?? state.shouldNotifyGeneral,
      showStatusNotification: prefs.getBool("showStatusNotification") ??
          state.showStatusNotification,
      selectedThemeMode: _getThemeMode(prefs.getString("selectedThemeMode")),
      selectedDarkTheme:
          _getSelectedDarkTheme(prefs.getInt("selectedDarkTheme")),
      selectedLightTheme:
          _getSelectedLightTheme(prefs.getInt("selectedLightTheme")),
      startScreen: prefs.getInt("startScreen") ?? state.startScreen,
      warningFontSize:
          prefs.getDouble("warningFontSize") ?? state.warningFontSize,
      showWelcomeScreen:
          prefs.getBool("showWelcomeScreen") ?? state.showWelcomeScreen,
      sortWarningsBy: SortingCategories
          .values[prefs.getInt("sortWarningBy") ?? state.sortWarningsBy.index],
    );
  }

  void setShouldNotifyGeneral(bool value) {
    state = state.copyWith(shouldNotifyGeneral: value);
    _savePreference("shouldNotifyGeneral", value);
  }

  void setShowStatusNotification(bool value) {
    state = state.copyWith(showStatusNotification: value);
    _savePreference("showStatusNotification", value);
  }

  void setSelectedThemeMode(ThemeMode mode) {
    state = state.copyWith(selectedThemeMode: mode);
    _savePreference("selectedThemeMode", mode.toString());
  }

  void setStartScreen(int screen) {
    state = state.copyWith(startScreen: screen);
    _savePreference("startScreen", screen);
  }

  void setWarningFontSize(double size) {
    state = state.copyWith(warningFontSize: size);
    _savePreference("warningFontSize", size);
  }

  void setShowWelcomeScreen(bool value) {
    state = state.copyWith(showWelcomeScreen: value);
    _savePreference("showWelcomeScreen", value);
  }

  void setSortWarningsBy(SortingCategories category) {
    state = state.copyWith(sortWarningsBy: category);
    _savePreference("sortWarningBy", category.index);
  }

  void setSelectedLightTheme(ThemeData newTheme) {
    state = state.copyWith(selectedLightTheme: newTheme);
    _savePreference(
      "selectedLightTheme",
      userPreferences.availableLightThemes.indexOf(newTheme),
    );
  }

  void setSelectedDarkTheme(ThemeData newTheme) {
    state = state.copyWith(selectedDarkTheme: newTheme);
    _savePreference(
      "selectedDarkTheme",
      userPreferences.availableDarkThemes.indexOf(newTheme),
    );
  }

  static ThemeMode _getThemeMode(String? mode) {
    switch (mode) {
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  static ThemeData _getSelectedDarkTheme(int? theme) {
    if (theme != null &&
        theme > -1 &&
        theme < userPreferences.availableDarkThemes.length) {
      return userPreferences.availableDarkThemes[theme];
    } else {
      return userPreferences.availableDarkThemes.first;
    }
  }

  static ThemeData _getSelectedLightTheme(int? theme) {
    if (theme != null &&
        theme > -1 &&
        theme < userPreferences.availableLightThemes.length) {
      return userPreferences.availableLightThemes[theme];
    } else {
      return userPreferences.availableLightThemes.first;
    }
  }

  Future<void> _savePreference<T>(String key, T value) async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is int) {
      prefs.setInt(key, value);
    } else if (value is double) {
      prefs.setDouble(key, value);
    } else if (value is String) {
      prefs.setString(key, value);
    }
  }
}

class UserPreferencesState {
  final bool shouldNotifyGeneral;
  final bool showStatusNotification;
  final ThemeMode selectedThemeMode;
  ThemeData? selectedLightTheme;
  ThemeData? selectedDarkTheme;
  final int startScreen;
  final double warningFontSize;
  final bool showWelcomeScreen;
  final SortingCategories sortWarningsBy;

  UserPreferencesState({
    this.shouldNotifyGeneral = true,
    this.showStatusNotification = false,
    this.selectedThemeMode = ThemeMode.system,
    this.selectedDarkTheme,
    this.selectedLightTheme,
    this.startScreen = 0,
    this.warningFontSize = 14.0,
    this.showWelcomeScreen = true,
    this.sortWarningsBy = SortingCategories.severity,
  });

  UserPreferencesState copyWith({
    bool? shouldNotifyGeneral,
    bool? showStatusNotification,
    ThemeMode? selectedThemeMode,
    ThemeData? selectedDarkTheme,
    ThemeData? selectedLightTheme,
    int? startScreen,
    double? warningFontSize,
    bool? showWelcomeScreen,
    SortingCategories? sortWarningsBy,
  }) {
    return UserPreferencesState(
      shouldNotifyGeneral: shouldNotifyGeneral ?? this.shouldNotifyGeneral,
      showStatusNotification:
          showStatusNotification ?? this.showStatusNotification,
      selectedThemeMode: selectedThemeMode ?? this.selectedThemeMode,
      selectedDarkTheme: selectedDarkTheme ?? this.selectedDarkTheme,
      selectedLightTheme: selectedLightTheme ?? this.selectedLightTheme,
      startScreen: startScreen ?? this.startScreen,
      warningFontSize: warningFontSize ?? this.warningFontSize,
      showWelcomeScreen: showWelcomeScreen ?? this.showWelcomeScreen,
      sortWarningsBy: sortWarningsBy ?? this.sortWarningsBy,
    );
  }
}

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferencesState>(
  (ref) => UserPreferencesNotifier(),
);
