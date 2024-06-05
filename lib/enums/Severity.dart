import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum Severity {
  Extreme,  // Extraordinary threat to life or property
  Severe,   // Significant threat to life or property
  Moderate, // Possible threat to life or property
  Minor,    // Minimal to no known threat to life or property
  Unknown;  // Severity unknown

  String toJson() => name;
  static Severity fromJson(String json) {
    try {
      return values.byName(json);
    } catch (e) {
      print("[Severity] no value found: " + e.toString());
      return Severity.Unknown;
    }
  }

  /// extract the severity from the string and return the corresponding enum
  static Severity fromString(String severity) {
    for (Severity sev in Severity.values) {
      if (sev.name == severity) {
        return sev;
      }
    }
    return Severity.Minor;
  }

  static double getIndexFromSeverity(Severity notificationLevel) {
    final severities = Severity.values;
    for (int i = 0; i < severities.length; i++) {
      if (severities[i] == notificationLevel) {
        return i.toDouble();
      }
    }

    // default return value: index of Severity.minor
    return 3;
  }

  /// translate the severity of a warning message
  static String getLocalizationName(Severity severity, BuildContext context) {
    switch (severity) {
      case Severity.Minor:
        return AppLocalizations.of(context)!.notification_settings_notify_by_minor; //@todo use warning_severity_minor
      case Severity.Moderate:
        return AppLocalizations.of(context)!.notification_settings_notify_by_moderate; //@todo use warning_severity_moderate
      case Severity.Severe:
        return AppLocalizations.of(context)!.notification_settings_notify_by_severe; // warning_severity_severe
      case Severity.Extreme:
        return AppLocalizations.of(context)!.notification_settings_notify_by_extreme; //warning_severity_extreme
      case Severity.Unknown:
        return "Unknown"; //warning_severity_unknown
        //return AppLocalizations.of(context)!.notification_settings_notify_by_
      default:
        return severity.name;
    }
  }

  /// get a fitting color by the severity of a warning message
  static Color getColorForSeverity(Severity severity) {
    switch (severity) {
      case Severity.Minor:
        return Colors.blueAccent;
      case Severity.Moderate:
        return Colors.orange;
      case Severity.Severe:
        return Colors.deepOrange;
      case Severity.Extreme:
        return Colors.red;
      case Severity.Unknown:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// translate the severity of a warning message
  /// @todo: Add translations
  @deprecated
  static String translateWarningSeverity(String severity) {
    switch (severity) {
      case "minor":
        return "Gering";
      case "moderate":
        return "Moderat";
      case "extreme":
        return "Extrem";
      case "severe":
        return "Schwer";
      case "other":
        return "Sonstiges";
      default:
        return severity;
    }
  }

}




