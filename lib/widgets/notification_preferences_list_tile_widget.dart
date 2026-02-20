import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/enums/severity.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/enums/category.dart';

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

    var userPreferences = ref.read(userPreferencesProvider);
    notificationLevel = Severity.getIndexFromSeverity(
      userPreferences.notificationSourceSetting.globalNotificationLevel,
    );
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

    if (widget.category != null) {
      intMaxValue = ref.watch(
        userPreferencesProvider.select(
          (preferences) =>
              preferences.notificationSourceSetting.globalNotificationLevel,
        ),
      );
      notificationLevel = Severity.getIndexFromSeverity(
        ref.watch(
          userPreferencesProvider.select(
            (preferences) => preferences.notificationSourceSetting
                .getSeverityLevelForOneCategory(widget.category!),
          ),
        ),
      );
      notificationLevel =
          min(Severity.getIndexFromSeverity(intMaxValue), notificationLevel);
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

                            var notificationMap = ref
                                .read(userPreferencesProvider)
                                .notificationSourceSetting
                                .categoryNotificationLevel;

                            if (widget.category != null) {
                              notificationMap[widget.category!] =
                                  notificationLevel;
                              userPreferencesService
                                  .setNotificationSourceSetting(
                                ref
                                    .read(userPreferencesProvider)
                                    .notificationSourceSetting
                                    .copyWith(
                                      categoryNotificationLevel:
                                          notificationMap,
                                    ),
                              );
                            } else {
                              userPreferencesService
                                  .setNotificationSourceSetting(
                                ref
                                    .read(userPreferencesProvider)
                                    .notificationSourceSetting
                                    .copyWith(
                                      globalNotificationLevel:
                                          notificationLevel,
                                    ),
                              );
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
