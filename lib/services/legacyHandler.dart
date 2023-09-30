import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../widgets/dialogs/legacyWarningDialog.dart';

/// checks if there is old data in SharedPreferences and if yes reset all settings
Future<void> legacyHandler() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  try {
    // before version 0.6.0 we stored e.g. notificationGeneral as string and not as bool.
    String? oldVersionIndicator =
        preferences.getString("showStatusNotification");

    if (oldVersionIndicator != null) {
      print("[legacyHandler] found old data - reset settings..");

      // reset all settings and data
      preferences.clear();

      preferences.setBool("hadToResetSettings", true);
      preferences.setBool("showWelcomeScreen", false);
    }
  } catch (e) {
    print("[legacyHandler] Error: ${e.toString()}");
  }
}

/// shows a dialog with information if FOSSWarn had to reset all settings.
Future<void> showMigrationDialog(BuildContext context) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  bool? hadToResetSettings = preferences.getBool("hadToResetSettings");
  if (hadToResetSettings != null && hadToResetSettings) {
    await showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return LegacyWarningDialog();
      },
    );
    preferences.setBool("hadToResetSettings", false);
  }
}