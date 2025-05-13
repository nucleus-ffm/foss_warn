import 'package:flutter/material.dart';
import 'package:foss_warn/class/class_user_preferences.dart';
import 'package:foss_warn/services/save_and_load_shared_preferences.dart';

import '../class/class_notification_service.dart';

Future<void> sendStatusUpdateNotification(
  bool success, {
  required UserPreferences userPreferences,
  String? error,
}) async {
  String lastUpdate = await loadLastBackgroundUpdateTime();
  DateTime now = DateTime.now();
  int hour = now.hour;
  int hourToAdd = 0;
  int minute = now.minute;
  String formattedMinuteNext,
      formattedHourNext,
      formattedMinuteNow,
      formattedHourNow = "";

  if (now.minute + userPreferences.frequencyOfAPICall >= 60) {
    hourToAdd = (now.minute + userPreferences.frequencyOfAPICall.toInt()) ~/ 60;
    minute = (now.minute + userPreferences.frequencyOfAPICall.toInt()) % 60;
    hour += hourToAdd;

    debugPrint("minutes: $minute");
    debugPrint("add hour: $hourToAdd");
    debugPrint(
      "Min + next ${now.minute + userPreferences.frequencyOfAPICall.toInt()}",
    );

    if (hour >= 24) {
      hour -= 24;
    }
  } else {
    minute += userPreferences.frequencyOfAPICall.toInt();
  }

  // format time to hh:mm
  if (now.minute.toString().length == 1) {
    formattedMinuteNow = "0${now.minute}";
  } else {
    formattedMinuteNow = now.minute.toString();
  }
  if (now.hour.toString().length == 1) {
    formattedHourNow = "0${now.hour}";
  } else {
    formattedHourNow = now.hour.toString();
  }

  if (minute.toString().length == 1) {
    formattedMinuteNext = "0$minute";
  } else {
    formattedMinuteNext = minute.toString();
  }
  if (hour.toString().length == 1) {
    formattedHourNext = "0$hour";
  } else {
    formattedHourNext = hour.toString();
  }

  String nowFormattedDate = "$formattedHourNow:$formattedMinuteNow";

  String nextUpdateTimeFormattedDate =
      "$formattedHourNext:$formattedMinuteNext";

  if (success) {
    saveLastBackgroundUpdateTime(nowFormattedDate);
    debugPrint("updating status notification...");
    await NotificationService.showStatusNotification(
      id: 1,
      title: "FOSS Warn ist aktiv",
      body:
          "letztes Update: $nowFormattedDate Uhr - nächstes Update: $nextUpdateTimeFormattedDate Uhr",
      payload: "statusanzeige",
    );
  } else {
    await NotificationService.showStatusNotification(
      id: 1,
      title: "FOSS Warn - Aktualisierung fehlgeschlagen",
      body:
          "letztes erfolgreiches Update: $lastUpdate Uhr - nächstes Update: $nextUpdateTimeFormattedDate Uhr \n"
          "Error: $error",
      payload: "statusanzeige",
    );
  }
}
