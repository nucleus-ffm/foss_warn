import 'dart:io';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_error_logger.dart';
import 'package:foss_warn/class/class_location_tracker.dart';
import 'package:foss_warn/class/class_notification_preferences.dart';
import 'package:foss_warn/class/class_notification_service.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/class/class_warn_message.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/warnings.dart';
import 'package:foss_warn/constants.dart' as constants;

// avoids issues in release mode on Flutter >= 3.3.0
@pragma('vm:entry-point', true)
Future<void> backgroundPollingCallback() async {
  try {
    await SharedPreferencesState.initialize();
  } catch (e) {
    ErrorLogger.writeLog(
      "class_alarm_manager.dart",
      "BackgroundPollingCallback",
      "Failed to initialize shared preferences state: $e",
    );

    debugPrint("shared Prefs error $e");
  }

  await NotificationService().init();

  final DateTime now = DateTime.now();

  final container = ProviderContainer();

  ErrorLogger.writeErrorLog(
    "alarm_manager.dart",
    "Background update info",
    "Background update has started at $now",
  );

  container.read(userPreferencesProvider);
  container.invalidate(alertsFutureProvider);
  var alerts = container.read(processedAlertsProvider);

  for (WarnMessage alert in alerts) {
    if (!alert.notified) {
      if (NotificationPreferences.checkIfEventShouldBeNotified(
        alert.info.first.severity,
        alert.info.first.category,
        container.read(userPreferencesProvider),
      )) {
        NotificationService.showNotification(
          id: alert.identifier.hashCode,
          title: "New alert: ${alert.info.first.headline}",
          body: alert.info.first.description.substring(0, 100),
          channelId:
              "de.nucleus.foss_warn.notifications_${alert.info.first.severity.name}",
          channelName: "",
        );
        container
            .read(processedAlertsProvider.notifier)
            .updateAlert(alert.copyWith(notified: true));
      }
    }
  }

  container.dispose();
  ErrorLogger.writeErrorLog(
    "alarm_manager.dart",
    "Background update info",
    "Background update has finished at $now",
  );
}

/// callback task for updating the current location
// avoids issues in release mode on Flutter >= 3.3.0
@pragma('vm:entry-point', true)
Future<void> backgroundLocationUpdateCallback() async {
  try {
    await SharedPreferencesState.initialize();
  } catch (e) {
    ErrorLogger.writeLog(
      "class_alarm_manager.dart",
      "BackgroundPollingCallback",
      "Failed to initialize shared preferences state: $e",
    );

    debugPrint("shared Prefs error $e");
  }

  await NotificationService().init();

  final DateTime now = DateTime.now();

  final container = ProviderContainer();

  try {
    ErrorLogger.writeLog(
      "alarm_manager.dart",
      "Background location update info",
      "Background location update has started at $startTime in isolate $isolateId",
    );

  var locationTracker = container.read(locationTrackerProvider);
  await locationTracker.subscribeForCurrentLocation();

  ErrorLogger.writeErrorLog(
    "alarm_manager.dart",
    "Background location update info",
    "Background location update has ended at $now",
  );
  container.dispose();
}

@pragma('vm:entry-point', true)
class AlarmManager {
  /// [Android only]
  /// creates a new background task to call the APIs
  static Future<void> registerBackgroundPollingTask() async {
    if (!Platform.isAndroid) return;
    await AndroidAlarmManager.initialize();
    if (await AlarmManager.requestAlarmPermission()) {
      await AndroidAlarmManager.periodic(
        const Duration(minutes: 15),
        constants.alarmManagerTaskIdPolling,
        backgroundPollingCallback,
        exact: true,
        rescheduleOnReboot: true,
        allowWhileIdle: true,
        wakeup: true,
      );
      debugPrint("AlarmManager notification successfully started");
    } else {
      debugPrint(
        "Can not register background task due to missing alarm permission",
      );
    }
  }

  /// [Android only]
  /// creates a new background task to call the APIs
  static Future<void> registerBackgroundLocationTask() async {
    if (!Platform.isAndroid) return;
    if (await AndroidAlarmManager.initialize()) {
      await AndroidAlarmManager.periodic(
        // @TODO in a future version we can let the user decide for the update period
        const Duration(
          hours: 1,
          minutes: 30,
        ),
        constants.alarmManagerTaskIdLocation,
        backgroundLocationUpdateCallback,
        exact:
            false, // an exact execution is not required here, with this we do not need the setExactAlarm permission
        rescheduleOnReboot: true,
        allowWhileIdle: true,
        wakeup: true,
      );
    } else {
      debugPrint("Failed to initialize AndroidAlarmManager");
    }
  }

  /// [Android only]
  /// cancel the periodic task
  static Future<void> cancelBackgroundPollingTask() async {
    if (!Platform.isAndroid) return;
    await AndroidAlarmManager.cancel(constants.alarmManagerTaskIdPolling);
    debugPrint("AlarmManager polling task canceled");
  }

  /// [Android only]
  /// Cancel the background location task
  static Future<void> cancelBackgroundLocationTask() async {
    if (!Platform.isAndroid) return;
    if (await AndroidAlarmManager.cancel(
      constants.alarmManagerTaskIdLocation,
    )) {
      debugPrint("AlarmManager location task canceled");
    } else {
      debugPrint("Failed to cancel AlarmManager location task");
    }
  }

  /// [Android only]
  /// request alarm permission and return the state afterwards
  static Future<bool> requestAlarmPermission() async {
    if (!Platform.isAndroid) return false;
    return await Permission.scheduleExactAlarm.request().isGranted;
  }
}
