import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/enums/severity.dart';
import 'package:foss_warn/extensions/context.dart';
import '../class/class_notification_preferences.dart';

class NotificationPreferencesListTileWidget extends ConsumerStatefulWidget {
  const NotificationPreferencesListTileWidget({super.key});

  @override
  ConsumerState<NotificationPreferencesListTileWidget> createState() =>
      _NotificationPreferencesListTileWidgetState();
}

class _NotificationPreferencesListTileWidgetState
    extends ConsumerState<NotificationPreferencesListTileWidget> {
  late double notificationLevel;

  @override
  void initState() {
    super.initState();

    var userPreferences = ref.read(userPreferencesProvider);
    notificationLevel = Severity.getIndexFromSeverity(
      userPreferences.notificationSourceSetting.notificationLevel,
    );
  }

  final EdgeInsets settingsTileListPadding =
      const EdgeInsets.fromLTRB(25, 2, 25, 2);

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

    var userPreferencesService = ref.watch(userPreferencesProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: settingsTileListPadding,
          child: const Divider(),
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
                      const Icon(
                        Icons.notifications_active,
                        color: Colors.red,
                      ),
                      Flexible(
                        child: Slider(
                          label: getLabelForWarningSeverity(notificationLevel),
                          divisions: 3,
                          min: 0,
                          max: 3,
                          value: notificationLevel,
                          onChanged: (value) {
                            notificationLevel = value;
                            setState(() {});
                          },
                          onChangeEnd: (value) {
                            // save settings, after change is complete
                            final notificationLevel =
                                Severity.values[value.toInt()];
                            userPreferencesService.setNotificationSourceSetting(
                              NotificationPreferences(
                                notificationLevel: notificationLevel,
                              ),
                            );
                          },
                        ),
                      ),
                      const Icon(
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
