import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/services/checkForMyPlacesWarnings.dart';
import 'package:foss_warn/services/listHandler.dart';
import 'package:foss_warn/services/saveAndLoadSharedPreferences.dart';

import '../class/class_alarmManager.dart';
import '../class/abstract_Place.dart';
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
        title: Text(AppLocalizations.of(context).dev_settings_headline),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
      ),
      body: SingleChildScrollView(
        child: Padding (
          padding: const EdgeInsets.only(top: 0, bottom: 20),
          child: Column(
            children: [
              ListTile(
                contentPadding: settingsTileListPadding,
                title: Text(AppLocalizations.of(context)
                    .dev_settings_test_notification),
                subtitle: Text(AppLocalizations.of(context)
                    .dev_settings_test_notification_text),
                onTap: () {
                  checkForMyPlacesWarnings(false, true);
                  bool thereIsNoWarning = true;
                  for (Place myPlace in myPlaceList) {
                    //check if there are warning and if it they are important enough
                    thereIsNoWarning = myPlace.checkIfThereIsAWarningToNotify();
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
                title: Text(AppLocalizations.of(context)
                    .dev_settings_restart_background_service),
                subtitle: Text(AppLocalizations.of(context)
                    .dev_settings_restart_background_service_text),
                onTap: () {
                  print("restart background service");
                  try {
                    //delete all background tasks and create new one
                    AlarmManager().cancelBackgroundTask();
                    AlarmManager().registerBackgroundTask();
                  } catch (e) {
                    print(
                        "Something went wrong while restart background task: " +
                            e.toString());
                  }
                  final snackBar = SnackBar(
                    content: Text(
                      AppLocalizations.of(context).dev_settings_success,
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
                title: Text(AppLocalizations.of(context)
                    .dev_settings_delete_list_of_read_warnings + " & \n" +
                    AppLocalizations.of(context)
                    .dev_settings_delete_notification_list),
                subtitle: Text(AppLocalizations.of(context)
                    .dev_settings_delete_list_of_read_warnings_text + " & \n"
                    + AppLocalizations.of(context)
                    .dev_settings_delete_notification_list_text),
                onTap: () {
                  print("reset read and notification status for all warnings");
                  for(Place p in myPlaceList) {
                    p.resetReadAndNotificationStatusForAllWarnings(context);
                  }
                  final snackBar = SnackBar(
                    content: Text(
                      AppLocalizations.of(context).dev_settings_success,
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
                title: Text(
                    AppLocalizations.of(context).dev_settings_call_alert_swiss),
                subtitle: Text(AppLocalizations.of(context)
                    .dev_settings_call_alert_swiss_text),
                onTap: () {
                  print("call swiss API");
                  callAlertSwissAPI();
                  final snackBar = SnackBar(
                    content: Text(
                      AppLocalizations.of(context).dev_settings_success,
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
                title: Text(AppLocalizations.of(context)
                    .dev_settings_load_cached_warnings),
                subtitle: Text(AppLocalizations.of(context)
                    .dev_settings_load_cached_warnings_text),
                onTap: () {
                  print("load cached warnings");
                  loadCachedWarnings();
                  final snackBar = SnackBar(
                    content: Text(
                      AppLocalizations.of(context).dev_settings_success,
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
                title: Text(
                    AppLocalizations.of(context).dev_settings_test_geocode),
                subtitle: Text(AppLocalizations.of(context)
                    .dev_settings_test_geocode_text),
                onTap: () {
                  print("call geocodeHandler");
                  geocodeHandler();
                  final snackBar = SnackBar(
                    content: Text(
                      AppLocalizations.of(context).dev_settings_success,
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
                title: Text(
                    AppLocalizations.of(context).dev_settings_delete_warnings),
                subtitle: Text(AppLocalizations.of(context)
                    .dev_settings_delete_warnings_text),
                onTap: () {
                  print("delete warnings");
                  warnMessageList.clear();
                  final snackBar = SnackBar(
                    content: Text(
                      AppLocalizations.of(context).dev_settings_success,
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
                    title:
                        Text("Systeminformationen zur Fehlerbehebung sammeln"),
                    subtitle: Text(
                        "Stellt Informationen zum System zusammen, die zwecks Fehlerbehandlung an den Entwickler geschickt werden kann. Es werden keine Daten versendet."),
                    onTap: () {
                      print("Systeminformationen sammeln");
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => SystemInformationDialog(),
                      );

                      final snackBar = SnackBar(
                        content: const Text(
                          "Collecting system information...",
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
          ),
        ),
      ),

    );
  }
}
