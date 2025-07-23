import 'dart:convert';

import 'package:flutter/foundation.dart' as foundation;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/enums/sorting_categories.dart';
import 'package:foss_warn/themes/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foss_warn/constants.dart' as constants;

import '../enums/severity.dart';
import 'class_notification_preferences.dart';

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

class SharedPreferencesState {
  static late final SharedPreferencesWithCache _preferences;

  SharedPreferencesState._();

  static SharedPreferencesWithCache get instance {
    return _preferences;
  }

  static Future<void> initialize() async {
    _preferences = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
  }
}

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesService, UserPreferences>((ref) {
  final preferences = SharedPreferencesState.instance;

  // Migrate from previous full enum name stored to only the name of the property
  // "ThemeMode.system" vs "system"
  var selectedThemeMode =
      preferences.getString("selectedThemeMode") ?? "system";
  if (!ThemeMode.values.any((element) => element.name == selectedThemeMode)) {
    selectedThemeMode = "system";
  }

  var selectedLightTheme = preferences.getInt("selectedLightTheme") ?? 0;
  if (selectedLightTheme > availableLightThemes.length - 1) {
    selectedLightTheme = 0;
  }

  var selectedDarkTheme = preferences.getInt("selectedDarkTheme") ?? 0;
  if (selectedDarkTheme > availableDarkThemes.length - 1) {
    selectedDarkTheme = 0;
  }

  var selectedSorting = preferences.getInt("sortWarningsBy") ?? 0;
  SortingCategories.values[selectedSorting];

  String? fossPublicAlertServerUrl =
      preferences.getString("fossPublicAlertServerUrl");
  if (foundation.kReleaseMode) {
    fossPublicAlertServerUrl ??= constants.defaultFPASServerUrl;
  } else {
    // in DEBUG mode set to local server but also
    // allow to change the default server
    fossPublicAlertServerUrl ??= "http://10.0.2.2:8000";
  }

  var notificationSourceSettingString =
      preferences.getString("notificationSourceSetting");
  var notificationPreferences =
      NotificationPreferences(notificationLevel: Severity.moderate);
  if (notificationSourceSettingString != null) {
    var notificationSourceSettingMap =
        jsonDecode(notificationSourceSettingString) as Map<String, dynamic>;
    notificationPreferences =
        NotificationPreferences.fromJson(notificationSourceSettingMap);
  }

  return UserPreferencesService(
    UserPreferences(
      shouldNotifyGeneral: preferences.getBool("shouldNotifyGeneral") ?? true,
      showStatusNotification:
          preferences.getBool("showStatusNotification") ?? true,
      showExtendedMetadata:
          preferences.getBool("showExtendedMetaData") ?? false,
      notificationSourceSetting: notificationPreferences,
      selectedThemeMode: ThemeMode.values.byName(selectedThemeMode),
      selectedLightTheme: availableLightThemes[selectedLightTheme],
      selectedDarkTheme: availableDarkThemes[selectedDarkTheme],
      startScreen: preferences.getInt("startScreen ") ?? 0,
      warningFontSize: preferences.getDouble("warningFontSize") ?? 14.0,
      showWelcomeScreen: preferences.getBool("showWelcomeScreen") ?? true,
      sortWarningsBy: SortingCategories.values[selectedSorting],
      isFirstStart: preferences.getBool("isFirstStart") ?? true,
      areWarningsFromCache:
          preferences.getBool("areWarningsFromCache") ?? false,
      maxSizeOfSubscriptionBoundingBox:
          preferences.getInt("maxSizeOfSubscriptionBoundingBox") ?? 20,
      fossPublicAlertServerUrl: fossPublicAlertServerUrl,
      fossPublicAlertServerOperator:
          preferences.getString("fossPublicAlertServerOperator") ?? "KDE",
      fossPublicAlertServerPrivacyNotice: preferences
              .getString("fossPublicAlertServerPrivacyNotice") ??
          "https://invent.kde.org/webapps/foss-public-alert-server/-/wikis/Privacy",
      fossPublicAlertServerTermsOfService: preferences
              .getString("fossPublicAlertServerTermsOfService") ??
          "https://invent.kde.org/webapps/foss-public-alert-server/-/wikis/Terms-of-Service",
      unifiedPushEndpoint: preferences.getString("unifiedPushEndpoint") ?? "",
      unifiedPushRegistered:
          preferences.getBool("unifiedPushRegistered") ?? false,
      fossPublicAlertSubscriptionIdsToSubscribe: preferences
              .getStringList("fossPublicAlertSubscriptionIdsToSubscribe") ??
          [],
      webPushVapidKey: preferences.getString("webPushVapidKey"),
      webPushAuthKey: preferences.getString("webPushAuthKey"),
      webPushPublicKey: preferences.getString("webPushPublicKey"),
      previousInstalledVersionCode:
          preferences.getInt("previousInstalledVersionCode") ?? -1,
      subscribeForTestAlerts:
          preferences.getBool("subscribeForTestAlerts") ?? false,
    ),
    sharedPreferences: preferences,
  );
});

