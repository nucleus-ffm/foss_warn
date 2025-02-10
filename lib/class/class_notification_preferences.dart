import 'package:foss_warn/enums/severity.dart';

/// to store the chosen notificationLevel for a warningSource
class NotificationPreferences {
  Severity notificationLevel;
  bool disabled;

  NotificationPreferences({
    required this.notificationLevel,
    this.disabled = false,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
        disabled: json['disabled'],
        notificationLevel: Severity.fromJson(json['notificationLevel']));
  }

  Map<String, dynamic> toJson() => {
        'notificationLevel': notificationLevel.toJson(),
        'disabled': disabled,
      };
}
