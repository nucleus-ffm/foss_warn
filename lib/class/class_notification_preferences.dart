import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/enums/severity.dart';
import 'package:foss_warn/enums/category.dart';

/// to store the chosen notificationLevel for an alert category
class NotificationPreferences {
  Severity globalNotificationLevel;
  bool disabled;
  Map<Category, Severity> categoryNotificationLevel;

  NotificationPreferences({
    required this.globalNotificationLevel,
    required this.categoryNotificationLevel,
    this.disabled = false,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      disabled: json['disabled'] ?? false,
      globalNotificationLevel: Severity.fromJson(json['notificationLevel']),
      categoryNotificationLevel: json['categoryNotificationLevel'] != null
          ? _parseCategoryNotificationLevelList(
              json['categoryNotificationLevel'],
            )
          : {},
    );
  }

  Map<String, dynamic> toJson() => {
        'notificationLevel': globalNotificationLevel.toJson(),
        'disabled': disabled,
        'categoryNotificationLevel': _categoryNotificationLevelToJson(),
      };

  NotificationPreferences copyWith({
    Severity? globalNotificationLevel,
    bool? disabled,
    Map<Category, Severity>? categoryNotificationLevel,
  }) =>
      NotificationPreferences(
        globalNotificationLevel:
            globalNotificationLevel ?? this.globalNotificationLevel,
        disabled: disabled ?? this.disabled,
        categoryNotificationLevel:
            categoryNotificationLevel ?? this.categoryNotificationLevel,
      );

  Map<String, String> _categoryNotificationLevelToJson() {
    Map<String, String> result = {};

    categoryNotificationLevel.forEach((key, value) {
      result[key.toJson()] = value.toJson();
    });
    return result;
  }

  /// get the severity setting for the given category
  /// return Severity.unknown if there is no setting
  List<Severity> getSeverityLevelForMultipleCategories(
    List<Category> categories,
  ) {
    List<Severity> result = [];
    for (var cat in categories) {
      result.add(categoryNotificationLevel[cat] ?? Severity.unknown);
    }
    return result;
  }

  // get the severy level for one category
  Severity getSeverityLevelForOneCategory(Category category) {
    return categoryNotificationLevel[category] ?? Severity.unknown;
  }

  /// parse the list of categories and their notification preference
  static Map<Category, Severity> _parseCategoryNotificationLevelList(
    Map<String, dynamic> json,
  ) {
    Map<Category, Severity> result = {};

    json.forEach(
      (key, value) => result[Category.fromJson(key)] = Severity.fromJson(value),
    );
    return result;
  }

  /// Return [true] if the user wants a notification - [false] if not.
  ///
  /// If the user selected a category setting, this setting is applied. In every
  /// other case, the global setting is applied. The a lower global setting will always override
  /// the a higher category setting.
  ///
  /// A low severity index is a higher danger. Extreme = 0, minor = 3
  ///
  /// example:
  /// ```
  /// Warning severity | Global notification setting | Category setting | notification?
  /// Moderate (2)     | Minor (3)                   | Moderate (2)     | 3 >= 2 && 2 >= 2 => true
  /// Minor (3)        | Moderate (2)                | Moderate (2)     | 2 >= 3 && 2 >= 2 => false
  /// Minor (3)        | Minor (3)                   | Severe (1)       | 3 >= 2 && 1 >= 3 => false
  /// ```
  static bool checkIfEventShouldBeNotified(
    Severity alertSeverity,
    List<Category> alertCategories,
    UserPreferences userPreferences,
  ) {
    final notificationSettings = userPreferences.notificationSourceSetting;
    // An unknown severity must not silently drop the alert.
    final effectiveSeverity =
        alertSeverity == Severity.unknown ? Severity.moderate : alertSeverity;
    final alertSeverityIndex = Severity.getIndexFromSeverity(effectiveSeverity);
    final globalNotificationLevel = Severity.getIndexFromSeverity(
      notificationSettings.globalNotificationLevel,
    );

    if (globalNotificationLevel < alertSeverityIndex) {
      // the global level is higher than the alert severity -> no notification
      return false;
    }

    final List<Severity> selectedCategorySeverity = userPreferences
        .notificationSourceSetting
        .getSeverityLevelForMultipleCategories(alertCategories);

    // find the highest selected value
    int highestSettingsLevel = -1;
    for (final severity in selectedCategorySeverity) {
      if (severity != Severity.unknown) {
        final index = Severity.getIndexFromSeverity(severity);
        if (index > highestSettingsLevel) {
          highestSettingsLevel = index;
        }
      }
    }

    if (highestSettingsLevel == -1) {
      // no specific category found, use global value
      return true;
    }

    // apply category setting
    return highestSettingsLevel >= alertSeverityIndex;
  }
}
