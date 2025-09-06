import 'package:foss_warn/enums/severity.dart';
import 'package:foss_warn/enums/warning_source.dart';

/// to store the chosen notificationLevel for a warningSource
class NotificationPreferences {
  Severity notificationLevel;
  bool disabled;
  WarningSource warningSource;

  NotificationPreferences({
    required this.warningSource,
    required this.notificationLevel,
    this.disabled = false,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
        warningSource:
            WarningSource.fromString(json['warningSource'].toString()),
        disabled: json['disabled'],
        notificationLevel: Severity.fromJson(json['notificationLevel']));
  }

  Map<String, dynamic> toJson() => {
        'notificationLevel': notificationLevel.toJson(),
        'disabled': disabled,
        'warningSource': warningSource.toJson(),
      };
}