class UserPreferencesService extends StateNotifier<UserPreferences> {
  final SharedPreferencesWithCache _sharedPreferences;

  UserPreferencesService(
    super.state, {
    required SharedPreferencesWithCache sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  void setShouldNotifyGeneral(bool value) {
    state = state.copyWith(shouldNotifyGeneral: value);
    _sharedPreferences.setBool("shouldNotifyGeneral", value);
  }

  void setShowStatusNotification(bool value) {
    state = state.copyWith(showStatusNotification: value);
    _sharedPreferences.setBool("showStatusNotification", value);
  }

  void setShowExtendedMetadata(bool value) {
    state = state.copyWith(showExtendedMetadata: value);
    _sharedPreferences.setBool("showExtendedMetaData", value);
  }

  void setNotificationSourceSetting(NotificationPreferences value) {
    state = state.copyWith(notificationSourceSetting: value);
    _sharedPreferences.setString(
      "notificationSourceSetting",
      jsonEncode(value),
    );
  }

  void setSelectedThemeMode(ThemeMode themeMode) {
    state = state.copyWith(selectedThemeMode: themeMode);
    _sharedPreferences.setString("selectedThemeMode", themeMode.name);
  }

  void setLightTheme(ThemeData theme) {
    state = state.copyWith(selectedLightTheme: theme);
    var indexSelectedTheme = availableLightThemes.indexOf(theme);
    _sharedPreferences.setInt("selectedLightTheme", indexSelectedTheme);
  }

  void setDarkTheme(ThemeData theme) {
    state = state.copyWith(selectedDarkTheme: theme);
    var indexSelectedTheme = availableDarkThemes.indexOf(theme);
    _sharedPreferences.setInt("selectedDarkTheme", indexSelectedTheme);
  }

  void setStartScreen(int value) {
    state = state.copyWith(startScreen: value);
    _sharedPreferences.setInt("startScreen", value);
  }

  void setWarningFontSize(double value) {
    state = state.copyWith(warningFontSize: value);
    _sharedPreferences.setDouble("warningFontSize", value);
  }

  void setShowWelcomeScreen(bool value) {
    state = state.copyWith(showWelcomeScreen: value);
    _sharedPreferences.setBool("showWelcomeScreen", value);
  }

  void setSortWarningsBy(SortingCategories category) {
    state = state.copyWith(sortWarningsBy: category);
    var indexSorting = SortingCategories.values.indexOf(category);
    _sharedPreferences.setInt("sortWarningsBy", indexSorting);
  }

  void setIsFirstStart(bool value) {
    state = state.copyWith(isFirstStart: value);
    _sharedPreferences.setBool("isFirstStart", value);
  }

  void setAreWarningsFromCache(bool value) {
    state = state.copyWith(areWarningsFromCache: value);
    _sharedPreferences.setBool("areWarningsFromCache", value);
  }

  void setMaxSizeOfSubscriptionBoundingBox(int value) {
    state = state.copyWith(maxSizeOfSubscriptionBoundingBox: value);
    _sharedPreferences.setInt("maxSizeOfSubscriptionBoundingBox", value);
  }

  void setFossPublicAlertServerUrl(String value) {
    state = state.copyWith(fossPublicAlertServerUrl: value);
    _sharedPreferences.setString("fossPublicAlertServerUrl", value);
  }

  void setFossPublicAlertServerOperator(String value) {
    state = state.copyWith(fossPublicAlertServerOperator: value);
    _sharedPreferences.setString("fossPublicAlertServerOperator", value);
  }

  void setFossPublicAlertServerPrivacyNotice(String value) {
    state = state.copyWith(fossPublicAlertServerPrivacyNotice: value);
    _sharedPreferences.setString("fossPublicAlertServerPrivacyNotice", value);
  }

  void setFossPublicAlertServerTermsOfService(String value) {
    state = state.copyWith(fossPublicAlertServerOperator: value);
    _sharedPreferences.setString("fossPublicAlertServerTermsOfService", value);
  }

  void setUnifiedpushEndpoint(String value) {
    state = state.copyWith(unifiedPushEndpoint: value);
    _sharedPreferences.setString("unifiedPushEndpoint", value);
  }

  void setUnifiedPushRegistered(bool value) {
    state = state.copyWith(unifiedPushRegistered: value);
    _sharedPreferences.setBool("unifiedPushRegistered", value);
  }

  void setFossPublicAlertSubscriptionIdsToSubscribe(List<String> value) {
    state = state.copyWith(fossPublicAlertSubscriptionIdsToSubscribe: value);
    _sharedPreferences.setStringList(
      "fossPublicAlertSubscriptionIdsToSubscribe",
      value,
    );
  }

  void setWebPushVapidKey(String? value) {
    state = state.copyWith(webPushVapidKey: value);
    if (value == null) {
      _sharedPreferences.remove("webPushVapidKey");
    } else {
      _sharedPreferences.setString("webPushVapidKey", value);
    }
  }

  void setWebPushPublicKey(String value) {
    state = state.copyWith(webPushPublicKey: value);
    _sharedPreferences.setString("webPushPublicKey", value);
  }

  void setWebPushAuthKey(String value) {
    state = state.copyWith(webPushAuthKey: value);
    _sharedPreferences.setString("webPushAuthKey", value);
  }

  void setPreviouslyInstalledVersionCode(int value) {
    state = state.copyWith(previousInstalledVersionCode: value);
    _sharedPreferences.setInt("previousInstalledVersionCode", value);
  }

  void setSubscribeForTestAlerts(bool value) {
    state = state.copyWith(subscribeForTestAlerts: value);
    _sharedPreferences.setBool("subscribeForTestAlerts", value);
  }
}

/// handle user preferences. The values written here are default values
/// the correct values are loaded in loadSettings() from sharedPreferences
class UserPreferences {
  UserPreferences({
    required this.shouldNotifyGeneral,
    required this.showStatusNotification,
    required this.showExtendedMetadata,
    required this.notificationSourceSetting,
    required this.selectedThemeMode,
    required this.selectedLightTheme,
    required this.selectedDarkTheme,
    required this.startScreen,
    required this.warningFontSize,
    required this.showWelcomeScreen,
    required this.sortWarningsBy,
    required this.isFirstStart,
    required this.areWarningsFromCache,
    required this.maxSizeOfSubscriptionBoundingBox,
    required this.fossPublicAlertServerUrl,
    required this.fossPublicAlertServerOperator,
    required this.fossPublicAlertServerPrivacyNotice,
    required this.fossPublicAlertServerTermsOfService,
    required this.unifiedPushEndpoint,
    required this.unifiedPushRegistered,
    required this.fossPublicAlertSubscriptionIdsToSubscribe,
    required this.webPushVapidKey,
    required this.webPushAuthKey,
    required this.webPushPublicKey,
    required this.previousInstalledVersionCode,
    required this.subscribeForTestAlerts,
  });

  final bool shouldNotifyGeneral;
  final bool showStatusNotification;
  final bool showExtendedMetadata;
  // to save the user settings for which source
  // the user would like to be notified
  final NotificationPreferences notificationSourceSetting;
  final ThemeMode selectedThemeMode;
  final ThemeData selectedLightTheme;
  final ThemeData selectedDarkTheme;
  final int startScreen;
  final double warningFontSize;
  final bool showWelcomeScreen;
  final SortingCategories sortWarningsBy;
  final bool isFirstStart;
  final bool areWarningsFromCache;
  final int maxSizeOfSubscriptionBoundingBox;

  final String fossPublicAlertServerUrl;
  final String fossPublicAlertServerOperator;
  final String fossPublicAlertServerPrivacyNotice;
  final String fossPublicAlertServerTermsOfService;
  final String unifiedPushEndpoint;
  final bool unifiedPushRegistered;
  final List<String> fossPublicAlertSubscriptionIdsToSubscribe;
  final String? webPushVapidKey;
  final String? webPushAuthKey;
  final String? webPushPublicKey;
  final bool subscribeForTestAlerts;

  // Version of the application, shown in the about view
  // TODO(PureTryOut): get this from package_info_plus instead
  // That way we only need to keep track of one number.
  static const String versionNumber = "1.0.0-alpha_1";

  static const int currentVersionCode = 32;
  final int previousInstalledVersionCode;

  static const String unifiedPushInstance = "FOSSWarn";
  static const String osmTileServerURL =
      "https://tile.openstreetmap.org/{z}/{x}/{y}.png";

  UserPreferences copyWith({
    bool? shouldNotifyGeneral,
    bool? showStatusNotification,
    bool? showExtendedMetadata,
    NotificationPreferences? notificationSourceSetting,
    ThemeMode? selectedThemeMode,
    ThemeData? selectedLightTheme,
    ThemeData? selectedDarkTheme,
    int? startScreen,
    double? warningFontSize,
    bool? showWelcomeScreen,
    SortingCategories? sortWarningsBy,
    bool? isFirstStart,
    bool? areWarningsFromCache,
    int? maxSizeOfSubscriptionBoundingBox,
    String? fossPublicAlertServerUrl,
    String? fossPublicAlertServerOperator,
    String? fossPublicAlertServerPrivacyNotice,
    String? fossPublicAlertServerTermsOfService,
    String? unifiedPushEndpoint,
    bool? unifiedPushRegistered,
    List<String>? fossPublicAlertSubscriptionIdsToSubscribe,
    String? webPushVapidKey,
    String? webPushAuthKey,
    String? webPushPublicKey,
    int? previousInstalledVersionCode,
    bool? subscribeForTestAlerts,
  }) =>
      UserPreferences(
        shouldNotifyGeneral: shouldNotifyGeneral ?? this.shouldNotifyGeneral,
        showStatusNotification:
            showStatusNotification ?? this.showStatusNotification,
        showExtendedMetadata: showExtendedMetadata ?? this.showExtendedMetadata,
        notificationSourceSetting:
            notificationSourceSetting ?? this.notificationSourceSetting,
        selectedThemeMode: selectedThemeMode ?? this.selectedThemeMode,
        selectedLightTheme: selectedLightTheme ?? this.selectedLightTheme,
        selectedDarkTheme: selectedDarkTheme ?? this.selectedDarkTheme,
        startScreen: startScreen ?? this.startScreen,
        warningFontSize: warningFontSize ?? this.warningFontSize,
        showWelcomeScreen: showWelcomeScreen ?? this.showWelcomeScreen,
        sortWarningsBy: sortWarningsBy ?? this.sortWarningsBy,
        isFirstStart: isFirstStart ?? this.isFirstStart,
        areWarningsFromCache: areWarningsFromCache ?? this.areWarningsFromCache,
        maxSizeOfSubscriptionBoundingBox: maxSizeOfSubscriptionBoundingBox ??
            this.maxSizeOfSubscriptionBoundingBox,
        fossPublicAlertServerUrl:
            fossPublicAlertServerUrl ?? this.fossPublicAlertServerUrl,
        fossPublicAlertServerOperator:
            fossPublicAlertServerOperator ?? this.fossPublicAlertServerOperator,
        fossPublicAlertServerPrivacyNotice:
            fossPublicAlertServerPrivacyNotice ??
                this.fossPublicAlertServerPrivacyNotice,
        fossPublicAlertServerTermsOfService:
            fossPublicAlertServerTermsOfService ??
                this.fossPublicAlertServerTermsOfService,
        unifiedPushEndpoint: unifiedPushEndpoint ?? this.unifiedPushEndpoint,
        unifiedPushRegistered:
            unifiedPushRegistered ?? this.unifiedPushRegistered,
        fossPublicAlertSubscriptionIdsToSubscribe:
            fossPublicAlertSubscriptionIdsToSubscribe ??
                this.fossPublicAlertSubscriptionIdsToSubscribe,
        webPushVapidKey: webPushVapidKey ?? this.webPushVapidKey,
        webPushAuthKey: webPushAuthKey ?? this.webPushAuthKey,
        webPushPublicKey: webPushPublicKey ?? this.webPushPublicKey,
        previousInstalledVersionCode:
            previousInstalledVersionCode ?? this.previousInstalledVersionCode,
        subscribeForTestAlerts:
            subscribeForTestAlerts ?? this.subscribeForTestAlerts,
      );

  /// the path and filename where the error log is saved
  static const String errorLogPath = "errorLog.txt";

  /// Dark mode colors for the map.
  /// invert(100%), hue-rotate(180deg), brightness(95%), contrast(90%)
  static const ColorFilter mapDarkMode = ColorFilter.matrix(<double>[
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
  static const ColorFilter mapLightMode = ColorFilter.matrix(<double>[
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
}
