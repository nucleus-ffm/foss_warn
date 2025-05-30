import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_error_logger.dart';
import 'package:foss_warn/class/class_user_preferences.dart';

/// This handler should allow a smooth transition from one version to another.
/// This handler checks if there are old settings that need to be reset or migrated.
/// After a reset, the user should be informed.
Future<void> legacyHandler() async {
  var preferences = SharedPreferencesState.instance;
  try {
    if (preferences.containsKey("previousInstalledVersionCode")) {
      // we have a version information. This is an update
      int previousVersionCode =
          preferences.getInt("previousInstalledVersionCode")!;
      if (previousVersionCode < UserPreferences.currentVersionCode) {
        //@TODO(Nucleus): handle update migration if necessary and show notification afterwards
      }
    }
    // migration complete or new installation. Set previousInstalledVersionCode to current version
    preferences.setInt(
      "previousInstalledVersionCode",
      UserPreferences.currentVersionCode,
    );
  } catch (e) {
    // catch everything from the legacy handler to prevent interrupting the user
    debugPrint("[legacyHandler] Error: ${e.toString()}");
    ErrorLogger.writeErrorLog(
      "legacyhandler.dart",
      "migration from version < 32",
      e.toString(),
    );
  }
}
