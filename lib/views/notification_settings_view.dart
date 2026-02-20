import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/widgets/notification_preferences_list_tile_widget.dart';
import 'package:foss_warn/widgets/dialogs/warning_severity_explanation.dart';
import 'package:foss_warn/enums/category.dart';

import '../services/url_launcher.dart';

class NotificationSettingsView extends ConsumerStatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  ConsumerState<NotificationSettingsView> createState() =>
      _NotificationSettingsViewState();
}

class _NotificationSettingsViewState
    extends ConsumerState<NotificationSettingsView> {
  final EdgeInsets settingsTileListPadding =
      const EdgeInsets.fromLTRB(25, 2, 25, 2);

  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.notification_settings_headline),
        actions: [
          IconButton(
            onPressed: () {
              launchUrlInBrowser(
                'https://github.com/nucleus-ffm/foss_warn/wiki/Notification-Settings',
              );
            },
            icon: const Icon(Icons.help),
            tooltip: localizations.help_button_tooltip,
          ),
        ],
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
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
                name: localizations.notification_settings_global_warning_level,
              ),
              const SizedBox(
                height: 20,
              ),
              ExpansionTile(
                title: Text(
                  localizations
                      .notification_settings_show_advanced_settings_title,
                ),
                subtitle: Text(
                  localizations
                      .notification_settings_show_advanced_settings_subtitle,
                ),
                children: [
                  ...Category.values.map(
                    (element) => NotificationPreferencesListTileWidget(
                      name: element.getLocalizedName(context),
                      category: element,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
