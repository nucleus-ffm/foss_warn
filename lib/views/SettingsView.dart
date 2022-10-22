import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:foss_warn/class/class_BackgroundTask.dart';
import 'package:foss_warn/class/class_NotificationService.dart';
import 'package:foss_warn/class/class_alarmManager.dart';
import 'package:foss_warn/services/updateProvider.dart';
import 'package:foss_warn/views/DevSettingsView.dart';
import 'package:provider/provider.dart';
import 'package:app_settings/app_settings.dart';

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

String versionNumber = "0.4.4"; // shown in the about view
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
  final Map<ThemeMode, String> themeLabels = {
    ThemeMode.system: "Automatisch",
    ThemeMode.dark: "Dunkel",
    ThemeMode.light: "Hell"
  };

  @override
  void initState() {
    frequenzTextController.text = frequencyOfAPICall.toInt().toString();
    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (startScreen == 0) {
      dropdownValue = 'Alle Meldungen';
    } else {
      dropdownValue = "Meine Orte";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Einstellungen"),
        backgroundColor: Colors.green[700],
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Benachrichtigungen",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text("Android-Benachrichtigungseinstellungen öffnen"),
              onTap: () => AppSettings.openNotificationSettings(),
            ),
            ListTile(
              title: Text("App-Benachrichtigungseinstellungen öffnen"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationSettingsView()),
                );
              },
            ),
            ListTile(
                title: Text("Status-Benachrichtigung anzeigen"),
                subtitle: Text(
                    "Zeigt eine Benachrichtung mit der Uhrzeit der letzten Aktualisierung"),
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
              title: Text("Hintergrundabfrage für deine Orte"),
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
            SizedBox(
              height: 10,
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
                        Text("Frequenz der Hintergrundabfrage"),
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
            SizedBox(
              height: 10,
            ),
            Text(
              "Darstellung:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text("Startansicht"),
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
                    if (dropdownValue == "Alle Meldungen") {
                      startScreen = 0;
                    } else if (dropdownValue == "Meine Orte") {
                      startScreen = 1;
                    }
                  });
                  saveSettings();
                },
                items: <String>['Alle Meldungen', 'Meine Orte']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            ListTile(
                title: Text("Erweiterte Metadaten von Meldungen anzeigen"),
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
              title: Text("Farbschema"),
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
              title: Text("Alle verfügbaren Meldungen anzeigen"),
              subtitle:
                  Text("Zeigt alle Meldungen der Warnmeldungsbehörden an"),
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
              title: Text("Schriftgröße der Meldungen"),
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
              title: Text("Sortierung der Meldungen"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SortByDialog();
                  },
                );
              },
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Erweiterte Einstellungen:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text("AlphaSwiss aktivieren (experimentell)"),
              subtitle: Text("Warnmeldungsbehörde für die Schweiz"),
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
              title: Text("Einführung erneut starten"),
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
              title: Text("App-Entwicklereinstellungen öffnen"),
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
