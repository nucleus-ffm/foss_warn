import 'package:foss_warn/enums/NotificationLevel.dart';
import 'package:foss_warn/enums/WarningSource.dart';
/// to store the chosen notificationLevel for a warningSource
class NotificationPreferences {
  NotificationLevel notificationLevel;
  WarningSource warningSource;

  NotificationPreferences(
      {required this.warningSource, required this.notificationLevel});

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
        warningSource: WarningSource.fromJson(json['warningSource']),
        notificationLevel:
            NotificationLevel.fromJson(json['notificationLevel']));
  }

  Map<String, dynamic> toJson() => {
    'notificationLevel': notificationLevel.toJson(),
    'warningSource': warningSource.toJson(),
  };
}
