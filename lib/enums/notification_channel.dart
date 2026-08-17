import 'package:flutter/cupertino.dart';
import 'package:foss_warn/enums/severity.dart';

import '../extensions/context.dart';

enum NotificationChannel {
  /// Notification channel for minor alerts
  minor,

  /// Notification channel for moderate alerts
  moderate,

  /// Notification channel for severe alerts
  severe,
  // Notification channel for extreme alerts
  extreme,

  /// Notification channel for updated alerts
  update,

  /// Notification channel for everything else, not used for alerts
  other,

  /// Notification channel for debug notifications, only used for debugging
  debug,

  /// Group summary for displaying a notification summary on < Android 7.0
  summary;

  /// Get the notification channel based on the alert severity
  factory NotificationChannel.fromSeverity(Severity severity) {
    switch (severity) {
      case Severity.extreme:
        return extreme;
      case Severity.severe:
        return severe;
      case Severity.moderate:
        return moderate;
      case Severity.minor:
        return minor;
      case Severity.unknown:
        // We don't know the severity, so just go for the middle way
        return moderate;
    }
  }

  /// return the channel name id of the channel name used for the notification
  String get channelId {
    switch (this) {
      case minor:
        return "de.nucleus.foss_warn.notifications_minor";
      case NotificationChannel.moderate:
        return "de.nucleus.foss_warn.notifications_moderate";
      case NotificationChannel.severe:
        return "de.nucleus.foss_warn.notifications_severe";
      case NotificationChannel.extreme:
        return "de.nucleus.foss_warn.notifications_extreme";
      case NotificationChannel.update:
        return "de.nucleus.foss_warn.notifications_update";
      case NotificationChannel.other:
        return "de.nucleus.foss_warn.notifications_other";
      case NotificationChannel.debug:
        return "de.nucleus.foss_warn.notifications_debug";
      case NotificationChannel.summary:
        return "de.nucleus.foss_warn.notifications_summary";
    }
  }

  String getLocalizedName(BuildContext context) {
    var localizations = context.localizations;
    switch (this) {
      case minor:
        return localizations.notification_settings_notify_by_minor;
      case NotificationChannel.moderate:
        return localizations.notification_settings_notify_by_moderate;
      case NotificationChannel.severe:
        return localizations.notification_settings_notify_by_severe;
      case NotificationChannel.extreme:
        return localizations.notification_settings_notify_by_extreme;
      case NotificationChannel.update:
        return localizations.notification_settings_notify_by_update;
      case NotificationChannel.other:
        return localizations.notification_channel_other_name;
      case NotificationChannel.debug:
        return localizations.notification_channel_debug_name;
      case NotificationChannel.summary:
        return localizations.notification_channel_summary_name;
    }
  }

  String getLocalizedDescription(BuildContext context) {
    var localizations = context.localizations;
    switch (this) {
      case minor:
        return localizations
            .warning_severity_explanation_dialog_minor_description;
      case NotificationChannel.moderate:
        return localizations
            .warning_severity_explanation_dialog_moderate_description;
      case NotificationChannel.severe:
        return localizations
            .warning_severity_explanation_dialog_severe_description;
      case NotificationChannel.extreme:
        return localizations
            .warning_severity_explanation_dialog_extreme_description;
      case NotificationChannel.update:
        return localizations
            .warning_severity_explanation_dialog_update_description;
      case NotificationChannel.other:
        return localizations.notification_channel_other_name;
      case NotificationChannel.debug:
        return localizations.notification_channel_debug_description;
      case NotificationChannel.summary:
        return localizations.notification_channel_summary_description;
    }
  }
}
