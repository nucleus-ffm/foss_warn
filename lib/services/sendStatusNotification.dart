import '../main.dart';
import '../class/class_NotificationService.dart';

sendStatusUpdateNotification(bool success, [String? error]) async {
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

    print("minutes: " + minute.toString());
    print("add hour: " + hourToAdd.toString());
    print("Min + next " + (now.minute + userPreferences.frequencyOfAPICall.toInt()).toString());

    if (hour >= 24) {
      hour -= 24;
    }
  } else {
    minute += userPreferences.frequencyOfAPICall.toInt();
  }

  // format time to hh:mm
  if (now.minute.toString().length == 1) {
    formattedMinuteNow = "0" + now.minute.toString();
  } else {
    formattedMinuteNow = now.minute.toString();
  }
  if (now.hour.toString().length == 1) {
    formattedHourNow = "0" + now.hour.toString();
  } else {
    formattedHourNow = now.hour.toString();
  }

  if (minute.toString().length == 1) {
    formattedMinuteNext = "0" + minute.toString();
  } else {
    formattedMinuteNext = minute.toString();
  }
  if (hour.toString().length == 1) {
    formattedHourNext = "0" + hour.toString();
  } else {
    formattedHourNext = hour.toString();
  }

  String nowFormattedDate = formattedHourNow + ":" + formattedMinuteNow;

  String nextUpdateTimeFormattedDate =
      formattedHourNext + ":" + formattedMinuteNext;

  if (success) {
    print("updating status notification...");
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
          "letztes Update: $nowFormattedDate Uhr - nächstes Update: $nextUpdateTimeFormattedDate Uhr \n"
          "Error: $error",
      payload: "statusanzeige",
    );
  }
}
