import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';

enum AlertService {
  push,
  poll,
  pushAndPoll,
  nothing;

  String toJson() => name;

  /// Parse a value written by [toJson].
  ///
  /// The lookup is case insensitive because the stored value is compared
  /// against the enum name, and `pushAndPoll` does not survive a plain
  /// `byName(json.toLowerCase())` lookup.
  static AlertService fromJson(String json) => values.firstWhere(
        (value) => value.name.toLowerCase() == json.toLowerCase(),
      );

  String getLocalizedName(BuildContext context) {
    var localizations = context.localizations;

    return switch (this) {
      push => localizations.alert_service_push,
      poll => localizations.alert_service_poll,
      pushAndPoll => localizations.alert_service_push_and_poll,
      nothing => localizations.alert_service_nothing,
    };
  }
}
