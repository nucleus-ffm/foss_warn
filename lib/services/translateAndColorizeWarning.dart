import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// format the given date and time
/// except dataAndTime in format: 2022-12-14T12:32:16+01:00
/// or in format: Fri, 03.02.2023, 14:58
/// return as 14.12.2022 - 12:32:16 Uhr
String formatSentDate(String dateAndTime) {
  String day, month, year = "";
  String seconds, minutes, hours = "";

  try {
    // check if alert swiss or NINA
    if (dateAndTime.contains(",")) {
      // format Alert Swiss
      int comma = dateAndTime.indexOf(",");
      int commaEnd = dateAndTime.indexOf(",", comma + 3);
      String date = dateAndTime.substring(comma + 2, commaEnd);
      day = date.substring(0, 2);
      month = date.substring(3, 5);
      year = date.substring(6, 10);

      String time = dateAndTime.substring(commaEnd + 2);
      hours = time.substring(0, 2);
      minutes = time.substring(3, 5);
      seconds = "00";
    } else {
      // format NINA
      int space = dateAndTime.indexOf("T");
      String date = dateAndTime.substring(0, space);

      year = date.substring(0, 4);
      month = date.substring(5, 7);
      day = date.substring(8, 10);

      String time = dateAndTime.substring(space + 1, space + 9);

      seconds = time.substring(time.length - 2, time.length);
      minutes = time.substring(time.length - 5, time.length - 3);
      hours = time.substring(0, 2);
    }
    // return formatted date and time
    String correctDate =
        day.toString() + "." + month.toString() + "." + year.toString();
    String correctFormatTime = hours + ":" + minutes + ":" + seconds + " Uhr";

    return correctDate + " - " + correctFormatTime;
  } catch (e) {
    print("Error while formatting date: $e");
    // can not format date and time - return unformatted string
    return dateAndTime;
  }
}

/// translate the category of a warning message
String translateWarningCategory(String category, BuildContext context) {
  switch (category) {
    case "Health":
    case "Contaminated drinking water":
    case "Pollution de l’eau potable":
      return AppLocalizations.of(context).explanation_health;
    case "Infra":
      return AppLocalizations.of(context).explanation_infrastructure;
    case "Fire":
    case "Forest fire":
    case "Safety precautions Forest fires":
      return AppLocalizations.of(context).explanation_fire;
    case "CBRNE":
      return AppLocalizations.of(context).explanation_CBRNE;
    case "Other":
    case "Other incident":
      return AppLocalizations.of(context).explanation_other;
    case "Safety":
      return AppLocalizations.of(context).explanation_safety;
    case "Met":
      return AppLocalizations.of(context).explanation_weather;
    case "Env":
    case "Drought":
    case "Geo":
      return AppLocalizations.of(context).explanation_environment;
    default:
      return category;
  }
}

/// translate the type of a warning message
String translateWarningType(String type, BuildContext context) {
  switch (type) {
    case "Update":
      return AppLocalizations.of(context).explanation_warning_level_update;
    case "Cancel":
      return AppLocalizations.of(context).explanation_warning_level_all_clear;
    case "Alert":
      return AppLocalizations.of(context).explanation_warning_level_attention;
    default:
      return type;
  }
}

/// get a fitting color by the type of a warning message
Color chooseWarningTypeColor(String type) {
  switch (type) {
    case "Update":
      return Colors.blueAccent;
    case "Cancel":
      return Colors.green;
    case "Alert":
      return Colors.red;
    default:
      return Colors.orangeAccent;
  }
}

/// get a fitting color by the severity of a warning message
Color chooseWarningSeverityColor(String severity) {
  switch (severity) {
    case "Minor":
      return Colors.blueAccent;
    case "Moderate":
      return Colors.orange;
    case "Extreme":
      return Colors.deepOrange;
    case "Severe":
      return Colors.red;
    default:
      return Colors.grey;
  }
}

/// translate the severity of a warning message
/// @todo: Add translations
String translateWarningSeverity(String severity) {
  switch (severity) {
    case "Minor":
      return "Gering";
    case "Moderate":
      return "Mittel";
    case "Extreme":
      return "Extrem";
    case "Severe":
      return "Schwer";
    default:
      return severity;
  }
}

/// translate the status of a warning message
/// @todo: Add translations
String translateWarningStatus(String status) =>
    (status == "Actual") ? "real" : status;

/// translate the urgency of a warning message
/// @todo: Add translations
String translateWarningUrgency(String urgency) =>
    (urgency == "Immediate") ? "unmittelbar" : urgency;

/// translate the certainty of a warning message
/// @todo: Add translations
String translateWarningCertainty(String certainty) =>
    (certainty == "Observed") ? "beobachtet" : certainty;
