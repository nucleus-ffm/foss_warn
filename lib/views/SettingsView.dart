import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foss_warn/class/class_NotificationService.dart';
import 'package:foss_warn/class/class_alarmManager.dart';
import 'package:foss_warn/services/updateProvider.dart';
import 'package:foss_warn/views/DevSettingsView.dart';
import 'package:provider/provider.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';
import '../services/apiHandler.dart';
import '../services/locationService.dart';
import 'NotificationSettingsView.dart';
import 'WelcomeView.dart';

import '../services/saveAndLoadSharedPreferences.dart';

import '../widgets/dialogs/FontSizeDialog.dart';
import '../widgets/dialogs/SortByDialog.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final TextEditingController frequenzTextController =
      new TextEditingController();
  final double _maxValueFrequencyOfAPICall = 999;
  final _platform = const MethodChannel("flutter.native/helper");

  @override
  void initState() {
    frequenzTextController.text = userPreferences.frequencyOfAPICall.toInt().toString();

    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const double indentOfCategoriesTitles = 15;

    final Map<int, String> startViewLabels = {
      0:  AppLocalizations.of(context).settings_start_view_all_warnings,
      1:  AppLocalizations.of(context).settings_start_view_only_my_places,
    };


    final Map<ThemeMode, String> themeLabels = {
      ThemeMode.system: AppLocalizations.of(context).settings_color_schema_auto,
      ThemeMode.dark: AppLocalizations.of(context).settings_color_schema_dark,
      ThemeMode.light: AppLocalizations.of(context).settings_color_schema_light
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings),
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
              padding: EdgeInsets.only(
                  left: indentOfCategoriesTitles,
                  top: indentOfCategoriesTitles),
              child: Text(
                AppLocalizations.of(context).settings_notification,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)
                  .settings_android_notification_settings),
              onTap: () => _openNotificationSettings(),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)
                  .settings_app_notification_settings),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationSettingsView()),
                );
              },
            ),
            ListTile(
                title: Text(AppLocalizations.of(context)
                    .settings_show_status_notification_title),
                subtitle: Text(AppLocalizations.of(context)
                    .settings_show_status_notification_subtitle),
                trailing: Switch(
                    activeColor: Theme.of(context).colorScheme.secondary,
                    value: userPreferences.showStatusNotification,
                    onChanged: (value) {
                      setState(() {
                        userPreferences.showStatusNotification = value;
                      });
                      saveSettings();
                      if (userPreferences.showStatusNotification == false) {
                        NotificationService.cancelOneNotification(1);
                      }
                    })),
            ListTile(
              title: Text(
                  AppLocalizations.of(context).settings_background_service),
              trailing: Switch(
                  activeColor: Theme.of(context).colorScheme.secondary,
                  value: userPreferences.shouldNotifyGeneral,
                  onChanged: (value) {
                    setState(() {
                      userPreferences.shouldNotifyGeneral = value;
                    });
                    saveSettings();
                    if (userPreferences.shouldNotifyGeneral) {
                      AlarmManager().cancelBackgroundTask();
                      AlarmManager().registerBackgroundTask();
                    } else {
                      AlarmManager().cancelBackgroundTask();
                      setState(() {
                        userPreferences.notificationWithExtreme = false;
                        userPreferences.notificationWithSevere = false;
                        userPreferences.notificationWithModerate = false;
                        userPreferences.notificationWithMinor = false;
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
                        Text(AppLocalizations.of(context)
                            .settings_frequent_of_background_update),
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
                                            _maxValueFrequencyOfAPICall) {
                                      setState(() {
                                        userPreferences.frequencyOfAPICall =
                                            double.parse(value);
                                      });
                                    } else {
                                      frequenzTextController.text =
                                          userPreferences.frequencyOfAPICall.round().toString();
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
                                value: userPreferences.frequencyOfAPICall,
                                activeColor:
                                    Theme.of(context).colorScheme.secondary,
                                min: 1,
                                max: _maxValueFrequencyOfAPICall,
                                onChanged: (value) {
                                  setState(() {
                                    userPreferences.frequencyOfAPICall = value.roundToDouble();
                                    frequenzTextController.text =
                                        userPreferences.frequencyOfAPICall.toInt().toString();
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
                AppLocalizations.of(context).settings_display,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context).settings_start_view),
              trailing: DropdownButton<int>(
                value: userPreferences.startScreen,
                icon: const Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                underline: Container(
                  height: 2,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onChanged: (int? newValue) {
                  setState(() {
                    userPreferences.startScreen = newValue!;
                  });
                  saveSettings();
                },
                items: [0, 1]
                    .map<DropdownMenuItem<int>>((value) {
                  return DropdownMenuItem<int>(

                    value: value,
                    child: Text(startViewLabels[value]!),
                  );
                }).toList(),
              ),
            ),
            ListTile(
                title: Text(AppLocalizations.of(context)
                    .settings_show_extended_metadata),
                trailing: Switch(
                    activeColor: Theme.of(context).colorScheme.secondary,
                    value: userPreferences.showExtendedMetaData,
                    onChanged: (value) {
                      setState(() {
                        userPreferences.showExtendedMetaData = value;
                      });
                      saveSettings();
                    })),
            ListTile(
              title: Text(AppLocalizations.of(context).settings_color_schema),
              trailing: DropdownButton<ThemeMode>(
                value: userPreferences.selectedTheme,
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
                    userPreferences.selectedTheme = newValue!;
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
              title: Text(AppLocalizations.of(context)
                  .settings_display_all_warnings_title),
              subtitle: Text(AppLocalizations.of(context)
                  .settings_display_all_warnings_subtitle),
              trailing: Switch(
                  activeColor: Theme.of(context).colorScheme.secondary,
                  value: userPreferences.showAllWarnings,
                  onChanged: (value) {
                    setState(() {
                      userPreferences.showAllWarnings = value;
                    });
                    saveSettings();
                    final updater = Provider.of<Update>(context, listen: false);
                    updater.updateView();
                  }),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context).settings_font_size),
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
              title: Text(AppLocalizations.of(context).settings_sorting),
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
                AppLocalizations.of(context).settings_extended_settings,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context).settings_alertSwiss),
              subtitle: Text(
                  (AppLocalizations.of(context).settings_alertSwiss_subtitle)),
              trailing: Switch(
                value: userPreferences.activateAlertSwiss,
                onChanged: (value) {
                  setState(() {
                    userPreferences.activateAlertSwiss = value;
                  });
                  saveSettings();
                },
                activeColor: Colors.green,
              ),
            ),
            ListTile(
              title: Text(
                  (AppLocalizations.of(context).settings_show_welcome_dialog)),
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
              title: Text((AppLocalizations.of(context).settings_dev_settings)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DevSettings()),
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
                "Location Settings", //@todo translate
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            ListTile(
              title: Text("Warnungen für die aktuelle Position erhalten (Experimentell)"),
              subtitle: Text("Nutzt alle 90 Min. GPS Informationen und berechnet daraus"
                  " den nächstgelegenen Ort. Für diesen Ort erhalten sie dann Warnungen."),
              trailing: Switch(
                value: userPreferences.warningsForCurrentLocation,
                onChanged: (value) async {
                  // check permission and enable feature when value is true
                  if(value) {
                    bool permissionCheck = await checkLocationPermission(context);
                    // do not active setting, when FOSS Warn does
                    // not have the right permission
                    if(permissionCheck) {
                      setState(() {
                        userPreferences.warningsForCurrentLocation = value;
                      });
                      AlarmManager().registerLocationBackgroundTask();
                      saveSettings();
                    }
                  } else {
                    setState(() {
                      userPreferences.warningsForCurrentLocation = value;
                    });
                    // cancel location background task (ID: 2)
                    AlarmManager().cancelLocationBackgroundTask();
                  }
                  saveSettings();
                },
                activeColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openNotificationSettings() async {
    try {
      await _platform.invokeMethod("openNotificationSettings");
    } on PlatformException catch (e) {
      print(e);
    }
  }
}
