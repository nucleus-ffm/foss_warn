enum NotificationChannel {
  minor,
  moderate,
  severe,
  extreme,
  state,
  other;
}

extension NotificationChannelExt on NotificationChannel {
  String get id {
    switch (this) {
      case NotificationChannel.minor:
        return "de.nucleus.foss_warn.notifications_minor";
      case NotificationChannel.moderate:
        return "de.nucleus.foss_warn.notifications_moderate";
      case NotificationChannel.severe:
        return "de.nucleus.foss_warn.notifications_severe";
      case NotificationChannel.extreme:
        return "de.nucleus.foss_warn.notifications_extreme";
      case NotificationChannel.state:
        return "de.nucleus.foss_warn.notifications_state";
      case NotificationChannel.other:
        return "de.nucleus.foss_warn.notifications_other";
    }
  }
}