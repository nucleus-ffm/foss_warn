import 'dart:io';

import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'services/CheckForMyPlacesWarnings.dart';
import 'services/saveAndLoadSharedPreferences.dart';
import 'services/listHandler.dart';
import 'class/class_Place.dart';
import 'aboutView.dart';

bool notificationWithExtreme = true;
bool notificationWithSevere = true;
bool notificationWithModerate = true;
bool notificationWithMinor = false;
bool notificationGeneral = true;
double frequencyOfAPICall = 15;
String dropdownValue = '';
int startScreen = 0;

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  @override
  Widget build(BuildContext context) {
    if(startScreen == 0) {
      dropdownValue = 'Alle Meldungen';
    } else {
      dropdownValue = "Meine Orte";
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ListTile(
              title: Text("Über diese App"),
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
              title: Text("Jetzt Benachrichtigung testen"),
              onTap: () {
                checkForWarnings();
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
              title: Text("Hintergrunddienst neustarten"),
              onTap: () {
                print("starte Hintergrunddienst neu");
                try {
                  //delete all background tasks and create new one
                  Workmanager().cancelAll();
                  Workmanager().registerPeriodicTask("1", "call APIs",
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
              title: Text("Lösche die Liste der gelesenen Warnungen"),
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
                          Workmanager().cancelAll();
                          Workmanager().registerPeriodicTask(
                            "1",
                            "call APIs",
                            frequency: Duration(minutes: 15),
                          );
                        } else {
                          Workmanager().cancelAll();
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
                            Workmanager().cancelAll();
                            Workmanager().registerPeriodicTask("1", "call APIs",
                                frequency: Duration(minutes: 15));
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
                            Workmanager().cancelAll();
                            Workmanager().registerPeriodicTask("1", "call APIs",
                                frequency: Duration(minutes: 15));
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
                            Workmanager().cancelAll();
                            Workmanager().registerPeriodicTask("1", "call APIs",
                                frequency: Duration(minutes: 15));
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
                            Workmanager().cancelAll();
                            Workmanager().registerPeriodicTask("1", "call APIs",
                                frequency: Duration(minutes: 15));
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
                                min: 15,
                                max: 300,
                                onChanged: (value) {
                                  setState(() {
                                    frequencyOfAPICall = value.roundToDouble();
                                  });
                                },
                                onChangeEnd: (value) {
                                  saveFrequencyOfAPICall();
                                  Workmanager().cancelAll();
                                  Workmanager().registerPeriodicTask(
                                      "1", "call APIs",
                                      frequency: Duration(
                                          minutes: frequencyOfAPICall.toInt()),
                                      initialDelay: Duration(
                                          minutes: frequencyOfAPICall.toInt()));
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
              "Sonstige Einstellungen:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
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
                        if(dropdownValue== "Alle Meldungen") {
                          startScreen = 0;
                        } else if(dropdownValue == "Meine Orte") {
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
                          "regionales Warn- und Informationssystem vieler Kommunen - warnt u.a. vor: Bombenfund, Chemieunfall, Feuer, Hochwasser, Erdrutsch / Lawine, Großschadenslage, Unwetter, Verkehrsunfall, Unterrichtsausfall und Seuchenfall.  ",
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
                          "Entwickelt von der Fraunhofer-Gesellschaft - Warnugen z.B. bei Großbrand, Bombenfund, Umweltkatastrophe",
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
                          "Bundesbehörde - warnt z.B. vor Unwettern",
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
            /*ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("DWD API - Warnungen Küste"),
                  Switch(value: false, onChanged: (value) {})
                ],
              ),
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("DWD API - Warnungen Küste"),
                  Switch(value: false, onChanged: (value) {})
                ],
              ),
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("DWD API - Warnungen Meer"),
                  Switch(value: false, onChanged: (value) {})
                ],
              ),
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("DWD API - Warnungen Larwinen"),
                  Switch(value: false, onChanged: (value) {})
                ],
              ),
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("DWD API - Warnungen Sturmflut"),
                  Switch(value: false, onChanged: (value) {})
                ],
              ),
            ),*/
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
