import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


String formatSentDate(String dateAndTime) {
  // if from alert swiss @todo: fix later
  if(dateAndTime.contains(",")) {
    return dateAndTime;
  }
  int space = dateAndTime.indexOf("T");
  String date = dateAndTime.substring(0, space);

  int year = int.parse(date.substring(0, 4));
  int month = int.parse(date.substring(5, 7));
  int day = int.parse(date.substring(8, 10));

  String time = dateAndTime.substring(space + 1, space + 9);

  int seconds = int.parse(time.substring(time.length - 2, time.length));
  int minutes = int.parse(time.substring(time.length - 5, time.length - 3));
  int hours = int.parse(time.substring(0, 2));

  String secondsAsString = "";
  String minutesAsString = "";
  String hoursAsString = "";

  if (seconds.toString().length == 1) {
    secondsAsString = "0" + seconds.toString();
  } else {
    secondsAsString = seconds.toString();
  }
  if (minutes.toString().length == 1) {
    minutesAsString = "0" + minutes.toString();
  } else {
    minutesAsString = minutes.toString();
  }
  if (hours.toString().length == 1) {
    hoursAsString = "0" + hours.toString();
  } else {
    hoursAsString = hours.toString();
  }

  String correctDate =
      day.toString() + "." + month.toString() + "." + year.toString();
  String correctFormatTime =
      hoursAsString + ":" + minutesAsString + ":" + secondsAsString + " Uhr";

  return correctDate + " - " + correctFormatTime;
}

String translateCategory(String text, BuildContext context) {
  if (text == "Health" || text == "Contaminated drinking water"|| text == "Pollution de l’eau potable" ) {
    return AppLocalizations.of(context).explanation_health;
  } else if (text == "Infra") {
    return  AppLocalizations.of(context).explanation_infrastructure;
  } else if (text == "Fire" || text == "Forest fire" ||
      text == "Safety precautions Forest fires") {
    return  AppLocalizations.of(context).explanation_fire;
  } else if (text == "CBRNE") {
    return  AppLocalizations.of(context).explanation_CBRNE;
  } else if (text == "Other" || text == "Other incident") {
    return  AppLocalizations.of(context).explanation_other;
  } else if (text == "Safety") {
    return  AppLocalizations.of(context).explanation_safety;
  } else if (text == "Met") {
    return  AppLocalizations.of(context).explanation_weather;
  } else if (text == "Env" || text == "Drought" || text == "Geo") {
    return  AppLocalizations.of(context).explanation_environment;
  } else {
    return text;
  }
}

String translateMessageType(String text, BuildContext context) {
  if (text == "Update") {
    return AppLocalizations.of(context).explanation_warning_level_update;
  } else if (text == "Cancel") {
    return AppLocalizations.of(context).explanation_warning_level_all_clear;
  } else if (text == "Alert") {
    return AppLocalizations.of(context).explanation_warning_level_attention;
  } else {
    return text;
  }
}

Color chooseMessageTypeColor(String text) {
  if (text == "Update") {
    return Colors.blueAccent;
  } else if (text == "Cancel") {
    return Colors.green;
  } else if (text == "Alert") {
    return Colors.red;
  } else {
    return Colors.orangeAccent;
  }
}
Color chooseSeverityColor(String text) {
  if (text == "Minor") {
    return Colors.blueAccent;
  } else if (text == "Moderate") {
    return Colors.orange;
  } else if (text == "Extrem") {
    return Colors.deepOrange;
  } else if (text == "Severe") {
    return Colors.red;
  } else {
    return Colors.grey;
  }
}
/// translate the message Severity and return the german name
/// @todo: Add translation
String translateMessageSeverity(String text) {
  // remove potential whitespace
  text = text.trim().toLowerCase();
  if (text == "minor") {
    return "Gering";
  } else if (text == "moderate") {
    return "Mittel";
  } else if (text == "extreme") {
    return "Extrem";
  } else if (text == "severe") {
    return "Schwer";
  } else {
    return text;
  }
}

String translateMessageStatus(String text) {
  if (text == "Actual") {
    return "real";
  } else {
    return text;
  }
}

String translateMessageUrgency(String text) {
  if (text == "Immediate") {
    return "unmittelbar";
  } else {
    return text;
  }
}

String translateMessageCertainty(String text) {
  if (text == "Observed") {
    return "beobachtet";
  } else {
    return text;
  }
}