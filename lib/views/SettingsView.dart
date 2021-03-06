import 'package:flutter/material.dart';
//import 'package:foss_warn/class/class_BackgroundTask.dart';
import 'package:foss_warn/class/class_NotificationService.dart';
import 'package:foss_warn/class/class_alarmManager.dart';
import 'package:foss_warn/services/checkForUpdates.dart';
import 'package:foss_warn/services/updateProvider.dart';
import 'package:foss_warn/views/DevSettingsView.dart';
import 'package:provider/provider.dart';
import 'package:app_settings/app_settings.dart';

import 'aboutView.dart';
import 'NotificationSettingsView.dart';
import 'WelcomeView.dart';

import '../services/saveAndLoadSharedPreferences.dart';
import '../services/urlLauncher.dart';

import '../widgets/dialogs/FontSizeDialog.dart';
import '../widgets/dialogs/SortByDialog.dart';

bool notificationWithExtreme = true;
bool notificationWithSevere = true;
bool notificationWithModerate = true;
bool notificationWithMinor = false;
bool notificationGeneral = true;
bool showStatusNotification = true;
Map<String, bool> notificationEventsSettings  = new Map();

bool showExtendedMetaData = false; //if ture show more tag in WarningDetailView
bool useDarkMode = false;
double frequencyOfAPICall = 15;
String dropdownValue = '';
int startScreen = 0;
double warningFontSize = 14;
bool showWelcomeScreen = true;
String sortWarningsBy = "severity";
bool updateAvailable = false;
bool showAllWarnings = false;

