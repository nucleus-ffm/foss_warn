import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/services/save_and_load_shared_preferences.dart';

import '../class/class_alarm_manager.dart';
import '../class/abstract_place.dart';
import '../main.dart';
import '../services/check_for_my_places_warnings.dart';
import '../services/list_handler.dart';
import '../services/alert_swiss.dart';
import '../services/geocode_handler.dart';
import '../widgets/dialogs/error_dialog.dart';
import '../widgets/dialogs/system_information_dialog.dart';
import 'log_file_viewer.dart';

class DevSettings extends StatefulWidget {
  const DevSettings({super.key});

  @override
  State<DevSettings> createState() => _DevSettingsState();
}

class _DevSettingsState extends State<DevSettings> {
  final EdgeInsets _settingsTileListPadding = EdgeInsets.fromLTRB(25, 2, 25, 2);
  final TextEditingController maxSizeOfSubscriptionBoundingBox =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    maxSizeOfSubscriptionBoundingBox.dispose();
  }

  @override
  void initState() {
    maxSizeOfSubscriptionBoundingBox.text =
        userPreferences.maxSizeOfSubscriptionBoundingBox.toString();
    return super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.dev_settings_headline),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 20),
          child: Column(
            children: [
              ListTile(
                contentPadding: _settingsTileListPadding,
                title: Text(AppLocalizations.of(context)!
                    .dev_settings_test_notification),
                subtitle: Text(AppLocalizations.of(context)!
                    .dev_settings_test_notification_text),
                onTap: () {
                  checkForMyPlacesWarnings(true);
                  bool thereIsNoWarning = true;
                  for (Place myPlace in myPlaceList) {
                    //check if there are warning and if it they are important enough
                    thereIsNoWarning =
                        !(myPlace.checkIfThereIsAWarningToNotify());
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
                contentPadding: _settingsTileListPadding,
                title: Text(AppLocalizations.of(context)!
                    .dev_settings_restart_background_service),
                subtitle: Text(AppLocalizations.of(context)!
                    .dev_settings_restart_background_service_text),
                onTap: () {
                  debugPrint("restart background service");
                  try {
                    //delete all background tasks and create new one
                    AlarmManager().cancelBackgroundTask();
                    AlarmManager().registerBackgroundTask();
                  } catch (e) {
                    debugPrint(
                        "Something went wrong while restart background task: $e");
                  }
                  final snackBar = SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.dev_settings_success,
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
                contentPadding: _settingsTileListPadding,
                title: Text(
                    "${AppLocalizations.of(context)!.dev_settings_delete_list_of_read_warnings} & \n${AppLocalizations.of(context)!.dev_settings_delete_notification_list}"),
                subtitle: Text(
                    "${AppLocalizations.of(context)!.dev_settings_delete_list_of_read_warnings_text} & \n${AppLocalizations.of(context)!.dev_settings_delete_notification_list_text}"),
                onTap: () {
                  debugPrint(
                      "reset read and notification status for all warnings");
                  for (Place p in myPlaceList) {
                    p.resetReadAndNotificationStatusForAllWarnings(context);
                  }
                  final snackBar = SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.dev_settings_success,
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
                contentPadding: _settingsTileListPadding,
                title: Text(AppLocalizations.of(context)!
                    .dev_settings_call_alert_swiss),
                subtitle: Text(AppLocalizations.of(context)!
                    .dev_settings_call_alert_swiss_text),
                onTap: () {
                  debugPrint("call swiss API");
                  callAlertSwissAPI();
                  final snackBar = SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.dev_settings_success,
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
                contentPadding: _settingsTileListPadding,
                title: Text(
                    AppLocalizations.of(context)!.dev_settings_test_geocode),
                subtitle: Text(AppLocalizations.of(context)!
                    .dev_settings_test_geocode_text),
                onTap: () {
                  debugPrint("call geocodeHandler");
                  geocodeHandler();
                  final snackBar = SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.dev_settings_success,
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
                contentPadding: _settingsTileListPadding,
                title: Text(
                    AppLocalizations.of(context)!.dev_settings_delete_warnings),
                subtitle: Text(AppLocalizations.of(context)!
                    .dev_settings_delete_warnings_text),
                onTap: () {
                  for (Place p in myPlaceList) {
                    p.warnings.clear();
                  }
                  saveMyPlacesList();
                  final snackBar = SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.dev_settings_success,
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
                contentPadding: _settingsTileListPadding,
                title: Text("Systeminformationen zur Fehlerbehebung sammeln"),
                subtitle: Text(
                    "Stellt Informationen zum System zusammen, die zwecks Fehlerbehandlung an den Entwickler geschickt werden kann. Es werden keine Daten versendet."),
                onTap: () {
                  debugPrint("Systeminformationen sammeln");
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        SystemInformationDialog(),
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
              ListTile(
                contentPadding: _settingsTileListPadding,
                title: Text("Zeige Fehlermeldungen an"),
                subtitle: Text("Zeigt einen Dialog zu Fehlermeldungen an"),
                onTap: () {
                  debugPrint("Lade Fehlermeldungen");
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => ErrorDialog(),
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
              ListTile(
                contentPadding: _settingsTileListPadding,
                title: Text("Übersicht über Fehlermeldungen"),
                subtitle:
                    Text("Führt zu einer Seite mit den Fehlermeldungen an"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LogFileViewer()),
                  );
                },
              ),
              ListTile(
                contentPadding: _settingsTileListPadding,
                title: Text("Max size of bounding box for a subscription"),
                subtitle: Text(
                    "select the max size of bounding box for a subscription"),
                trailing: SizedBox(
                  width: 100,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    controller: maxSizeOfSubscriptionBoundingBox,
                    onChanged: (value) {
                      if (value != "") {
                        if (double.parse(value) > 1) {
                          setState(() {
                            userPreferences.maxSizeOfSubscriptionBoundingBox =
                                int.parse(value);
                          });
                        }
                      }
                    },
                    onTapOutside: (e) {
                      // Check whether the text field is in focus,
                      // because this method is executed every time
                      // you tap somewhere in the settings, even
                      // if the text field is not in focus at all
                      if (FocusScope.of(context).isFirstFocus) {
                        FocusScope.of(context).unfocus();
                        saveSettings();
                      }
                    },
                    onEditingComplete: () {
                      FocusScope.of(context).unfocus();
                      saveSettings();
                    },
                    decoration: InputDecoration(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}