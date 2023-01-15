import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../class/class_alarmManager.dart';
import '../services/saveAndLoadSharedPreferences.dart';
import 'SettingsView.dart';


class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsView> createState() => _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView> {
  final EdgeInsets settingsTileListPadding = EdgeInsets.fromLTRB(25, 2, 25, 2);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).notification_settings_headline),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
      //padding: const EdgeInsets.fromLTRB(20, 20, 20, 1),
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
              title: Text(AppLocalizations.of(context).notification_settings_notify_by_extreme),
              trailing: Switch(
                  activeColor: Theme.of(context).colorScheme.secondary,
                  value: notificationWithExtreme,
                  onChanged: (value) {
                    if (notificationGeneral) {
                      setState(() {
                        notificationWithExtreme = value;
                        saveNotificationSettingsImportanceList();
                        /*BackgroundTaskManager()
                                      .cancelBackgroundTask();
                                  BackgroundTaskManager()
                                      .registerBackgroundTaskWithDelay(); */
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
              title: Text(AppLocalizations.of(context).notification_settings_notify_by_severe),
              trailing: Switch(
                  activeColor: Theme.of(context).colorScheme.secondary,
                  value: notificationWithSevere,
                  onChanged: (value) {
                    if (notificationGeneral) {
                      setState(() {
                        notificationWithSevere = value;
                        saveNotificationSettingsImportanceList();
                        /*BackgroundTaskManager()
                                      .cancelBackgroundTask();
                                  BackgroundTaskManager()
                                      .registerBackgroundTaskWithDelay(); */
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
              title: Text(AppLocalizations.of(context).notification_settings_notify_by_moderate),
              trailing: Switch(
                  activeColor: Theme.of(context).colorScheme.secondary,
                  value: notificationWithModerate,
                  onChanged: (value) {
                    if (notificationGeneral) {
                      setState(() {
                        notificationWithModerate = value;
                        saveNotificationSettingsImportanceList();
                        /*BackgroundTaskManager()
                                      .cancelBackgroundTask();
                                  BackgroundTaskManager()
                                      .registerBackgroundTaskWithDelay(); */
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
              title: Text(AppLocalizations.of(context).notification_settings_notify_by_minor),
              trailing: Switch(
                  activeColor: Theme.of(context).colorScheme.secondary,
                  value: notificationWithMinor,
                  onChanged: (value) {
                    if (notificationGeneral) {
                      setState(() {
                        notificationWithMinor = value;
                        saveNotificationSettingsImportanceList();
                        /*BackgroundTaskManager()
                                      .cancelBackgroundTask();
                                  BackgroundTaskManager()
                                      .registerBackgroundTaskWithDelay(); */
                        AlarmManager().cancelBackgroundTask();
                        AlarmManager().registerBackgroundTask();
                      });
                    } else {
                      print("Background notification is disabled");
                    }
                  }),
            ),
            SizedBox(height: 10,),
            Text(
              "DWD",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Text(AppLocalizations.of(context).notification_settings_thunderstorm),
              trailing: Switch(
                  activeColor: Theme.of(context).colorScheme.secondary,
                    value: notificationEventsSettings["STARKES GEWITTER"]
                        != null ? notificationEventsSettings["STARKES GEWITTER"]!
                        : true ,
                    //value: notificationEventsSettings.values.firstWhere((element) => notificationEventsSettings[element]== "starkesGewitter", orElse: () => true),
                    onChanged: (value) {
                      setState(() {
                        notificationEventsSettings.putIfAbsent("STARKES GEWITTER", () => value);
                        notificationEventsSettings.update("STARKES GEWITTER", (newValue) => value);
                      });
                      saveSettings();
                      print(notificationEventsSettings);
                    })
            ),
            ListTile(
                contentPadding: settingsTileListPadding,
                title: Text(AppLocalizations.of(context).notification_settings_strong_weather),
                trailing: Switch(
                    activeColor: Theme.of(context).colorScheme.secondary,
                    value: notificationEventsSettings["STARKES WETTER"]
                        != null ? notificationEventsSettings["STARKES WETTER"]!
                        : true ,
                    //value: notificationEventsSettings.values.firstWhere((element) => notificationEventsSettings[element]== "starkesGewitter", orElse: () => true),
                    onChanged: (value) {
                      setState(() {
                        notificationEventsSettings.putIfAbsent("STARKES WETTER", () => value);
                        notificationEventsSettings.update("STARKES WETTER", (newValue) => value);
                      });
                      saveSettings();
                    })
            ),
            ListTile(
                contentPadding: settingsTileListPadding,
                title: Text(AppLocalizations.of(context).notification_settings_everything_else),
                trailing: Switch(
                    activeColor: Theme.of(context).colorScheme.secondary,
                    value: true,
                    onChanged: null)
            ),

            SizedBox(height: 10,),
            Text(
              "Mowas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
                contentPadding: settingsTileListPadding,
                title: Text(AppLocalizations.of(context).notification_settings_everything),
                trailing: Switch(
                    activeColor: Theme.of(context).colorScheme.secondary,
                    value: true,
                    onChanged: null)
            ),
            SizedBox(height: 10,),
            Text(
              "BIWAPP",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
                contentPadding: settingsTileListPadding,
                title: Text(AppLocalizations.of(context).notification_settings_everything),
                trailing: Switch(
                    activeColor: Theme.of(context).colorScheme.secondary,
                    value: true,
                    onChanged: null)
            ),
            SizedBox(height: 10,),
            Text(
              "KATWARN",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
                contentPadding: settingsTileListPadding,
                title: Text(AppLocalizations.of(context).notification_settings_everything),
                trailing: Switch(
                    activeColor: Theme.of(context).colorScheme.secondary,
                    value: true,
                    onChanged: null)
            ),

            SizedBox(height: 10,),
            Text(
              "LHP",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
                contentPadding: settingsTileListPadding,
                title: Text(AppLocalizations.of(context).notification_settings_everything),
                trailing: Switch(
                    activeColor: Theme.of(context).colorScheme.secondary,
                    value: true,
                    onChanged: null)
            ),
          ],
        ),
      ),
    )
    );
  }
}
