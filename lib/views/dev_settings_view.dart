import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foss_warn/class/class_fpas_place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/services/alert_api/fpas.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/services/save_and_load_shared_preferences.dart';

import '../main.dart';
import '../services/check_for_my_places_warnings.dart';
import '../services/list_handler.dart';
import '../widgets/dialogs/error_dialog.dart';
import '../widgets/dialogs/system_information_dialog.dart';
import 'log_file_viewer.dart';

class DevSettings extends ConsumerStatefulWidget {
  const DevSettings({super.key});

  @override
  ConsumerState<DevSettings> createState() => _DevSettingsState();
}

class _DevSettingsState extends ConsumerState<DevSettings> {
  final EdgeInsets _settingsTileListPadding =
      const EdgeInsets.fromLTRB(25, 2, 25, 2);
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
    var localizations = context.localizations;
    var theme = Theme.of(context);
    var scaffoldMessenger = ScaffoldMessenger.of(context);
    var focusScope = FocusScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.dev_settings_headline),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 20),
          child: Column(
            children: [
              ListTile(
                contentPadding: _settingsTileListPadding,
                title: Text(localizations.dev_settings_test_notification),
                subtitle:
                    Text(localizations.dev_settings_test_notification_text),
                onTap: () {
                  checkForMyPlacesWarnings(
                    alertApi: ref.read(alertApiProvider),
                  );
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

                    scaffoldMessenger.showSnackBar(snackBar);
                  }
                },
              ),
              ListTile(
                contentPadding: _settingsTileListPadding,
                title: Text(
                  "${localizations.dev_settings_delete_list_of_read_warnings} & \n${localizations.dev_settings_delete_notification_list}",
                ),
                subtitle: Text(
                  "${localizations.dev_settings_delete_list_of_read_warnings_text} & \n${localizations.dev_settings_delete_notification_list_text}",
                ),
                onTap: () {
                  debugPrint(
                    "reset read and notification status for all warnings",
                  );
                  for (Place p in myPlaceList) {
                    p.resetReadAndNotificationStatusForAllWarnings(ref);
                  }
                  final snackBar = SnackBar(
                    content: Text(
                      localizations.dev_settings_success,
                      style: const TextStyle(color: Colors.black),
                    ),
                    backgroundColor: Colors.green[100],
                  );

                  scaffoldMessenger.showSnackBar(snackBar);
                },
              ),
              ListTile(
                contentPadding: _settingsTileListPadding,
                title: Text(localizations.dev_settings_delete_warnings),
                subtitle: Text(localizations.dev_settings_delete_warnings_text),
                onTap: () {
                  for (Place p in myPlaceList) {
                    p.warnings.clear();
                  }
                  saveMyPlacesList();
                  final snackBar = SnackBar(
                    content: Text(
                      localizations.dev_settings_success,
                      style: const TextStyle(color: Colors.black),
                    ),
                    backgroundColor: Colors.green[100],
                  );

                  scaffoldMessenger.showSnackBar(snackBar);
                },
              ),
              ListTile(
                contentPadding: _settingsTileListPadding,
                title: const Text(
                  "Systeminformationen zur Fehlerbehebung sammeln",
                ),
                subtitle: const Text(
                  "Stellt Informationen zum System zusammen, die zwecks Fehlerbehandlung an den Entwickler geschickt werden kann. Es werden keine Daten versendet.",
                ),
                onTap: () {
                  debugPrint("Systeminformationen sammeln");
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        const SystemInformationDialog(),
                  );

                  final snackBar = SnackBar(
                    content: const Text(
                      "Collecting system information...",
                      style: TextStyle(color: Colors.black),
                    ),
                    backgroundColor: Colors.green[100],
                  );

                  scaffoldMessenger.showSnackBar(snackBar);
                },
              ),
              ListTile(
                contentPadding: _settingsTileListPadding,
                title: const Text("Zeige Fehlermeldungen an"),
                subtitle:
                    const Text("Zeigt einen Dialog zu Fehlermeldungen an"),
                onTap: () {
                  debugPrint("Lade Fehlermeldungen");
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => const ErrorDialog(),
                  );

                  final snackBar = SnackBar(
                    content: const Text(
                      "Collecting system information...",
                      style: TextStyle(color: Colors.black),
                    ),
                    backgroundColor: Colors.green[100],
                  );

                  scaffoldMessenger.showSnackBar(snackBar);
                },
              ),
              ListTile(
                contentPadding: _settingsTileListPadding,
                title: const Text("Übersicht über Fehlermeldungen"),
                subtitle: const Text(
                  "Führt zu einer Seite mit den Fehlermeldungen an",
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LogFileViewer(),
                    ),
                  );
                },
              ),
              ListTile(
                contentPadding: _settingsTileListPadding,
                title:
                    const Text("Max size of bounding box for a subscription"),
                subtitle: const Text(
                  "select the max size of bounding box for a subscription",
                ),
                trailing: SizedBox(
                  width: 100,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
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
                      if (focusScope.isFirstFocus) {
                        focusScope.unfocus();
                      }
                    },
                    onEditingComplete: () {
                      focusScope.unfocus();
                    },
                    decoration: const InputDecoration(),
                    style: theme.textTheme.bodyMedium,
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
