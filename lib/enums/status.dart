import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';

enum Status {
  /// Actionable by all targeted recipients
  actual,

  /// Actionable only by designated exercise participants
  exercise,

  /// For messages that support alert network internal functions
  system,

  /// Technical testing only, all recipients disregard
  test,

  /// A preliminary template or draft, not actionable in its current form
  draft,

  /// fallback field when the value from the alert is not valid
  unknown;

  String toJson() => name;
  static Status fromJson(String? json) {
    try {
      return values.byName(json!.toLowerCase());
    } catch (e) {
      return unknown;
    }
  }

  /// extract the severity from the string and return the corresponding enum
  static Status fromString(String status) {
    for (Status sta in Status.values) {
      if (sta.name == status.toLowerCase()) {
        return sta;
      }
    }
    return Status.actual; //@todo what should be the default value?
  }

  String getLocalizedName(BuildContext context) {
    var localizations = context.localizations;

    return switch (this) {
      actual => localizations.warning_status_actual,
      exercise => localizations.warning_status_exercise,
      system => localizations.warning_status_system,
      test => localizations.warning_status_test,
      draft => localizations.warning_status_draft,
      unknown => localizations.warning_status_unknown,
    };
  }
}
