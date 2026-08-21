import 'package:flutter_test/flutter_test.dart';
import 'package:foss_warn/class/class_notification_preferences.dart';
import 'package:foss_warn/enums/category.dart';
import 'package:foss_warn/enums/severity.dart';

import 'helpers/test_preferences.dart';

/// The severity an alert is judged by.
///
/// A low index means a high danger: extreme = 0, minor = 3. An alert whose
/// severity we could not parse must not be dropped silently, so it is judged
/// as if it were moderate - the same middle ground
/// `NotificationChannel.fromSeverity` uses.
int judgedIndex(Severity alertSeverity) => Severity.getIndexFromSeverity(
      alertSeverity == Severity.unknown ? Severity.moderate : alertSeverity,
    );

bool shouldNotify({
  required Severity alertSeverity,
  required List<Category> alertCategories,
  required Severity globalLevel,
  Map<Category, Severity> categoryLevel = const {},
}) {
  return NotificationPreferences.checkIfEventShouldBeNotified(
    alertSeverity,
    alertCategories,
    createUserPreferences(
      notificationSourceSetting: createNotificationPreferences(
        globalNotificationLevel: globalLevel,
        categoryNotificationLevel: categoryLevel,
      ),
    ),
  );
}

void main() {
  group('global setting only', () {
    test('notifies when the global level is at or below the alert severity',
        () {
      for (final globalLevel in Severity.values) {
        for (final alertCategory in Category.values) {
          for (final alertSeverity in Severity.values) {
            final expected = Severity.getIndexFromSeverity(globalLevel) >=
                judgedIndex(alertSeverity);

            expect(
              shouldNotify(
                alertSeverity: alertSeverity,
                alertCategories: [alertCategory],
                globalLevel: globalLevel,
              ),
              expected,
              reason: "global $globalLevel, alert severity $alertSeverity, "
                  "category $alertCategory",
            );
          }
        }
      }
    });

    test('an alert of unknown severity still notifies', () {
      // Regression test: unknown has index 4 while the settings slider only
      // reaches minor (3), so comparing the raw index dropped every alert
      // whose severity we could not parse.
      for (final globalLevel in [
        Severity.minor,
        Severity.moderate,
        Severity.unknown,
      ]) {
        expect(
          shouldNotify(
            alertSeverity: Severity.unknown,
            alertCategories: const [Category.other],
            globalLevel: globalLevel,
          ),
          isTrue,
          reason: "global $globalLevel must not silence an unknown severity",
        );
      }
    });

    test('a strict global level still applies to an unknown severity', () {
      for (final globalLevel in [Severity.extreme, Severity.severe]) {
        expect(
          shouldNotify(
            alertSeverity: Severity.unknown,
            alertCategories: const [Category.other],
            globalLevel: globalLevel,
          ),
          isFalse,
          reason: "global $globalLevel is stricter than moderate",
        );
      }
    });
  });

  group('global setting plus category settings', () {
    test('the category setting narrows, but never widens, the global one', () {
      for (final globalLevel in Severity.values) {
        for (final settingCategory in Category.values) {
          for (final settingSeverity in Severity.values) {
            for (final alertCategory in Category.values) {
              for (final alertSeverity in Severity.values) {
                final alertIndex = judgedIndex(alertSeverity);
                final globalIndex = Severity.getIndexFromSeverity(globalLevel);
                final categoryApplies = alertCategory == settingCategory &&
                    settingSeverity != Severity.unknown;

                final bool expected;
                if (globalIndex < alertIndex) {
                  // the global level is stricter than the alert
                  expected = false;
                } else if (categoryApplies) {
                  expected = Severity.getIndexFromSeverity(settingSeverity) >=
                      alertIndex;
                } else {
                  expected = true;
                }

                expect(
                  shouldNotify(
                    alertSeverity: alertSeverity,
                    alertCategories: [alertCategory],
                    globalLevel: globalLevel,
                    categoryLevel: {settingCategory: settingSeverity},
                  ),
                  expected,
                  reason: "global $globalLevel, alert $alertSeverity "
                      "($alertCategory), setting $settingSeverity "
                      "($settingCategory)",
                );
              }
            }
          }
        }
      }
    });

    test('the documented examples hold', () {
      // Taken from the doc comment of checkIfEventShouldBeNotified.
      expect(
        shouldNotify(
          alertSeverity: Severity.moderate,
          alertCategories: const [Category.met],
          globalLevel: Severity.minor,
          categoryLevel: const {Category.met: Severity.moderate},
        ),
        isTrue,
      );
      expect(
        shouldNotify(
          alertSeverity: Severity.minor,
          alertCategories: const [Category.met],
          globalLevel: Severity.moderate,
          categoryLevel: const {Category.met: Severity.moderate},
        ),
        isFalse,
      );
      expect(
        shouldNotify(
          alertSeverity: Severity.minor,
          alertCategories: const [Category.met],
          globalLevel: Severity.minor,
          categoryLevel: const {Category.met: Severity.severe},
        ),
        isFalse,
      );
    });

    test('a setting for another category does not apply', () {
      expect(
        shouldNotify(
          alertSeverity: Severity.minor,
          alertCategories: const [Category.met],
          globalLevel: Severity.minor,
          categoryLevel: const {Category.fire: Severity.extreme},
        ),
        isTrue,
      );
    });

    test('an alert with several categories uses the most permissive setting',
        () {
      expect(
        shouldNotify(
          alertSeverity: Severity.minor,
          alertCategories: const [Category.met, Category.geo],
          globalLevel: Severity.minor,
          categoryLevel: const {
            Category.met: Severity.extreme,
            Category.geo: Severity.minor,
          },
        ),
        isTrue,
        reason: "geo accepts minor alerts, so the alert is notified",
      );
    });

    test('an alert without categories falls back to the global setting', () {
      expect(
        shouldNotify(
          alertSeverity: Severity.minor,
          alertCategories: const [],
          globalLevel: Severity.minor,
          categoryLevel: const {Category.met: Severity.extreme},
        ),
        isTrue,
      );
    });
  });

  group('serialization', () {
    test('round trips through json', () {
      final preferences = createNotificationPreferences(
        globalNotificationLevel: Severity.severe,
        categoryNotificationLevel: const {
          Category.met: Severity.minor,
          Category.geo: Severity.extreme,
        },
      );

      final restored = NotificationPreferences.fromJson(preferences.toJson());

      expect(restored.globalNotificationLevel, Severity.severe);
      expect(
        restored.getSeverityLevelForOneCategory(Category.met),
        Severity.minor,
      );
      expect(
        restored.getSeverityLevelForOneCategory(Category.geo),
        Severity.extreme,
      );
      // A category without a setting reports unknown, which the check ignores.
      expect(
        restored.getSeverityLevelForOneCategory(Category.fire),
        Severity.unknown,
      );
    });

    test('reads settings written before the disabled flag existed', () {
      final restored = NotificationPreferences.fromJson({
        "notificationLevel": "moderate",
      });

      expect(restored.globalNotificationLevel, Severity.moderate);
      expect(restored.disabled, isFalse);
      expect(restored.categoryNotificationLevel, isEmpty);
    });
  });

  group('UserPreferences', () {
    test('copyWith keeps the untouched fields', () {
      final preferences = createUserPreferences();
      final copy = preferences.copyWith(showUpdateDialog: true);

      expect(copy.showUpdateDialog, isTrue);
      expect(
        copy.fossPublicAlertServerUrl,
        preferences.fossPublicAlertServerUrl,
      );
      expect(copy.alertService, preferences.alertService);
      expect(
        copy.notificationSourceSetting,
        same(preferences.notificationSourceSetting),
      );
    });
  });
}
