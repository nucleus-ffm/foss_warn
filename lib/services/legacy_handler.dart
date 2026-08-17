import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_error_logger.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../widgets/dialogs/update_dialog.dart';

/// This handler should allow a smooth transition from one version to another.
/// This handler checks if there are old settings that need to be reset or migrated.
/// After a reset, the user should be informed.
Future<void> legacyHandler() async {
  var preferences = SharedPreferencesState.instance;
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  int currentVersionCode = int.parse(packageInfo.buildNumber);
  try {
    if (preferences.containsKey("previousInstalledVersionCode")) {
      // we have a version information. This is an update

      int previousVersionCode =
          preferences.getInt("previousInstalledVersionCode")!;
      if (previousVersionCode < currentVersionCode) {
        if (previousVersionCode <= 33) {
          //version 8.x.x or smaller
          // this is a major update. This requires user attention and we need to reset the entire app
          // clear all old settings to make place for the new app version
          preferences.clear();
        } else if (previousVersionCode < 42) {
          preferences.setBool("showUpdateDialog", true);
        } else if (previousVersionCode < 45) {
          // we let the software handle https now so the user don't has to deal with that anymore
          // but we need to adapt the stored address to remove the http scheme
          String? serverUrl = preferences.getString("fossPublicAlertServerUrl");
          if (serverUrl != null && serverUrl.toLowerCase().startsWith("http")) {
            serverUrl = serverUrl.replaceAll("http://", "");
            serverUrl = serverUrl.replaceAll("https://", "");
            preferences.setString("fossPublicAlertServerUrl", serverUrl);
          }
        }
      }
    }
    // migration complete or new installation. Set previousInstalledVersionCode to current version
    preferences.setInt(
      "previousInstalledVersionCode",
      currentVersionCode,
    );
  } catch (e) {
    // catch everything from the legacy handler to prevent interrupting the user
    debugPrint("[legacyHandler] Error: ${e.toString()}");
    ErrorLogger.writeLog(
      "legacyhandler.dart",
      "migration from version < 32",
      e.toString(),
    );
  }
}

/// Show a dialog after an update with information about this version
Future<void> showUpdateDialog(BuildContext context, WidgetRef ref) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return const UpdateDialog();
    },
  );
  ref.read(userPreferencesProvider.notifier).setShowUpdateDialog(false);
}
