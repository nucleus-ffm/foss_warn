import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';

enum Severity {
  extreme, // Extraordinary threat to life or property
  severe, // Significant threat to life or property
  moderate, // Possible threat to life or property
  minor, // Minimal to no known threat to life or property
  unknown; // Severity unknown

  String toJson() => name;
  static Severity fromJson(String json) {
    try {
      return values.byName(json.toLowerCase());
    } catch (e) {
      debugPrint("[Severity] no value found: $e");
      return Severity.unknown;
    }
  }

  /// extract the severity from the string and return the corresponding enum
  static Severity fromString(String severity) {
    for (Severity sev in Severity.values) {
      if (sev.name == severity) {
        return sev;
      }
    }
    return Severity.minor;
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
    var localizations = context.localizations;

    switch (severity) {
      case Severity.minor:
        return localizations
            .notification_settings_notify_by_minor; //@todo use warning_severity_minor
      case Severity.moderate:
        return localizations
            .notification_settings_notify_by_moderate; //@todo use warning_severity_moderate
      case Severity.severe:
        return localizations
            .notification_settings_notify_by_severe; // warning_severity_severe
      case Severity.extreme:
        return localizations
            .notification_settings_notify_by_extreme; //warning_severity_extreme
      case Severity.unknown:
        return "Unknown"; //warning_severity_unknown
    }
  }

  /// get a fitting color by the severity of a warning message
  static Color getColorForSeverity(Severity severity) {
    switch (severity) {
      case Severity.minor:
        return Colors.blueAccent;
      case Severity.moderate:
        return Colors.orange;
      case Severity.severe:
        return Colors.deepOrange;
      case Severity.extreme:
        return Colors.red;
      case Severity.unknown:
        return Colors.grey;
    }
  }

  /// translate the severity of a warning message
  /// @todo: Add translations
  @Deprecated("")
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
