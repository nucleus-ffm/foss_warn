import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';

enum Certainty {
  /// Determined to have occurred or to be ongoing
  observed,

  /// Likely (p > ~50%)
  likely,

  /// Possible but not likely (p <=  ~50%)
  possible,

  /// Not expected to occur (p ~ 0)
  unlikely,

  /// Certainty unknown
  unknown,

  /// not part of CAP
  other;

  String toJson() => name;
  static Certainty fromJson(String? json) {
    try {
      return values.byName(json!.toLowerCase());
    } catch (e) {
      return unknown;
    }
  }

  String getLocalizedName(BuildContext context) {
    var localizations = context.localizations;

    return switch (this) {
      observed => localizations.warning_certainty_observed,
      likely => localizations.warning_certainty_likely,
      possible => localizations.warning_certainty_possible,
      unlikely => localizations.warning_certainty_unlikely,
      unknown => localizations.warning_certainty_unknown,
      other => localizations.warning_certainty_other,
    };
  }
}

/// extract the certainty from the string and return the corresponding enum
Certainty getCertainty(String certainty) {
  for (Certainty cer in Certainty.values) {
    if (cer.name == certainty.toLowerCase()) {
      return cer;
    }
  }
  return Certainty.other;
}
