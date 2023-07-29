import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../class/class_alarmManager.dart';
import '../main.dart';
import '../services/saveAndLoadSharedPreferences.dart';

class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsView> createState() =>
      _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView> {
  final EdgeInsets settingsTileListPadding = EdgeInsets.fromLTRB(25, 2, 25, 2);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context).notification_settings_headline),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Text(
                AppLocalizations.of(context).notification_settings_notify_by,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                contentPadding: settingsTileListPadding,
                title: Text(AppLocalizations.of(context)
                    .notification_settings_notify_by_extreme),
                trailing: Switch(
                    activeColor: Theme.of(context).colorScheme.secondary,
                    value: userPreferences.notificationWithExtreme,
                    onChanged: (value) {
                      if (userPreferences.shouldNotifyGeneral) {
                        setState(() {
                          userPreferences.notificationWithExtreme = value;
                          saveNotificationSettingsImportanceList();
                          AlarmManager().cancelBackgroundTask();
                          AlarmManager().registerBackgroundTask();
                        });
                      } else {
                        print("Background notification is disabled");
                      }
                    }),
              ),
              ListTile(
                contentPadding: settingsTileListPadding,
                title: Text(AppLocalizations.of(context)
                    .notification_settings_notify_by_severe),
                trailing: Switch(
                    activeColor: Theme.of(context).colorScheme.secondary,
                    value: userPreferences.notificationWithSevere,
                    onChanged: (value) {
                      if (userPreferences.shouldNotifyGeneral) {
                        setState(() {
                          userPreferences.notificationWithSevere = value;
                          saveNotificationSettingsImportanceList();
                          AlarmManager().cancelBackgroundTask();
                          AlarmManager().registerBackgroundTask();
                        });
                      } else {
                        print("Background notification is disabled");
                      }
                    }),
              ),
              ListTile(
                contentPadding: settingsTileListPadding,
                title: Text(AppLocalizations.of(context)
                    .notification_settings_notify_by_moderate),
                trailing: Switch(
                    activeColor: Theme.of(context).colorScheme.secondary,
                    value: userPreferences.notificationWithModerate,
                    onChanged: (value) {
                      if (userPreferences.shouldNotifyGeneral) {
                        setState(() {
                          userPreferences.notificationWithModerate = value;
                          saveNotificationSettingsImportanceList();
                          AlarmManager().cancelBackgroundTask();
                          AlarmManager().registerBackgroundTask();
                        });
                      } else {
                        print("Background notification is disabled");
                      }
                    }),
              ),
              ListTile(
                contentPadding: settingsTileListPadding,
                title: Text(AppLocalizations.of(context)
                    .notification_settings_notify_by_minor),
                trailing: Switch(
                    activeColor: Theme.of(context).colorScheme.secondary,
                    value: userPreferences.notificationWithMinor,
                    onChanged: (value) {
                      if (userPreferences.shouldNotifyGeneral) {
                        setState(() {
                          userPreferences.notificationWithMinor = value;
                          saveNotificationSettingsImportanceList();
                          AlarmManager().cancelBackgroundTask();
                          AlarmManager().registerBackgroundTask();
                        });
                      } else {
                        print("Background notification is disabled");
                      }
                    }),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "DWD",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                  contentPadding: settingsTileListPadding,
                  title: Text(AppLocalizations.of(context)
                      .notification_settings_thunderstorm),
                  trailing: Switch(
                      activeColor: Theme.of(context).colorScheme.secondary,
                      value: userPreferences.notificationEventsSettings[
                                  "STARKES GEWITTER"] !=
                              null
                          ? userPreferences
                              .notificationEventsSettings["STARKES GEWITTER"]!
                          : true,
                      onChanged: (value) {
                        setState(() {
                          userPreferences.notificationEventsSettings
                              .putIfAbsent("STARKES GEWITTER", () => value);
                          userPreferences.notificationEventsSettings
                              .update("STARKES GEWITTER", (newValue) => value);
                        });
                        saveSettings();
                        print(userPreferences.notificationEventsSettings);
                      })),
              ListTile(
                  contentPadding: settingsTileListPadding,
                  title: Text(AppLocalizations.of(context)
                      .notification_settings_strong_weather),
                  trailing: Switch(
                      activeColor: Theme.of(context).colorScheme.secondary,
                      value: userPreferences.notificationEventsSettings[
                                  "STARKES WETTER"] !=
                              null
                          ? userPreferences
                              .notificationEventsSettings["STARKES WETTER"]!
                          : true,
                      onChanged: (value) {
                        setState(() {
                          userPreferences.notificationEventsSettings
                              .putIfAbsent("STARKES WETTER", () => value);
                          userPreferences.notificationEventsSettings
                              .update("STARKES WETTER", (newValue) => value);
                        });
                        saveSettings();
                      })),
              ListTile(
                  contentPadding: settingsTileListPadding,
                  title: Text(AppLocalizations.of(context)
                      .notification_settings_everything_else),
                  trailing: Switch(
                      activeColor: Theme.of(context).colorScheme.secondary,
                      value: true,
                      onChanged: null)),
              SizedBox(
                height: 10,
              ),
              Text(
                "Mowas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                  contentPadding: settingsTileListPadding,
                  title: Text(AppLocalizations.of(context)
                      .notification_settings_everything),
                  trailing: Switch(
                      activeColor: Theme.of(context).colorScheme.secondary,
                      value: true,
                      onChanged: null)),
              SizedBox(
                height: 10,
              ),
              Text(
                "BIWAPP",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                contentPadding: settingsTileListPadding,
                title: Text(AppLocalizations.of(context)
                    .notification_settings_everything),
                trailing: Switch(
                    activeColor: Theme.of(context).colorScheme.secondary,
                    value: true,
                    onChanged: null),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "KATWARN",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                contentPadding: settingsTileListPadding,
                title: Text(AppLocalizations.of(context)
                    .notification_settings_everything),
                trailing: Switch(
                    activeColor: Theme.of(context).colorScheme.secondary,
                    value: true,
                    onChanged: null),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "LHP",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                  contentPadding: settingsTileListPadding,
                  title: Text(AppLocalizations.of(context)
                      .notification_settings_everything),
                  trailing: Switch(
                      activeColor: Theme.of(context).colorScheme.secondary,
                      value: true,
                      onChanged: null)),
            ],
          ),
        ),
      ),
    );
  }
}