String versionNumber = "0.3.0"; // shown in the about view
String githubVersionNumber = versionNumber; // used in the update check
bool gitHubRelease =
    false; // if true, there the check for update Button is shown

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final EdgeInsets settingsTileListPadding = EdgeInsets.fromLTRB(25, 2, 25, 2);

  @override
  Widget build(BuildContext context) {
    if (startScreen == 0) {
      dropdownValue = 'Alle Meldungen';
    } else {
      dropdownValue = "Meine Orte";
    }

    return SingleChildScrollView(
      //padding: const EdgeInsets.fromLTRB(20, 20, 20, 1),
      child: Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(25, 25, 20, 25),
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/app_icon.png'),
                radius: 30,
              ),
              title: Text("??ber FOSS Warn"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutView()),
                );
              },
            ),
            Text(
              "Benachrichtigungen",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Text("Einstellungen ??ffnen"),
              subtitle:
                  Text("??ffnet die Android-Benachrichtigungs-Einstellungen"),
              onTap: () {
                AppSettings.openNotificationSettings();
              },
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Text("Benachrichtigungseinstellungen"),
              subtitle:
              Text("??ffnet die Einstellungen f??r was eine Benachrichtigung"
                  " gesendet werden soll"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationSettingsView()),
                );
              },
            ),

            ListTile(
                contentPadding: settingsTileListPadding,
                title: Text("Status-Benachrichtigung anzeigen"),
                subtitle: Text(
                    "Zeigt eine Benachrichtung mit der Uhrzeit der letzten Aktualisieurng"),
                trailing: Switch(
                  activeColor: Theme.of(context).colorScheme.secondary,
                    value: showStatusNotification,
                    onChanged: (value) {
                      setState(() {
                        showStatusNotification = value;
                        saveSettings();
                      });
                      if (showStatusNotification == false) {
                        NotificationService.cancelOneNotification(1);
                      }
                    }
                    )
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Text("Hintergrundbenachrichtigungen f??r hinterlegte Orte"),
              subtitle: Text("Wenn eingeschaltet pr??ft FOSS Warn"
                  " im Hintergrund ob es Warnungen f??r hinterlegte Orte gibt."),
              trailing: Switch(
                  activeColor: Theme.of(context).colorScheme.secondary,
                  value: notificationGeneral,
                  onChanged: (value) {
                    setState(() {
                      notificationGeneral = value;
                      saveSettings();
                    });
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
              contentPadding: settingsTileListPadding,
              title: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Frequenz der Hintergrunddatenabfrage:"),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 70,
                              child: Text(
                                  frequencyOfAPICall.toInt().toString() +
                                      " min"),
                            ),
                            Expanded(
                              child: Slider(
                                value: frequencyOfAPICall,
                                activeColor:
                                    Theme.of(context).colorScheme.secondary,
                                min: 1,
                                max: 800,
                                onChanged: (value) {
                                  setState(() {
                                    frequencyOfAPICall = value.roundToDouble();
                                  });
                                },
                                onChangeEnd: (value) {
                                  saveSettings();
                                  /*BackgroundTaskManager()
                                      .cancelBackgroundTask();
                                  BackgroundTaskManager()
                                      .registerBackgroundTaskWithDelay(); */
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
              contentPadding: settingsTileListPadding,
              title: Text("Startansicht beim ??ffnen:"),
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
                    saveSettings();
                  });
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
                contentPadding: settingsTileListPadding,
                title: Text("Zeige erweiterte Metadaten bei Meldungen"),
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
              contentPadding: settingsTileListPadding,
              title: Text("Nutze dunkles Farbschema"),
              trailing: Switch(
                  activeColor: Theme.of(context).colorScheme.secondary,
                  value: useDarkMode,
                  onChanged: (value) {
                    setState(() {
                      useDarkMode = value;
                    });
                    saveSettings();
                    final updater = Provider.of<Update>(context, listen: false);
                    updater.updateView();
                  }),
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Text("Zeige alle Meldungen an"),
              subtitle: Text(
                  "Wenn aktiviert werden in der Ansicht 'Alle Meldungen' nicht nur die Meldungen f??r Deine Orte"
                      " angezeigt, sondern alle verf??gbaren Meldungen aus"
                      " ganz Deutschland."),
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
              contentPadding: settingsTileListPadding,
              title: Text("Schriftgr????e der Meldungen"),
              subtitle: Text("Passe die Schriftgr????e der Warnungen an"),
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
              contentPadding: settingsTileListPadding,
              title: Text("Sortierung der Meldungen"),
              subtitle: Text("Passe die Anzeigereihenfolge der Meldungen an"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SortByDialog();
                  },
                );
              },
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Text("Zeige das Intro nochmal"),
              subtitle: Text("Zeigt den Einf??hgrungsdialog noch einmal"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WelcomeView(),
                  ),
                );
              },
            ),
            SizedBox(
              height: 10,
            ),
            gitHubRelease
                ? Text(
                    "Updates:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                : SizedBox(),
            gitHubRelease
                ? ListTile(
                    contentPadding: settingsTileListPadding,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text("Pr??fe auf Updates")),
                        updateAvailable && versionNumber != githubVersionNumber
                            ? TextButton(
                                onPressed: () {
                                  launchUrlInBrowser(
                                      'https://github.com/nucleus-ffm/foss_warn/releases/latest');
                                },
                                child: Text(
                                  "Update verf??gbar",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.blue),
                              )
                            : SizedBox(),
                      ],
                    ),
                    onTap: () async {
                      String result = await checkForUpdates();
                      print("R??ckgabewert: $result");
                      if (result != "latest version installed" &&
                          result != "something else" &&
                          result != "Error - server not reachable") {
                        setState(() {
                          updateAvailable = true;
                          saveSettings();
                        });
                      } else {
                        setState(() {
                          updateAvailable = false;
                          saveSettings();
                        });
                        if (result == "Error - server not reachable") {
                          final snackBar = SnackBar(
                            content: const Text(
                              'Server nicht erreichbar',
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor: Colors.red[100],
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else {
                          final snackBar = SnackBar(
                            content: const Text(
                              'neuste Version installiert',
                              style: TextStyle(color: Colors.black),
                            ),
                            backgroundColor: Colors.green[100],
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      }
                    },
                  )
                : SizedBox(),
            Text(
              "Erweiterte Einstellungen:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Text("??ffne erweiterte Einstellungen"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DevSettings()),
                );
              },
            ),

            SizedBox(
              height: 15,
            ),
            Text(
              "Quellen der Warnmeldungen:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 1,
            ),
            //Text("(k??nnen nicht deaktiviert werden)", style: TextStyle(fontSize: 12),),
            SizedBox(
              height: 5,
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Mowas (Modulares Warnsystem)"),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          "Bundesamt f??r Bev??lkerungsschutz und Katastrophenhilfe - warnt vor Katastrophen",
                          style: TextStyle(
                              fontSize: 12, fontStyle: FontStyle.italic),
                        )
                      ],
                    ),
                  ),
                  //Switch(value: true, onChanged: null,)
                ],
              ),
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Biwapp (B??rger Info- & Warn-App)"),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          "regionales Warn- und Informationssystem vieler Kommunen - warnt z.B. vor: Bombenfund, Chemieunfall, Feuer, Hochwasser, Erdrutsch / Lawine, Gro??schadenslage, Unwetter, Verkehrsunfall, Unterrichtsausfall und Seuchenfall.  ",
                          style: TextStyle(
                              fontSize: 12, fontStyle: FontStyle.italic),
                        )
                      ],
                    ),
                  ),
                  //Switch(value: true, onChanged: null, )
                ],
              ),
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Katwarn "),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          "Entwickelt von der Fraunhofer-Gesellschaft - warnt z.B. bei: Gro??brand, Bombenfund und Umweltkatastrophe",
                          style: TextStyle(
                              fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  //Switch(value: true, onChanged: null),
                ],
              ),
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("DWD (Deutscher Wetterdienst)"),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          "Bundesbeh??rde - warnt vor Unwettern",
                          style: TextStyle(
                              fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  //Switch(value: true, onChanged: null, activeColor: Colors.green,),
                ],
              ),
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("LHP (L??nder??bergreifendes Hochwasser Portal)"),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          "Eine gemeinsame Initiative der deutschen Bundesl??nder "
                          "- warnt vor Hochwasserwasser",
                          style: TextStyle(
                              fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  //Switch(value: true, onChanged: null, activeColor: Colors.green,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
