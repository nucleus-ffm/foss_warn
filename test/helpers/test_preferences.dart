import 'package:foss_warn/class/class_notification_preferences.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/class/class_warn_message.dart';
import 'package:foss_warn/enums/alert_service.dart';
import 'package:foss_warn/enums/category.dart';
import 'package:foss_warn/enums/severity.dart';
import 'package:foss_warn/enums/sorting_categories.dart';
import 'package:flutter/material.dart';

/// Build a [NotificationPreferences] instance for tests.
NotificationPreferences createNotificationPreferences({
  Severity globalNotificationLevel = Severity.minor,
  Map<Category, Severity> categoryNotificationLevel = const {},
  bool disabled = false,
}) {
  return NotificationPreferences(
    globalNotificationLevel: globalNotificationLevel,
    categoryNotificationLevel: Map.of(categoryNotificationLevel),
    disabled: disabled,
  );
}

/// Build a [UserPreferences] instance for tests.
///
/// Every field has a usable default so a test only has to name the values it
/// actually cares about. Keeping this in one place means adding a field to
/// [UserPreferences] breaks one file instead of every test.
UserPreferences createUserPreferences({
  NotificationPreferences? notificationSourceSetting,
  String fossPublicAlertServerUrl = "example.org",
  AlertService alertService = AlertService.push,
  String unifiedPushEndpoint = "",
  bool unifiedPushRegistered = false,
  String webPushVapidKey = "",
  String webPushAuthKey = "",
  String webPushPublicKey = "",
  bool alertArchive = false,
  bool restrictSearchToCities = false,
  SortingCategories sortWarningsBy = SortingCategories.severity,
  List<WarnMessage> cachedAlerts = const [],
}) {
  return UserPreferences(
    notificationSourceSetting:
        notificationSourceSetting ?? createNotificationPreferences(),
    shouldNotifyGeneral: true,
    showStatusNotification: true,
    showExtendedMetadata: true,
    selectedThemeMode: ThemeMode.system,
    selectedLightTheme: availableLightThemes.first,
    selectedDarkTheme: availableDarkThemes.first,
    startScreen: 0,
    warningFontSize: 14,
    showWelcomeScreen: false,
    sortWarningsBy: sortWarningsBy,
    isFirstStart: false,
    maxSizeOfSubscriptionBoundingBox: 12,
    fossPublicAlertServerUrl: fossPublicAlertServerUrl,
    fossPublicAlertServerOperator: "Example",
    fossPublicAlertServerPrivacyNotice: "https://example.org/privacy",
    fossPublicAlertServerTermsOfService: "https://example.org/terms",
    unifiedPushEndpoint: unifiedPushEndpoint,
    unifiedPushRegistered: unifiedPushRegistered,
    fossPublicAlertSubscriptionIdsToSubscribe: const [],
    webPushVapidKey: webPushVapidKey,
    webPushAuthKey: webPushAuthKey,
    webPushPublicKey: webPushPublicKey,
    previousInstalledVersionCode: 1,
    subscribeForTestAlerts: false,
    cachedAlerts: cachedAlerts,
    showDebugNotification: false,
    showUpdateDialog: false,
    locationTracking: false,
    alertService: alertService,
    alertArchive: alertArchive,
    restrictSearchToCities: restrictSearchToCities,
  );
}
