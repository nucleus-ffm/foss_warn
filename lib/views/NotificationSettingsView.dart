import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:foss_warn/class/class_notificationPreferences.dart';
import 'package:foss_warn/enums/NotificationLevel.dart';
import 'package:foss_warn/enums/WarningSource.dart';
import 'package:foss_warn/widgets/NotificationPreferencesListTileWidget.dart';

import '../main.dart';

class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsView> createState() =>
      _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView> {
  final EdgeInsets settingsTileListPadding = EdgeInsets.fromLTRB(25, 2, 25, 2);

  @override
  Widget build(BuildContext context) {
    // fill notificationSourceSettings with init data if empty
    if (userPreferences.notificationSourceSettings.isEmpty) {
      userPreferences.notificationSourceSettings.clear();
      print("User Preferences notificationSourceSettings is empty");
      userPreferences.notificationSourceSettings.add(NotificationPreferences(
          warningSource: WarningSource.other,
          notificationLevel: NotificationLevel.getUpToMinor));
      userPreferences.notificationSourceSettings.add(NotificationPreferences(
          warningSource: WarningSource.mowas,
          notificationLevel: NotificationLevel.getUpToMinor));
      userPreferences.notificationSourceSettings.add(NotificationPreferences(
          warningSource: WarningSource.biwapp,
          notificationLevel: NotificationLevel.getUpToMinor));
      userPreferences.notificationSourceSettings.add(NotificationPreferences(
          warningSource: WarningSource.katwarn,
          notificationLevel: NotificationLevel.getUpToMinor));
      userPreferences.notificationSourceSettings.add(NotificationPreferences(
          warningSource: WarningSource.dwd,
          notificationLevel: NotificationLevel.getUpToSevere));
      userPreferences.notificationSourceSettings.add(NotificationPreferences(
          warningSource: WarningSource.lhp,
          notificationLevel: NotificationLevel.getUpToSevere));
      userPreferences.notificationSourceSettings.add(NotificationPreferences(
          warningSource: WarningSource.alertSwiss,
          notificationLevel: NotificationLevel.getUpToMinor));
    }

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
                child: Text(
                    "Hier können Sie einstellen, ab welcher Warnstufe Sie für"
                    " welche Warnquelle eine Benachrichtigung erhalten möchten. "),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: settingsTileListPadding,
                child: Divider(),
              ),
              // generate the settings tiles
              ...userPreferences.notificationSourceSettings
                  .map((element) => NotificationPreferencesListTileWidget(
                        notificationPreferences: element,
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}
