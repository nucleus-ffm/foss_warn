import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/enums/daytime.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/widgets/notification_preferences_list_tile_widget.dart';
import 'package:foss_warn/widgets/dialogs/warning_severity_explanation.dart';
import 'package:foss_warn/enums/category.dart';

import '../services/url_launcher.dart';

class NotificationSettingsView extends ConsumerStatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  ConsumerState<NotificationSettingsView> createState() =>
      _NotificationSettingsViewState();
}

class _NotificationSettingsViewState
    extends ConsumerState<NotificationSettingsView> {
  final EdgeInsets settingsTileListPadding =
      const EdgeInsets.fromLTRB(25, 2, 25, 2);

  String findLabelForChip(String key) {
    switch (key) {
      //@TODO(Nucleus): Translate
      case "headline":
        return "Title";
      case "description":
        return "Beschreibung";
      case "severity":
        return "Schweregrad";
      case "category":
        return "Katagorie";
      case "instructions":
        return "Handlungsempfehlung";
      case "sender":
        return "Absender";
    }
    return "Error";
  }

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.notification_settings_headline),
        actions: [
          IconButton(
            onPressed: () {
              launchUrlInBrowser(
                'https://github.com/nucleus-ffm/foss_warn/wiki/Notification-Settings',
              );
            },
            icon: const Icon(Icons.help),
            tooltip: localizations.help_button_tooltip,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: settingsTileListPadding,
                child: Text(localizations.notification_settings_description),
              ),
              const SizedBox(height: 10),
              Container(
                padding: settingsTileListPadding,
                child: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const WarningSeverityExplanation();
                      },
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info),
                      const SizedBox(width: 10),
                      Text(
                        localizations
                            .notification_settings_open_severity_explanation,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.sunny,
                      size: IconTheme.of(context).size,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        localizations.notification_settings_start_of_the_day,
                      ),
                      TextButton(
                        onPressed: () async {
                          TimeOfDay? newStartTime = await showTimePicker(
                            context: context,
                            initialTime: const TimeOfDay(hour: 8, minute: 0),
                          );
                          if (newStartTime != null) {
                            ref
                                .read(userPreferencesProvider.notifier)
                                .setStartOfDay(newStartTime);
                          }
                        },
                        child: Text(
                          ref
                              .watch(userPreferencesProvider)
                              .startOfDay
                              .format(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 150,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Divider(
                        height: 50,
                        indent: 15,
                        endIndent: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(localizations.notification_settings_end_of_the_day),
                      TextButton(
                        onPressed: () async {
                          TimeOfDay? newEndTime = await showTimePicker(
                            context: context,
                            initialTime: const TimeOfDay(hour: 22, minute: 0),
                          );
                          if (newEndTime != null) {
                            ref
                                .read(userPreferencesProvider.notifier)
                                .setEndOfDay(newEndTime);
                          }
                        },
                        child: Text(
                          ref
                              .watch(userPreferencesProvider)
                              .endOfDay
                              .format(context),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.nightlight,
                      size: IconTheme.of(context).size,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),

              SegmentedButton(
                onSelectionChanged: (Set<Daytime> newSelection) {
                  ref.read(selectedDayTimeProvider.notifier).state =
                      newSelection.first;
                },
                segments: [
                  ButtonSegment(
                    value: Daytime.day,
                    icon: const Icon(Icons.sunny),
                    label: Text(localizations.notification_settings_day),
                  ),
                  ButtonSegment(
                    value: Daytime.night,
                    icon: const Icon(Icons.nightlight),
                    label: Text(localizations.notification_settings_night),
                  ),
                ],
                selected: <Daytime>{ref.watch(selectedDayTimeProvider)},
              ),

              // generate the settings tiles
              NotificationPreferencesListTileWidget(
                name: localizations.notification_settings_global_warning_level,
              ),
              const SizedBox(
                height: 20,
              ),
              ExpansionTile(
                title: Text(
                  localizations
                      .notification_settings_show_advanced_settings_title,
                ),
                subtitle: Text(
                  localizations
                      .notification_settings_show_advanced_settings_subtitle,
                ),
                children: [
                  ...Category.values.map(
                    (element) => NotificationPreferencesListTileWidget(
                      name: element.getLocalizedName(context),
                      category: element,
                    ),
                  ),
                ],
              ),

              const Divider(),
              ListTile(
                title: Text(
                  localizations
                      .notification_settings_enabled_foss_warn_tv_title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  localizations
                      .notification_settings_enabled_foss_warn_tv_subtitle,
                ),
                trailing: Switch(
                  value: ref.watch(selectedDayTimeProvider) == Daytime.day
                      ? ref.watch(
                          userPreferencesProvider.select(
                            (userPreferences) =>
                                userPreferences.enableFOSSWarnAtTvDay,
                          ),
                        )
                      : ref.watch(
                          userPreferencesProvider.select(
                            (userPreferences) =>
                                userPreferences.enableFOSSWarnAtTvNight,
                          ),
                        ),
                  onChanged: (value) {
                    if (ref.watch(selectedDayTimeProvider) == Daytime.day) {
                      ref
                          .read(userPreferencesProvider.notifier)
                          .setEnableFOSSWarnAtTvDay(value);
                    } else {
                      ref
                          .read(userPreferencesProvider.notifier)
                          .setEnableFOSSWarnAtTvNight(value);
                    }
                  },
                ),
              ),
              // only display duration slider if the TV option is enabled
              ref.watch(
                            userPreferencesProvider.select(
                              (userPreferences) =>
                                  userPreferences.enableFOSSWarnAtTvDay,
                            ),
                          ) &&
                          ref.watch(selectedDayTimeProvider) == Daytime.day ||
                      ref.watch(
                            userPreferencesProvider.select(
                              (userPreferences) =>
                                  userPreferences.enableFOSSWarnAtTvNight,
                            ),
                          ) &&
                          ref.watch(selectedDayTimeProvider) == Daytime.night
                  ? ListTile(
                      title: Text(
                        localizations
                            .notification_settings_duration_on_tv_title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations
                                    .notification_settings_duration_on_tv_subtitle,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  const Icon(
                                    Icons.tv,
                                    color: Colors.amber,
                                  ),
                                  Flexible(
                                    child: Slider(
                                      label: ref
                                          .watch(
                                            userPreferencesProvider.select(
                                              (userPreferences) =>
                                                  userPreferences
                                                      .displayDurationOnTv,
                                            ),
                                          )
                                          .toString(),
                                      divisions: 14,
                                      min: 1,
                                      max: 15,
                                      value: ref
                                          .watch(
                                            userPreferencesProvider.select(
                                              (userPreferences) =>
                                                  userPreferences
                                                      .displayDurationOnTv,
                                            ),
                                          )
                                          .toDouble(),
                                      onChanged: (value) {
                                        ref
                                            .read(
                                              userPreferencesProvider.notifier,
                                            )
                                            .setDisplayDurationOnTv(
                                              value.round(),
                                            );
                                        setState(() {});
                                      },
                                      onChangeEnd: (value) {
                                        ref
                                            .read(
                                              userPreferencesProvider.notifier,
                                            )
                                            .setDisplayDurationOnTv(
                                              value.round(),
                                            );
                                      },
                                    ),
                                  ),
                                  Text(
                                    "${ref.watch(userPreferencesProvider.select((userPreferences) => userPreferences.displayDurationOnTv))} min",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
              ListTile(
                title: Text(
                  localizations.notification_settings_read_out_the_alert_title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  localizations
                      .notification_settings_read_out_the_alert_subtitle,
                ),
                trailing: Switch(
                  value: ref.watch(selectedDayTimeProvider) == Daytime.day
                      ? ref.watch(
                          userPreferencesProvider.select(
                            (userPreferences) =>
                                userPreferences.readOutAlertDay,
                          ),
                        )
                      : ref.watch(
                          userPreferencesProvider.select(
                            (userPreferences) =>
                                userPreferences.readOutAlertNight,
                          ),
                        ),
                  onChanged: (value) {
                    if (ref.watch(selectedDayTimeProvider) == Daytime.day) {
                      ref
                          .read(userPreferencesProvider.notifier)
                          .setReadOutAlertDay(value);
                    } else {
                      ref
                          .read(userPreferencesProvider.notifier)
                          .setReadOutAlertNight(value);
                    }
                  },
                ),
              ),
              ListTile(
                title:
                    Text(localizations.notification_settings_speaker_settings),
                subtitle: Wrap(
                  children: ref
                      .watch(userPreferencesProvider)
                      .speakerSettings
                      .entries
                      .map(
                        (chip) => Padding(
                          padding: const EdgeInsets.all(1),
                          child: FilterChip(
                            tooltip:
                                "", //findTooltipTranslation(chip.key, chip.value),
                            label: Text(findLabelForChip(chip.key)),
                            backgroundColor: Colors.transparent,
                            shape: const StadiumBorder(side: BorderSide()),
                            selected: chip.value,
                            onSelected: (bool value) {
                              setState(
                                () {
                                  Map<String, bool> updatedMap = ref
                                      .read(userPreferencesProvider)
                                      .speakerSettings;
                                  updatedMap.update(
                                    chip.key,
                                    (value) => !value,
                                  );
                                  ref
                                      .watch(userPreferencesProvider.notifier)
                                      .setSpeakerSettings(
                                        updatedMap,
                                      );
                                },
                              );
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
