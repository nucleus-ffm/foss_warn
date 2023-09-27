import 'dart:isolate';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

import '../main.dart';
import '../services/checkForMyPlacesWarnings.dart';
import '../services/locationService.dart';

class AlarmManager {
  void initialize() async {
    await AndroidAlarmManager.initialize();
  }

  // avoids issues in release mode on Flutter >= 3.3.0
  @pragma('vm:entry-point')
  static Future<void> callback() async {
    // fix error with missing plugin exception for sharePref getALL()
    // DartPluginRegistrant.ensureInitialized() comes with Flutter 2.11+
    SharedPreferencesAndroid.registerWith();

    final DateTime now = DateTime.now();
    final int isolateId = Isolate.current.hashCode;
    print("[$now] Call APIs! isolate=$isolateId function='$callback'");

    await checkForMyPlacesWarnings(true, true);
    print("Call APIs executed");
  }

  // avoids issues in release mode on Flutter >= 3.3.0
  @pragma('vm:entry-point')
  static Future<void> updateCurrentLocationInBackground() async {
    // fix error with missing plugin exception for sharePref getALL()
    // DartPluginRegistrant.ensureInitialized() comes with Flutter 2.11+
    SharedPreferencesAndroid.registerWith();

    final DateTime now = DateTime.now();
    final int isolateId = Isolate.current.hashCode;
    print("[$now] Call APIs! isolate=$isolateId function='$callback'");

    await updateCurrentPlace();
    print("updatet currentPlace");
  }

  /// creates a new background task to call the APIs
  void registerBackgroundTask() async {
    await AndroidAlarmManager.periodic(
        Duration(minutes: userPreferences.frequencyOfAPICall.toInt()), 1, callback,
        exact: true,
        rescheduleOnReboot: true,
        allowWhileIdle: true,
        wakeup: true);
    print("AlarmManager successfully started");
  }

  /// creates a new background task to call the APIs
  void registerLocationBackgroundTask() async {
    await AndroidAlarmManager.periodic(
        Duration(minutes: userPreferences.frequencyOfLocationUpdate.toInt()), 2, updateCurrentLocationInBackground,
        exact: true,
        rescheduleOnReboot: true,
        allowWhileIdle: true,
        wakeup: true);
    print("AlarmManager with background location update successfully started");
  }

  void cancelBackgroundTask() async {
    await AndroidAlarmManager.cancel(1);
    print("AlarmManager canceled");
  }

  void cancelLocationBackgroundTask() async {
    await AndroidAlarmManager.cancel(2);
    print("AlarmManager canceled");
  }
}
