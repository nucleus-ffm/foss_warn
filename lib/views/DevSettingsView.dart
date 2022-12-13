import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foss_warn/class/class_Place.dart';
import 'package:foss_warn/services/checkForMyPlacesWarnings.dart';
import 'package:foss_warn/services/listHandler.dart';
import 'package:foss_warn/services/saveAndLoadSharedPreferences.dart';

import '../class/class_alarmManager.dart';
import '../services/alertSwiss.dart';
import '../services/geocodeHandler.dart';
import '../widgets/dialogs/systemInformationDialog.dart';


class DevSettings extends StatefulWidget {
  const DevSettings({Key? key}) : super(key: key);

  @override
  _DevSettingsState createState() => _DevSettingsState();
}

class _DevSettingsState extends State<DevSettings> {
  final EdgeInsets settingsTileListPadding = EdgeInsets.fromLTRB(25, 2, 25, 2);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Erweiterte Einstellungen"),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        systemOverlayStyle:
        SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      ),
      body: SingleChildScrollView(
          child: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 20),
          child: Column(
            children: [
              ListTile(
                contentPadding: settingsTileListPadding,
                title: Text("Jetzt Benachrichtigung testen"),
                subtitle:
                Text("Führt einmalig manuell den Hintergrunddienst aus"),
                onTap: () {
                  checkForMyPlacesWarnings(false, true);
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
                    AlarmManager().cancelBackgroundTask();
                    AlarmManager().registerBackgroundTask();
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
                title: Text("Lösche Benachrichtigungsliste"),
                subtitle: Text(
                    "löscht die Liste über die bereits benachrichtigen Meldungen"),
                onTap: () {
                  print("delete alreadyNotifiedWarnings");
                  alreadyNotifiedWarnings.clear();
                  saveAlreadyNotifiedWarningsList();
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
                title: Text("call swiss Alert API"),
                subtitle: Text(
                    "führt einmal die Methode aus und fügt die Meldungen hinzu"),
                onTap: () {
                  print("call swiss API");
                  callAlertSwissAPI();
                  final snackBar = SnackBar(
                    content: const Text(
                      'called',
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
                title: Text("load cached warnings"),
                subtitle: Text(
                    "läd die zwischengespeicherten Meldungen"),
                onTap: () {
                  print("load cached warnings");
                  loadCachedWarnings();
                  final snackBar = SnackBar(
                    content: const Text(
                      'called',
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
                title: Text("test geocode"),
                subtitle: Text(
                    "Lädt die geocodes für die Liste"),
                onTap: () {
                  print("call geocodeHandler");
                  geocodeHandler();
                  final snackBar = SnackBar(
                    content: const Text(
                      'called',
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
                title: Text("lösche Warnungen"),
                subtitle: Text(
                    "Leer die Liste mit den Warnungen"),
                onTap: () {
                  print("lösche Warnungen");
                  warnMessageList.clear();
                  final snackBar = SnackBar(
                    content: const Text(
                      'called',
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
                title: Text("Systeminformationen für Fehlerbehebung sammeln"),
                subtitle: Text(
                    "Stellt Informationen zum System zusammen, "
                        "die zwecks Fehlerbehandlung an den Entwickler "
                        "geschickt werden können. Es wird nichts verwendet."),
                onTap: () {
                  print("Systeminformationen sammeln");
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SystemInformationDialog();
                    },
                  );

                  final snackBar = SnackBar(
                    content: const Text(
                      'collect systeminfo',
                      style: TextStyle(color: Colors.black),
                    ),
                    backgroundColor: Colors.green[100],
                  );

                  // Find the ScaffoldMessenger in the widget tree
                  // and use it to show a SnackBar.
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
            ],



          ))
      ),
    );
  }
}
