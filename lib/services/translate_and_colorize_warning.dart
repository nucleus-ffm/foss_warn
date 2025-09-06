import 'package:flutter/material.dart';

/// format the given date and time
/// except dataAndTime in format: 2022-12-14T12:32:16+01:00
/// or in format: Fri, 03.02.2023, 14:58
/// return as 14.12.2022 - 12:32:16 Uhr
String formatSentDate(String dateAndTime) {
  String day, month, year = "";
  String seconds, minutes, hours = "";

  try {
    int space = dateAndTime.indexOf("T");
    String date = dateAndTime.substring(0, space);

    year = date.substring(0, 4);
    month = date.substring(5, 7);
    day = date.substring(8, 10);

    String time = dateAndTime.substring(space + 1, space + 9);

    seconds = time.substring(time.length - 2, time.length);
    minutes = time.substring(time.length - 5, time.length - 3);
    hours = time.substring(0, 2);

    // return formatted date and time
    String correctDate = "$day.$month.$year";
    String correctFormatTime = "$hours:$minutes:$seconds Uhr";

    return "$correctDate - $correctFormatTime";
  } catch (e) {
    debugPrint("Error while formatting date: $e");
    // can not format date and time - return unformatted string
    return dateAndTime;
  }
}
