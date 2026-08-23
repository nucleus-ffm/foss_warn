import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/class_error_logger.dart';
import 'package:foss_warn/class/class_location_tracker.dart';
import 'package:foss_warn/class/class_notification_preferences.dart';
import 'package:foss_warn/class/class_notification_service.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/class/class_warn_message.dart';
import 'package:foss_warn/extensions/list.dart';
import 'package:foss_warn/services/list_handler.dart';
import 'package:permission_handler/permission_handler.dart';

import '../enums/notification_channel.dart';
import '../services/alert_text_parser.dart';
import '../services/warnings.dart';
import 'package:foss_warn/constants.dart' as constants;

// avoids issues in release mode on Flutter >= 3.3.0
@pragma('vm:entry-point')
Future<void> backgroundPollingCallback() async {
  try {
    await SharedPreferencesState.initialize();
  } catch (e) {
    ErrorLogger.writeLog(
      "class_alarm_manager.dart",
      "BackgroundPollingCallback",
      "Failed to initialize shared preferences state: $e",
    );
  }

  await NotificationService().init();

  final DateTime startTime = DateTime.now();
  final int isolateId = Isolate.current.hashCode;

  final container = ProviderContainer();

  try {
    // fetch and reconcile, then notify for everything that is still unnotified
    await container.refresh(alertsFutureProvider.future);
    var alerts = applyUpdateRelations(container.read(processedAlertsProvider));
    for (WarnMessage alert in alerts) {
      if (alert.info.isEmpty) {
        await ErrorLogger.writeLog(
          "class_alarm_manager.dart",
          "BackgroundPollingCallback",
          "Alert ${alert.fpasId} has no info block and is not notified",
        );
        continue;
      }
      if (!alert.notified &&
          !alert.read &&
          !alert.hideWarningBecauseThereIsANewerVersion) {
        if (NotificationPreferences.checkIfEventShouldBeNotified(
          alert.info.first.severity,
          alert.info.first.category,
          container.read(userPreferencesProvider),
        )) {
          var description = alertTextToPlainText(alert.info.first.description);
          var place = container
              .read(myPlacesProvider)
              .firstWhereOrNull((p) => p.id == alert.placeId);

          String title = "";
          if (place != null) {
            title = "${place.name}: ${alert.info.first.headline}";
          } else {
            title = alert.info.first.headline;
          }

          await NotificationService.showNotification(
            id: alert.fpasId.hashCode,
            title: title,
            body: description.substring(0, min(description.length, 150)),
            channel: alert.isUpdateOfAlreadyNotifiedWarning
                ? NotificationChannel.update
                : NotificationChannel.fromSeverity(alert.info.first.severity),
            payload: place?.name,
          );
          container
              .read(processedAlertsProvider.notifier)
              .updateAlert(alert.copyWith(notified: true));
        }
      }
    }
  } catch (e, stack) {
    final DateTime endTime = DateTime.now();
    await ErrorLogger.writeLog(
      "alarm_manager.dart",
      "Background update info",
      "Background update has failed at $endTime after ${endTime.difference(startTime)} in isolate $isolateId dues to $e \n $stack",
    );
  } finally {
    container.dispose();
    final DateTime endTime = DateTime.now();
    //@TODO(Nucleus): Introduce a new debug flag for that
    if (container.read(userPreferencesProvider).showDebugNotification) {
      await ErrorLogger.writeLog(
        "alarm_manager.dart",
        "Background update info",
        "Background update has finished at $endTime after ${endTime.difference(startTime)} in isolate $isolateId.",
      );
    }
  }
}

/// callback task for updating the current location
// avoids issues in release mode on Flutter >= 3.3.0
@pragma('vm:entry-point')
Future<void> backgroundLocationUpdateCallback() async {
  try {
    await SharedPreferencesState.initialize();
  } catch (e) {
    ErrorLogger.writeLog(
      "class_alarm_manager.dart",
      "BackgroundPollingCallback",
      "Failed to initialize shared preferences state: $e",
    );
  }

  await NotificationService().init();
  final DateTime startTime = DateTime.now();
  final int isolateId = Isolate.current.hashCode;

  final container = ProviderContainer();

  try {
    ErrorLogger.writeLog(
      "alarm_manager.dart",
      "Background location update info",
      "Background location update has started at $startTime in isolate $isolateId",
    );

    var locationTracker = container.read(locationTrackerProvider);
    // location access will timeout after 1 min, so we grant the entire call 1,5m as timeout
    await locationTracker
        .subscribeForCurrentLocation()
        .timeout(const Duration(minutes: 1, seconds: 30));
  } catch (e, stack) {
    final DateTime endTime = DateTime.now();
    ErrorLogger.writeLog(
      "alarm_manager.dart",
      "Background location update info",
      "Background location update has ended $endTime after ${endTime.difference(startTime)} in isolate $isolateId dues to $e \n $stack",
    );
  } finally {
    container.dispose();
    final DateTime endTime = DateTime.now();
    ErrorLogger.writeLog(
      "alarm_manager.dart",
      "Background location update info",
      "Background location update has ended at $endTime after ${endTime.difference(startTime)} in isolate $isolateId",
    );
  }
}

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
        const Duration(
          //@TODO make delay configurable via Ui
          hours: 1,
          minutes: 30,
        ),
        constants.alarmManagerTaskIdLocation,
        backgroundLocationUpdateCallback,
        exact:
            false, // an exact execution is not required here. Without we do not need the setExactAlarm permission
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
