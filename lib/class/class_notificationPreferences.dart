import 'package:foss_warn/enums/Severity.dart';
import 'package:foss_warn/enums/WarningSource.dart';

/// to store the chosen notificationLevel for a warningSource
class NotificationPreferences {
  Severity notificationLevel;
  bool disabled;
  WarningSource warningSource;

  NotificationPreferences(
      {required this.warningSource, required this.notificationLevel, this.disabled = false});

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
        warningSource: WarningSource.fromString(json['warningSource'].toString()),
        disabled: json['disabled'] == "true", // @todo is there a better way to deserialize a boolean?
        notificationLevel:
            Severity.fromJson(json['notificationLevel']));
  }

  Map<String, dynamic> toJson() => {
    'notificationLevel': notificationLevel.toJson(),
    'disabled': disabled,
    'warningSource': warningSource.toJson(),
  };
}
