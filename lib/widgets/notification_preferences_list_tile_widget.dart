import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/enums/severity.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/enums/category.dart';

import '../enums/daytime.dart';

class NotificationPreferencesListTileWidget extends ConsumerStatefulWidget {
  final String name;
  final Category? category;

  const NotificationPreferencesListTileWidget({
    super.key,
    required this.name,
    this.category,
  });

  @override
  ConsumerState<NotificationPreferencesListTileWidget> createState() =>
      _NotificationPreferencesListTileWidgetState();
}

class _NotificationPreferencesListTileWidgetState
    extends ConsumerState<NotificationPreferencesListTileWidget> {
  late int notificationLevel;
  Severity intMaxValue = Severity.minor;

  @override
  void initState() {
    super.initState();
  }

  final EdgeInsets settingsTileListPadding =
      const EdgeInsets.fromLTRB(25, 2, 25, 2);

  // return the label for the given value
  String getLabelForWarningSeverity(int sliderValue) {
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
    Daytime daytime = ref.watch(selectedDayTimeProvider);
    bool isDay = daytime == Daytime.day;

    if (widget.category != null) {
      if (isDay) {
        intMaxValue = ref.watch(
          userPreferencesProvider.select(
            (preferences) =>
                preferences.notificationDaySetting.globalNotificationLevel,
          ),
        );

        notificationLevel = Severity.getIndexFromSeverity(
          ref.watch(
            userPreferencesProvider.select(
              (preferences) => preferences.notificationDaySetting
                  .getSeverityLevelForOneCategory(widget.category!),
            ),
          ),
        );
      } else {
        intMaxValue = ref.watch(
          userPreferencesProvider.select(
            (preferences) =>
                preferences.notificationNightSetting.globalNotificationLevel,
          ),
        );

        notificationLevel = Severity.getIndexFromSeverity(
          ref.watch(
            userPreferencesProvider.select(
              (preferences) => preferences.notificationNightSetting
                  .getSeverityLevelForOneCategory(widget.category!),
            ),
          ),
        );
      }

      notificationLevel =
          min(Severity.getIndexFromSeverity(intMaxValue), notificationLevel);
    } else {
      if (isDay) {
        notificationLevel = Severity.getIndexFromSeverity(
          ref.watch(
            userPreferencesProvider.select(
              (preferences) =>
                  preferences.notificationDaySetting.globalNotificationLevel,
            ),
          ),
        );
      } else {
        notificationLevel = Severity.getIndexFromSeverity(
          ref.watch(
            userPreferencesProvider.select(
              (preferences) =>
                  preferences.notificationNightSetting.globalNotificationLevel,
            ),
          ),
        );
      }
    }

    var userPreferencesService = ref.watch(userPreferencesProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: settingsTileListPadding,
          child: const Divider(),
        ),
        ListTile(
          contentPadding: settingsTileListPadding,
          title:
              Text(widget.name, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.category != null
                      ? Text(widget.category!.getLocalizedExplanation(context))
                      : const SizedBox(),
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
                          value: notificationLevel.toDouble(),
                          onChanged: (value) {
                            notificationLevel = value.round();
                            setState(() {});
                          },
                          onChangeEnd: (value) {
                            // save settings, after change is complete
                            final notificationLevel =
                                Severity.values[value.toInt()];

                            if (widget.category != null) {
                              if (isDay) {
                                var notificationMap = ref
                                    .read(userPreferencesProvider)
                                    .notificationDaySetting
                                    .categoryNotificationLevel;
                                notificationMap[widget.category!] =
                                    notificationLevel;
                                userPreferencesService
                                    .setNotificationDaySetting(
                                  ref
                                      .read(userPreferencesProvider)
                                      .notificationDaySetting
                                      .copyWith(
                                        categoryNotificationLevel:
                                            notificationMap,
                                      ),
                                );
                              } else {
                                var notificationMap = ref
                                    .read(userPreferencesProvider)
                                    .notificationNightSetting
                                    .categoryNotificationLevel;
                                notificationMap[widget.category!] =
                                    notificationLevel;
                                userPreferencesService
                                    .setNotificationNightSetting(
                                  ref
                                      .read(userPreferencesProvider)
                                      .notificationNightSetting
                                      .copyWith(
                                        categoryNotificationLevel:
                                            notificationMap,
                                      ),
                                );
                              }
                            } else {
                              if (isDay) {
                                userPreferencesService
                                    .setNotificationDaySetting(
                                  ref
                                      .read(userPreferencesProvider)
                                      .notificationDaySetting
                                      .copyWith(
                                        globalNotificationLevel:
                                            notificationLevel,
                                      ),
                                );
                              } else {
                                userPreferencesService
                                    .setNotificationNightSetting(
                                  ref
                                      .read(userPreferencesProvider)
                                      .notificationNightSetting
                                      .copyWith(
                                        globalNotificationLevel:
                                            notificationLevel,
                                      ),
                                );
                              }
                            }
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
