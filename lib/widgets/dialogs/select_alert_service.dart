import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_unified_push_handler.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/enums/alert_service.dart';
import 'package:foss_warn/extensions/context.dart';
import 'package:foss_warn/services/url_launcher.dart';

import '../../class/class_alarm_manager.dart';

class SelectAlertServiceDialog extends ConsumerStatefulWidget {
  const SelectAlertServiceDialog({super.key});

  @override
  ConsumerState<SelectAlertServiceDialog> createState() =>
      _FontSizeDialogState();
}

class _FontSizeDialogState extends ConsumerState<SelectAlertServiceDialog> {
  @override
  Widget build(BuildContext context) {
    var localizations = context.localizations;
    var theme = Theme.of(context);
    var navigator = Navigator.of(context);

    var userPreferences = ref.watch(userPreferencesProvider);
    var userPreferencesService = ref.read(userPreferencesProvider.notifier);

    return SimpleDialog(
      title: Text(localizations.alert_service_dialog_title),
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  launchUrlInBrowser(
                    "https://github.com/nucleus-ffm/foss_warn/wiki/Alert-Services",
                  );
                },
                child: Text(localizations.alert_service_dialog_help_text),
              ),
              ListTile(
                title: Text(localizations.alert_service_push),
                subtitle: Text(localizations.alert_service_push_description),
                leading: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.speed),
                ),
                selectedColor: theme.colorScheme.primary,
                selected: userPreferences.alertService == AlertService.push,
                onTap: () {
                  userPreferencesService.setAlertService(AlertService.push);
                  navigator.pop();
                  AlarmManager.cancelBackgroundPollingTask();
                },
              ),
              ListTile(
                title: Text(localizations.alert_service_poll),
                subtitle: Text(localizations.alert_service_poll_description),
                leading: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.refresh),
                ),
                selectedColor: theme.colorScheme.primary,
                selected: userPreferences.alertService == AlertService.poll,
                onTap: () {
                  userPreferencesService.setAlertService(AlertService.poll);
                  navigator.pop();
                  AlarmManager.registerBackgroundPollingTask();
                },
              ),
              ListTile(
                title: Text(localizations.alert_service_push_and_poll),
                subtitle:
                    Text(localizations.alert_service_push_and_poll_description),
                leading: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.health_and_safety_rounded),
                ),
                selectedColor: theme.colorScheme.primary,
                selected:
                    userPreferences.alertService == AlertService.pushAndPoll,
                onTap: () {
                  userPreferencesService
                      .setAlertService(AlertService.pushAndPoll);
                  navigator.pop();
                  AlarmManager.registerBackgroundPollingTask();
                },
              ),
              ListTile(
                title: Text(localizations.alert_service_nothing),
                subtitle: Text(localizations.alert_service_nothing_description),
                leading: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.update_disabled),
                ),
                selectedColor: theme.colorScheme.primary,
                selected: userPreferences.alertService == AlertService.nothing,
                onTap: () {
                  userPreferencesService.setAlertService(AlertService.nothing);
                  ref
                      .read(unifiedPushHandlerProvider)
                      .unregisterDistributor(ref);
                  navigator.pop();
                  AlarmManager.cancelBackgroundPollingTask();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
