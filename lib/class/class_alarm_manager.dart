import 'dart:isolate';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

import '../main.dart';
import '../services/check_for_my_places_warnings.dart';

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
    debugPrint("[$now] Call APIs! isolate=$isolateId function='$callback'");

    await checkForMyPlacesWarnings(true);
    debugPrint("Call APIs executed");
  }

  /// creates a new background task to call the APIs
  void registerBackgroundTask() async {
    await AndroidAlarmManager.periodic(
        Duration(minutes: userPreferences.frequencyOfAPICall.toInt()),
        1,
        callback,
        exact: true,
        rescheduleOnReboot: true,
        allowWhileIdle: true,
        wakeup: true);
    debugPrint("AlarmManager successfully started");
  }

  void cancelBackgroundTask() async {
    await AndroidAlarmManager.cancel(1);
    debugPrint("AlarmManager canceled");
  }
}
