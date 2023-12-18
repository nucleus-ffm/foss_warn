// represents the settings for the notification per sourcee
// getUpToMinor: You receive all warnings up to minor warnings
// getUpToModerate: You receive all warnings up to moderate warnings. For minor
// warnings you wont receive a notification
// etc.
enum NotificationLevel {
  getUpToMinor,
  getUpToModerate,
  getUpToSevere,
  getUpToExtreme,
  disabled;

  String toJson() => name;
  static NotificationLevel fromJson(String json) => values.byName(json);
}
