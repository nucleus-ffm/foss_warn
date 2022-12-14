import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foss_warn/class/class_NotificationService.dart';
import 'package:foss_warn/class/class_alarmManager.dart';
import 'package:foss_warn/services/updateProvider.dart';
import 'package:foss_warn/views/DevSettingsView.dart';
import 'package:provider/provider.dart';
import 'package:app_settings/app_settings.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../services/apiHandler.dart';
import 'NotificationSettingsView.dart';
import 'WelcomeView.dart';

import '../services/saveAndLoadSharedPreferences.dart';

import '../widgets/dialogs/FontSizeDialog.dart';
import '../widgets/dialogs/SortByDialog.dart';

bool notificationWithExtreme = true;
bool notificationWithSevere = true;
bool notificationWithModerate = true;
bool notificationWithMinor = false;
bool notificationGeneral = true;
bool showStatusNotification = true;
Map<String, bool> notificationEventsSettings = new Map();

bool showExtendedMetaData = false; // show more tags in WarningDetailView
ThemeMode selectedTheme = ThemeMode.system;
double frequencyOfAPICall = 15;
String dropdownValue = '';
int startScreen = 0;
double warningFontSize = 14;
bool showWelcomeScreen = true;
String sortWarningsBy = "severity";
bool updateAvailable = false;
bool showAllWarnings = false;
bool areWarningsFromCache = false;

String versionNumber = "0.4.6"; // shown in the about view
String githubVersionNumber = versionNumber; // used in the update check
bool gitHubRelease =
    false; // if true, there the check for update Button is shown

