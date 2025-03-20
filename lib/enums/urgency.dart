import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';

enum Urgency {
  immediate, // Responsive action SHOULD be taken immediately
  expected, // Responsive action SHOULD be taken soon (within next hour)
  future, // Responsive action SHOULD be taken in the near future
  past, // Responsive action is no longer required
  unknown; // Urgency not known

  String toJson() => name;
  static Urgency fromJson(String json) => values.byName(json.toLowerCase());

  /// extract the urgency from the string and return the corresponding enum
  static Urgency fromString(String urgency) {
    for (Urgency value in Urgency.values) {
      if (value.name == urgency.toLowerCase()) {
        return value;
      }
    }
    return Urgency.unknown; //@todo what should be the default value?
  }

  String getLocalizedName(BuildContext context) {
    var localizations = context.localizations;

    return switch (this) {
      immediate => localizations.warning_urgency_immediate,
      expected => localizations.warning_urgency_expected,
      future => localizations.warning_urgency_future,
      past => localizations.warning_urgency_past,
      unknown => localizations.warning_urgency_unknown,
    };
  }
}
