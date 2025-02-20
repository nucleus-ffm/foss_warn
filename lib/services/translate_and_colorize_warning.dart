import 'package:flutter/material.dart';
import 'package:foss_warn/enums/message_type.dart';
import 'package:foss_warn/extensions/context.dart';

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

/// translate the category of a warning message
String translateWarningCategory(String category, BuildContext context) {
  var localizations = context.localizations;

  switch (category) {
    case "Health":
    case "Contaminated drinking water":
    case "Pollution de l’eau potable":
      return localizations.explanation_health;
    case "Infra":
      return localizations.explanation_infrastructure;
    case "Fire":
    case "Forest fire":
    case "Safety precautions Forest fires":
      return localizations.explanation_fire;
    case "CBRNE":
      return localizations.explanation_CBRNE;
    case "Other":
    case "Other incident":
      return localizations.explanation_other;
    case "Safety":
      return localizations.explanation_safety;
    case "Security":
      return localizations.explanation_safety;
    case "Met":
      return localizations.explanation_weather;
    case "Env":
    case "Drought":
    case "Geo":
      return localizations.explanation_environment;
    default:
      return category;
  }
}

/// translate the type of a warning message
String translateWarningType(MessageType type, BuildContext context) {
  var localizations = context.localizations;

  switch (type) {
    case MessageType.update:
      return localizations.explanation_warning_level_update;
    case MessageType.cancel:
      return localizations.explanation_warning_level_all_clear;
    case MessageType.alert:
      return localizations.explanation_warning_level_attention;
    default:
      return type.name;
  }
}

/// get a fitting color by the type of a warning message
Color chooseWarningTypeColor(MessageType type) {
  switch (type) {
    case MessageType.update:
      return Colors.blueAccent;
    case MessageType.cancel:
      return Colors.green;
    case MessageType.alert:
      return Colors.red;
    default:
      return Colors.orangeAccent;
  }
}

/// translate the status of a warning message
String translateWarningStatus(String status, BuildContext context) {
  var localizations = context.localizations;
  return (status == "Actual") ? localizations.warning_status_actual : status;
}

/// translate the urgency of a warning message
String translateWarningUrgency(String urgency, BuildContext context) {
  var localizations = context.localizations;
  return (urgency == "Immediate")
      ? localizations.warning_urgency_immediate
      : urgency;
}

/// translate the certainty of a warning message
String translateWarningCertainty(String certainty, BuildContext context) {
  var localizations = context.localizations;
  return (certainty == "Observed")
      ? localizations.warning_certainty_observed
      : certainty;
}
