import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_BackgroundTask.dart';
import 'package:foss_warn/services/checkForUpdates.dart';
import 'package:foss_warn/services/updateProvider.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:app_settings/app_settings.dart';

import 'aboutView.dart';
import 'WelcomeView.dart';

import '../services/checkForMyPlacesWarnings.dart';
import '../services/saveAndLoadSharedPreferences.dart';
import '../services/listHandler.dart';
import '../services/urlLauncher.dart';

import '../class/class_Place.dart';

import '../widgets/dialogs/FontSizeDialog.dart';
import '../widgets/dialogs/SortByDialog.dart';
import '../class/class_NotificationService.dart';

bool notificationWithExtreme = true;
bool notificationWithSevere = true;
bool notificationWithModerate = true;
bool notificationWithMinor = false;
bool notificationGeneral = true;
bool showStatusNotification = true;
bool showExtendedMetaData = false; //if ture show more tag in WarningDetailView
bool useDarkMode = false;
double frequencyOfAPICall = 15;
String dropdownValue = '';
int startScreen = 0;
double warningFontSize = 14;
bool showWelcomeScreen = true;
String sortWarningsBy = "source";

String versionNumber = "0.2.2";
String githubVersionNumber = versionNumber;
bool updateAvailable = false;

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
              title: Text("Über FOSS Warn"),
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
              title: Text("Einstellungen öffnen"),
              subtitle:
                  Text("Öffnet die Android-Benachrichtigungs-Einstellungen"),
              onTap: () {
                print("starte Hintergrunddienst neu");
                AppSettings.openNotificationSettings();
              },
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Text("Jetzt Benachrichtigung testen"),
              subtitle:
                  Text("Führt einmalig manuell den Hintergrunddienst aus"),
              onTap: () {
                checkForMyPlacesWarnings();
                bool thereIsNoWarning = true;
                for (Place myPlace in myPlaceList) {
                  //check if there are warning and if it they are important enough
                  if (myPlace.warnings.length > 0 &&
                      myPlace.warnings.any((warning) =>
                          notificationSettingsImportance
                              .contains(warning.severity))) {
                    if (myPlace.warnings.every((warning) =>
                        readWarnings.contains(warning.identifier))) {
                      //all warnings read
                    } else {
                      thereIsNoWarning = false;
                    }
                  } else {}
                }
                if (thereIsNoWarning) {
                  final snackBar = SnackBar(
                    content: const Text(
                      'Es liegen keine neuen Warnungen für Ihre Orte vor',
                      style: TextStyle(color: Colors.black),
                    ),
                    backgroundColor: Colors.green[100],
                  );

                  // Find the ScaffoldMessenger in the widget tree
                  // and use it to show a SnackBar.
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Text("Hintergrunddienst neustarten"),
              subtitle: Text(
                  "Startet den Hintergrunddienst neu. Kann helfen Probleme zu beheben"),
              onTap: () {
                print("starte Hintergrunddienst neu");
                try {
                  //delete all background tasks and create new one
                  Workmanager().cancelAll();
                  Workmanager().registerPeriodicTask("1", "call APIs",
                      /*constraints: Constraints(
                        networkType: NetworkType.connected,
                      ),*/
                      frequency: Duration(minutes: frequencyOfAPICall.toInt()));
                } catch (e) {
                  print("Something went wrong while restart background task: " +
                      e.toString());
                }
                final snackBar = SnackBar(
                  content: const Text(
                    'Hintergrunddienst neugestartet',
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Colors.green[100],
                );

                // Find the ScaffoldMessenger in the widget tree
                // and use it to show a SnackBar.
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Text("Lösche die Liste der gelesenen Warnungen"),
              subtitle: Text(
                  "leer manuell die gespeicherte Liste über die bereits gelesenen Warnungen."),
              onTap: () {
                print("delete readWarningsList");
                readWarnings.clear();
                saveReadWarningsList();
                final snackBar = SnackBar(
                  content: const Text(
                    'Liste gelöscht',
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Colors.green[100],
                );

                // Find the ScaffoldMessenger in the widget tree
                // and use it to show a SnackBar.
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text("Status-Benachrichtigung anzeigen"),
                  ),
                  Switch(
                      value: showStatusNotification,
                      onChanged: (value) {
                        setState(() {
                          showStatusNotification = value;
                          saveSettings();
                        });
                        if (showStatusNotification == false) {
                          NotificationService.cancelOneNotification(1);
                        }
                      })
                ],
              ),
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                        "Hintergrundbenachrichtigungen für hinterlegte Orte"),
                  ),
                  Switch(
                      value: notificationGeneral,
                      onChanged: (value) {
                        setState(() {
                          notificationGeneral = value;
                          saveSettings();
                        });
                        if (notificationGeneral) {
                          BackgroundTaskManager().cancelBackgroundTask();
                          BackgroundTaskManager().registerBackgroundTask();
                        } else {
                          BackgroundTaskManager().cancelBackgroundTask();
                          setState(() {
                            notificationWithExtreme = false;
                            notificationWithSevere = false;
                            notificationWithModerate = false;
                            notificationWithMinor = false;
                          });
                          print("background notification disabled");
                        }
                      })
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Benachrichtigen bei:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("extremen Meldungen"), //severe
                  Switch(
                      value: notificationWithExtreme,
                      onChanged: (value) {
                        if (notificationGeneral) {
                          setState(() {
                            notificationWithExtreme = value;
                            saveNotificationSettingsImportanceList();
                            BackgroundTaskManager().cancelBackgroundTask();
                            BackgroundTaskManager().registerBackgroundTask();
                          });
                        } else {
                          print("Background notification is disabled");
                        }
                        ;
                      })
                ],
              ),
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("schweren Meldungen"), //severe
                  Switch(
                      value: notificationWithSevere,
                      onChanged: (value) {
                        if (notificationGeneral) {
                          setState(() {
                            notificationWithSevere = value;
                            saveNotificationSettingsImportanceList();
                            BackgroundTaskManager().cancelBackgroundTask();
                            BackgroundTaskManager().registerBackgroundTask();
                          });
                        } else {
                          print("Background notification is disabled");
                        }
                        ;
                      })
                ],
              ),
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("moderaten Meldungen"),
                  Switch(
                      value: notificationWithModerate,
                      onChanged: (value) {
                        if (notificationGeneral) {
                          setState(() {
                            notificationWithModerate = value;
                            saveNotificationSettingsImportanceList();
                            BackgroundTaskManager().cancelBackgroundTask();
                            BackgroundTaskManager().registerBackgroundTask();
                          });
                        } else {
                          print("Background notification is disabled");
                        }
                        ;
                      })
                ],
              ),
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("geringfügigen Meldungen"),
                  Switch(
                      value: notificationWithMinor,
                      onChanged: (value) {
                        if (notificationGeneral) {
                          setState(() {
                            notificationWithMinor = value;
                            saveNotificationSettingsImportanceList();
                            BackgroundTaskManager().cancelBackgroundTask();
                            BackgroundTaskManager().registerBackgroundTask();
                            ;
                          });
                        } else {
                          print("Background notification is disabled");
                        }
                      })
                ],
              ),
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
                        Text("Minimalfrequenz der Hintergrunddatenabfrage:"),
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
                                min: 15,
                                max: 300,
                                onChanged: (value) {
                                  setState(() {
                                    frequencyOfAPICall = value.roundToDouble();
                                  });
                                },
                                onChangeEnd: (value) {
                                  saveSettings();
                                  BackgroundTaskManager()
                                      .cancelBackgroundTask();
                                  BackgroundTaskManager()
                                      .registerBackgroundTaskWithDelay();
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
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Startansicht beim Öffnen:"),
                  DropdownButton<String>(
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 24,
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
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
                ],
              ),
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text("Zeige erweiterte Metadaten bei Meldungen.")),
                  Switch(
                      value: showExtendedMetaData,
                      onChanged: (value) {
                        setState(() {
                          showExtendedMetaData = value;
                        });
                        saveSettings();
                      })
                ],
              ),
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text("Nutze dunkles Farbschema")),
                  Switch(
                      value: useDarkMode,
                      onChanged: (value) {
                        setState(() {
                          useDarkMode = value;
                        });
                        saveSettings();
                        final updater =
                            Provider.of<Update>(context, listen: false);
                        updater.updateView();
                      })
                ],
              ),
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Text("Schriftgröße der Meldungen"),
              subtitle:
                  Text("Passe die Schriftgröße der Warnungen an"),
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
              subtitle:
                  Text("Passe die Anzeigereihenfolge der Meldungen an."),
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
              subtitle: Text("Zeigt den Einfühgrungsdialog noch einmal."),
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
            Text(
              "Updates:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              contentPadding: settingsTileListPadding,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text("Prüfe auf Updates")),
                  updateAvailable && versionNumber != githubVersionNumber
                      ? TextButton(
                          onPressed: () {
                            launchUrlInBrowser(
                                'https://github.com/nucleus-ffm/foss_warn/releases/latest');
                          },
                          child: Text(
                            "Update verfügbar",
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
                print("Rückgabewert: $result");
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
            //Text("(können nicht deaktiviert werden)", style: TextStyle(fontSize: 12),),
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
                          "Bundesamt für Bevölkerungsschutz und Katastrophenhilfe - warnt vor Katastrophen",
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
                        Text("Biwapp (Bürger Info- & Warn-App)"),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          "regionales Warn- und Informationssystem vieler Kommunen - warnt z.B. vor: Bombenfund, Chemieunfall, Feuer, Hochwasser, Erdrutsch / Lawine, Großschadenslage, Unwetter, Verkehrsunfall, Unterrichtsausfall und Seuchenfall.  ",
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
                          "Entwickelt von der Fraunhofer-Gesellschaft - warnt z.B. bei: Großbrand, Bombenfund und Umweltkatastrophe",
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
                          "Bundesbehörde - warnt vor Unwettern",
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