bool activateAlertSwiss = false;

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final TextEditingController frequenzTextController =
      new TextEditingController();
  final double maxValueFrequencyOfAPICall = 999;

  @override
  void initState() {
    frequenzTextController.text = frequencyOfAPICall.toInt().toString();
    return super.initState();
  }
  @override
  Widget build(BuildContext context) {
    const double indentOfCategoriesTitles = 15;
    if (startScreen == 0) {
      dropdownValue = AppLocalizations.of(context)!.settings_start_view_all_warnings;
    } else {
      dropdownValue = AppLocalizations.of(context)!.settings_start_view_only_my_places;;
    }

    final Map<ThemeMode, String> themeLabels = {
      ThemeMode.system: AppLocalizations.of(context)!.settings_color_schema_auto,
      ThemeMode.dark: AppLocalizations.of(context)!.settings_color_schema_dark,
      ThemeMode.light: AppLocalizations.of(context)!.settings_color_schema_light
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: indentOfCategoriesTitles, top: indentOfCategoriesTitles),
              child: Text(
                AppLocalizations.of(context)!.settings_notification,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.settings_android_notification_settings),
              onTap: () => AppSettings.openNotificationSettings(),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.settings_app_notification_settings),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationSettingsView()),
                );
              },
            ),
            ListTile(
                title: Text(AppLocalizations.of(context)!.settings_show_status_notification_title),
                subtitle: Text(
                    AppLocalizations.of(context)!.settings_show_status_notification_subtitle),
                trailing: Switch(
                    activeColor: Theme.of(context).colorScheme.secondary,
                    value: showStatusNotification,
                    onChanged: (value) {
                      setState(() {
                        showStatusNotification = value;
                      });
                      saveSettings();
                      if (showStatusNotification == false) {
                        NotificationService.cancelOneNotification(1);
                      }
                    })),
            ListTile(
              title: Text(AppLocalizations.of(context)!.settings_background_servies),
              trailing: Switch(
                  activeColor: Theme.of(context).colorScheme.secondary,
                  value: notificationGeneral,
                  onChanged: (value) {
                    setState(() {
                      notificationGeneral = value;
                    });
                    saveSettings();
                    if (notificationGeneral) {
                      /*BackgroundTaskManager()
                                      .cancelBackgroundTask();
                                  BackgroundTaskManager()
                                      .registerBackgroundTaskWithDelay(); */
                      AlarmManager().cancelBackgroundTask();
                      AlarmManager().registerBackgroundTask();
                    } else {
                      AlarmManager().cancelBackgroundTask();
                      setState(() {
                        notificationWithExtreme = false;
                        notificationWithSevere = false;
                        notificationWithModerate = false;
                        notificationWithMinor = false;
                      });
                      print("background notification disabled");
                    }
                  }),
            ),
            ListTile(
              title: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context)!.settings_frequent_of_background_update),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 70,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: frequenzTextController,
                                onChanged: (value) {
                                  if (value != "") {
                                    if (double.parse(value) > 0 &&
                                        double.parse(value) <=
                                            maxValueFrequencyOfAPICall) {
                                      setState(() {
                                        frequencyOfAPICall =
                                            double.parse(value);
                                      });
                                    } else {
                                      frequenzTextController.text =
                                          frequencyOfAPICall.round().toString();
                                    }
                                  }
                                },
                                onEditingComplete: () {
                                  saveSettings();
                                  AlarmManager().cancelBackgroundTask();
                                  AlarmManager().registerBackgroundTask();
                                  callAPI(); // call api and update notification
                                },
                                decoration: InputDecoration(),
                              ),
                            ),
                            Text("min"),
                            Expanded(
                              child: Slider(
                                value: frequencyOfAPICall,
                                activeColor:
                                    Theme.of(context).colorScheme.secondary,
                                min: 1,
                                max: maxValueFrequencyOfAPICall,
                                onChanged: (value) {
                                  setState(() {
                                    frequencyOfAPICall = value.roundToDouble();
                                    frequenzTextController.text =
                                        frequencyOfAPICall.toInt().toString();
                                  });
                                },
                                onChangeEnd: (value) {
                                  saveSettings();
                                  AlarmManager().cancelBackgroundTask();
                                  AlarmManager().registerBackgroundTask();
                                  callAPI(); // call api and update notification
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 50,
              indent: 15.0,
              endIndent: 15.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: indentOfCategoriesTitles),
              child: Text(
                AppLocalizations.of(context)!.settings_display,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.settings_start_view),
              trailing: DropdownButton<String>(
                value: dropdownValue,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                underline: Container(
                  height: 2,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                    if (dropdownValue == AppLocalizations.of(context)!.settings_start_view_all_warnings) {
                      startScreen = 0;
                    } else if (dropdownValue == AppLocalizations.of(context)!.settings_start_view_only_my_places) {
                      startScreen = 1;
                    }
                  });
                  saveSettings();
                },
                items: <String>[AppLocalizations.of(context)!.settings_start_view_all_warnings,
                  AppLocalizations.of(context)!.settings_start_view_only_my_places]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
                title: Text(AppLocalizations.of(context)!.settings_show_extended_metadata),
                trailing: Switch(
                    activeColor: Theme.of(context).colorScheme.secondary,
                    value: showExtendedMetaData,
                    onChanged: (value) {
                      setState(() {
                        showExtendedMetaData = value;
                      });
                      saveSettings();
                    })),
            ListTile(
              title: Text(AppLocalizations.of(context)!.settings_color_schema),
              trailing: DropdownButton<ThemeMode>(
                value: selectedTheme,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                underline: Container(
                  height: 2,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onChanged: (ThemeMode? newValue) {
                  setState(() {
                    selectedTheme = newValue!;
                  });
                  saveSettings();

                  // Reload the full app for theme changes to reflect
                  final updater = Provider.of<Update>(context, listen: false);
                  updater.updateView();
                },
                items: [ThemeMode.system, ThemeMode.dark, ThemeMode.light]
                    .map<DropdownMenuItem<ThemeMode>>((value) {
                  return DropdownMenuItem<ThemeMode>(
                    value: value,
                    child: Text(themeLabels[value]!),
                  );
                }).toList(),
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.settings_display_all_warnings_title),
              subtitle:
                  Text(AppLocalizations.of(context)!.settings_display_all_warnings_subtitle),
              trailing: Switch(
                  activeColor: Theme.of(context).colorScheme.secondary,
                  value: showAllWarnings,
                  onChanged: (value) {
                    setState(() {
                      showAllWarnings = value;
                    });
                    saveSettings();
                    final updater = Provider.of<Update>(context, listen: false);
                    updater.updateView();
                  }),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.settings_font_size),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FontSizeDialog();
                  },
                );
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.settings_sorting),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SortByDialog();
                  },
                );
              },
            ),
            Divider(
              height: 50,
              indent: 15.0,
              endIndent: 15.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: indentOfCategoriesTitles),
              child: Text(
                AppLocalizations.of(context)!.settings_extended_settings,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.settings_alertSwiss),
              subtitle: Text((AppLocalizations.of(context)!.settings_alertSwiss_subtiltle)),
              trailing: Switch(
                value: activateAlertSwiss,
                onChanged: (value) {
                  setState(() {
                    activateAlertSwiss = value;
                  });
                  saveSettings();
                },
                activeColor: Colors.green,
              ),
            ),
            ListTile(
              title: Text((AppLocalizations.of(context)!.settings_show_welcome_dialog)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WelcomeView(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text((AppLocalizations.of(context)!.settings_dev_settings)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DevSettings()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
