import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/extensions/list.dart';
import 'package:foss_warn/services/warnings.dart';
import 'package:latlong2/latlong.dart';

import '../class/class_bounding_box.dart';
import '../class/class_fpas_place.dart';
import '../services/alert_api/fpas.dart';
import '../services/api_handler.dart';
import '../services/list_handler.dart';
import '../services/subscription_handler.dart';
import '../widgets/dialogs/error_dialog.dart';
import '../widgets/dialogs/notification_troubleshoot_dialog.dart';
import '../widgets/dialogs/system_information_dialog.dart';

class DevSettings extends ConsumerStatefulWidget {
  const DevSettings({
    required this.onShowLogFilePressed,
    super.key,
  });

  final VoidCallback onShowLogFilePressed;

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
    var userPreferences = ref.read(userPreferencesProvider);
    maxSizeOfSubscriptionBoundingBox.text =
        userPreferences.maxSizeOfSubscriptionBoundingBox.toString();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var theme = Theme.of(context);
    var scaffoldMessenger = ScaffoldMessenger.of(context);
    var focusScope = FocusScope.of(context);

    var userPreferences = ref.watch(userPreferencesProvider);
    var userPreferencesService = ref.watch(userPreferencesProvider.notifier);
    var warningService = ref.read(processedAlertsProvider.notifier);

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
                  bool thereIsNoWarning = !ref
                      .read(processedAlertsProvider.notifier)
                      .hasWarningToNotify();
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
                  warningService.resetReadAndNotificationStatusForAllWarnings();

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
                title: const Text("Übersicht über Fehlermeldungen"), //@TODO translate
                subtitle: const Text(
                  "Führt zu einer Seite mit den Fehlermeldungen an",
                ),
                onTap: widget.onShowLogFilePressed,
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
                            userPreferencesService
                                .setMaxSizeOfSubscriptionBoundingBox(
                              int.parse(value),
                            );
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
              ListTile(
                title:
                    Text(localizations.dev_settings_subscribe_for_test_alert),
                trailing: Switch(
                  value: userPreferences.subscribeForTestAlerts,
                  onChanged: (value) async {
                    String testAlertPlaceName = "Test Alerts - Point Nemo";
                    var api = ref.read(alertApiProvider);

                    if (value) {
                      try {
                        await subscribeForArea(
                          // FPAS publishes its test alerts for Point Nemo as
                          // this point has the maximal distance to the next
                          // coast in the world.
                          boundingBox: BoundingBox(
                            minLatLng: const LatLng(-47.8767, -122.3933),
                            maxLatLng: const LatLng(-48.8767, -124.3933),
                          ),
                          selectedPlaceName: testAlertPlaceName,
                          context: context,
                          ref: ref,
                        );
                        userPreferencesService.setSubscribeForTestAlerts(value);
                      } on RegisterAreaError {
                        // do not set the switch to true
                      } on SocketException {
                        // do not set the switch to true
                      }
                    } else {
                      // remove subscription for Point Nemo
                      var places = ref.read(myPlacesProvider.notifier);
                      Place? place = places.places.firstWhereOrNull(
                        (p) => p.name == testAlertPlaceName,
                      );
                      if (place != null) {
                        try {
                          await api.unregisterArea(
                            subscriptionId: place.subscriptionId,
                          );
                          places.remove(place);
                          userPreferencesService
                              .setSubscribeForTestAlerts(value);
                        } on UnregisterAreaError {
                          // we currently can not unsubscribe - show a snack bar to inform the
                          // user to check their internet connection
                          final snackBar = SnackBar(
                            content: Text(
                              localizations.delete_place_error,
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                            backgroundColor: theme.colorScheme.errorContainer,
                          );
                          scaffoldMessenger.showSnackBar(snackBar);
                        }
                      } else {
                        // place was manually removed by the user
                        userPreferencesService.setSubscribeForTestAlerts(value);
                      }
                    }
                  },
                ),
              ),
              ListTile(
                title:
                Text(localizations.dev_settings_troubleshoot_notifications),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                    const NotificationTroubleshootDialog(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
