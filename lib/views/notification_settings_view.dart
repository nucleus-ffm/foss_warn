import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/widgets/notification_preferences_list_tile_widget.dart';
import 'package:foss_warn/widgets/dialogs/warning_severity_explanation.dart';

import '../main.dart';

class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  State<NotificationSettingsView> createState() =>
      _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView> {
  final EdgeInsets settingsTileListPadding = EdgeInsets.fromLTRB(25, 2, 25, 2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context)!.notification_settings_headline),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
              ),
              Container(
                padding: settingsTileListPadding,
                child: Text(AppLocalizations.of(context)!
                    .notification_settings_description), //
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: settingsTileListPadding,
                child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return WarningSeverityExplanation();
                        },
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.info),
                        SizedBox(
                          width: 10,
                        ),
                        Text(AppLocalizations.of(context)!
                            .notification_settings_open_severity_explanation), //
                      ],
                    )),
              ),
              SizedBox(
                height: 10,
              ),
              // generate the settings tiles
              NotificationPreferencesListTileWidget(
                notificationPreferences:
                    userPreferences.notificationSourceSetting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
