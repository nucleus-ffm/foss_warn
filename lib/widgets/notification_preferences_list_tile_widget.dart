import 'package:flutter/material.dart';
import 'package:foss_warn/enums/severity.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/services/save_and_load_shared_preferences.dart';
import '../class/class_notification_preferences.dart';

class NotificationPreferencesListTileWidget extends StatefulWidget {
  final NotificationPreferences notificationPreferences;
  const NotificationPreferencesListTileWidget(
      {super.key, required this.notificationPreferences});

  @override
  State<NotificationPreferencesListTileWidget> createState() =>
      _NotificationPreferencesListTileWidgetState();
}

class _NotificationPreferencesListTileWidgetState
    extends State<NotificationPreferencesListTileWidget> {
  final EdgeInsets settingsTileListPadding = EdgeInsets.fromLTRB(25, 2, 25, 2);

  // return the label for the given value
  String getLabelForWarningSeverity(double sliderValue) {
    var localizations = context.localizations;

    switch (sliderValue.toInt()) {
      case 0:
        return localizations.notification_settings_notify_by_extreme;
      case 1:
        return localizations.notification_settings_notify_by_severe;
      case 2:
        return localizations.notification_settings_notify_by_moderate;
      case 3:
        return localizations.notification_settings_notify_by_minor;
      default:
        return "Error";
    }
  }

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;

    return Column(
      children: [
        Padding(
          padding: settingsTileListPadding,
          child: Divider(),
        ),
        ListTile(
          contentPadding: settingsTileListPadding,
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // hide the slider when source is disabled
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: Colors.red,
                      ),
                      Flexible(
                        child: Slider(
                          label: getLabelForWarningSeverity(
                              Severity.getIndexFromSeverity(widget
                                  .notificationPreferences.notificationLevel)),
                          divisions: 3,
                          min: 0,
                          max: 3,
                          value: Severity.getIndexFromSeverity(
                              widget.notificationPreferences.notificationLevel),
                          onChanged: (value) {
                            setState(
                              () {
                                final notificationLevel =
                                    Severity.values[value.toInt()];

                                // update notification level with slider value
                                widget.notificationPreferences
                                    .notificationLevel = notificationLevel;
                              },
                            );
                          },
                          onChangeEnd: (value) {
                            // save settings, after change is complete
                            saveSettings();
                          },
                        ),
                      ),
                      Icon(
                        Icons.notifications,
                        color: Colors.orangeAccent,
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          localizations
                              .notification_settings_slidervalue_extreme,
                        ),
                        Text(
                          localizations
                              .notification_settings_slidervalue_severe,
                        ),
                        Text(
                          localizations
                              .notification_settings_slidervalue_moderate,
                        ),
                        Text(
                          localizations.notification_settings_slidervalue_minor,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
