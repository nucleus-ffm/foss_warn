import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foss_warn/class/class_notification_preferences.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/enums/category.dart';
import 'package:foss_warn/enums/severity.dart';
import 'package:foss_warn/enums/sorting_categories.dart';

void main() {
  NotificationPreferences createNotificationPreferences(
    Severity severity,
    Map<Category, Severity> catLevel,
  ) {
    return NotificationPreferences(
      globalNotificationLevel: severity,
      categoryNotificationLevel: catLevel,
    );
  }

  UserPreferences createUserPreferences(
    NotificationPreferences notificationPreferences,
  ) {
    return UserPreferences(
      notificationSourceSetting: notificationPreferences,
      shouldNotifyGeneral: true,
      showStatusNotification: true,
      showExtendedMetadata: true,
      selectedThemeMode: ThemeMode.system,
      selectedLightTheme: availableLightThemes[1],
      selectedDarkTheme: availableDarkThemes[1],
      startScreen: 1,
      warningFontSize: 12,
      showWelcomeScreen: false,
      sortWarningsBy: SortingCategories.severity,
      isFirstStart: false,
      areWarningsFromCache: false,
      maxSizeOfSubscriptionBoundingBox: 12,
      fossPublicAlertServerUrl: "http://example.com",
      fossPublicAlertServerOperator: "Example",
      fossPublicAlertServerPrivacyNotice: "http://example.com/",
      fossPublicAlertServerTermsOfService: "http://example.com",
      unifiedPushEndpoint: "",
      unifiedPushRegistered: false,
      fossPublicAlertSubscriptionIdsToSubscribe: [""],
      webPushVapidKey: "",
      webPushAuthKey: "",
      webPushPublicKey: "",
      previousInstalledVersionCode: 1,
      subscribeForTestAlerts: false,
      cachedAlerts: [],
      showDebugNotification: false,
    );
  }

  test(
    'test notification preferences - general only no other settings',
    () {
      for (Severity severityGlobal in Severity.values) {
        for (Category alertCategory in Category.values) {
          for (Severity alertSeverity in Severity.values) {
            Map<Category, Severity> catLevelMap = {};
            NotificationPreferences notificationPreferences =
                createNotificationPreferences(severityGlobal, catLevelMap);
            UserPreferences userPreferences =
                createUserPreferences(notificationPreferences);

            if (Severity.getIndexFromSeverity(severityGlobal) >=
                Severity.getIndexFromSeverity(alertSeverity)) {
              expect(
                NotificationPreferences.checkIfEventShouldBeNotified(
                  alertSeverity,
                  [alertCategory],
                  userPreferences,
                ),
                true,
                reason:
                    "Global severity setting $severityGlobal is higher or equal than alert severy $alertSeverity",
              );
            } else {
              expect(
                NotificationPreferences.checkIfEventShouldBeNotified(
                  alertSeverity,
                  [alertCategory],
                  userPreferences,
                ),
                false,
                reason:
                    "Global severity $severityGlobal is lower than alert severy $alertSeverity",
              );
            }
          }
        }
      }
    },
  );

  test(
    'test notification preferences - general + other settings',
    () {
      for (Severity severityGlobal in Severity.values) {
        for (Category settingCat in Category.values) {
          for (Severity settingSeverity in Severity.values) {
            Map<Category, Severity> catLevelMap = {settingCat: settingSeverity};
            NotificationPreferences notificationPreferences =
                createNotificationPreferences(severityGlobal, catLevelMap);
            UserPreferences userPreferences =
                createUserPreferences(notificationPreferences);

            for (Category alertCat in Category.values) {
              for (Severity alertSeverity in Severity.values) {
                // check if the global setting is applied -> setting is higher than alert => notification else no notification
                if (Severity.getIndexFromSeverity(severityGlobal) >=
                    Severity.getIndexFromSeverity(alertSeverity)) {
                  // check if the category setting is applied
                  if (alertCat == settingCat &&
                      Severity.getIndexFromSeverity(settingSeverity) <
                          Severity.getIndexFromSeverity(alertSeverity)) {
                    // the settings is higher than the alert => no notification
                    expect(
                      NotificationPreferences.checkIfEventShouldBeNotified(
                        alertSeverity,
                        [alertCat],
                        userPreferences,
                      ),
                      false,
                      reason:
                          "Global severity $severityGlobal is higher or equal than alert severy $alertSeverity and "
                          "for $alertCat $settingSeverity is selected",
                    );
                  } else {
                    expect(
                      NotificationPreferences.checkIfEventShouldBeNotified(
                        alertSeverity,
                        [alertCat],
                        userPreferences,
                      ),
                      true,
                      reason:
                          "Global severity $severityGlobal is higher or equal than alert severy $alertSeverity and "
                          "for $alertCat $settingSeverity is selected",
                    );
                  }
                } else {
                  expect(
                    false,
                    NotificationPreferences.checkIfEventShouldBeNotified(
                      alertSeverity,
                      [alertCat],
                      userPreferences,
                    ),
                    reason:
                        "Global severity $severityGlobal is lower than alert severy $alertSeverity and "
                        "for $alertCat $settingSeverity is selected",
                  );
                }
              }
            }
          }
        }
      }
    },
  );
}
