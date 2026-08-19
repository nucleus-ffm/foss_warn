import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';

enum Scope {
  public, // For general dissemination to unrestricted audiences
  restricted, // For dissemination only to users with a known operational requirement (see <restriction>, below)
  private, // For dissemination only to specified addresses (see <addresses>, below)
  unknown; // Fallback field if the value from the alert is not valid

  String toJson() => name;
  static Scope fromJson(String? json) {
    try {
      return values.byName(json!.toLowerCase());
    } catch (e) {
      return unknown;
    }
  }

  /// extract the severity from the string and return the corresponding enum
  static Scope fromString(String value) {
    for (Scope i in Scope.values) {
      if (i.name == value.toLowerCase()) {
        return i;
      }
    }
    return Scope.public; //@todo what should be the default value?
  }

  String getLocalizedName(BuildContext context) {
    var localizations = context.localizations;

    return switch (this) {
      public => localizations.warning_scope_public,
      restricted => localizations.warning_scope_restricted,
      private => localizations.warning_scope_private,
      unknown => localizations.warning_status_unknown,
    };
  }
}
