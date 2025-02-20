import 'package:flutter/material.dart';
import 'package:foss_warn/extensions/context.dart';
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
  final EdgeInsets settingsTileListPadding =
      const EdgeInsets.fromLTRB(25, 2, 25, 2);

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.notification_settings_headline),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: settingsTileListPadding,
                child: Text(localizations.notification_settings_description),
              ),
              const SizedBox(height: 10),
              Container(
                padding: settingsTileListPadding,
                child: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const WarningSeverityExplanation();
                      },
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.info),
                      const SizedBox(width: 10),
                      Text(
                        localizations
                            .notification_settings_open_severity_explanation,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
