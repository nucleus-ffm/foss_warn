import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String formatSentDate(String dateAndTime) {
  // if from alert swiss @todo: fix later
  if (dateAndTime.contains(",")) {
    return dateAndTime;
  }

  final List<String> parts = dateAndTime.split("T");

  final String date = parts[0];
  final String year = date.substring(0, 4);
  final String month = date.substring(5, 7);
  final String day = date.substring(8, 10);

  final String time = parts[1].substring(0, 8);

  // @todo: translate "Uhr"
  return "$day.$month.$year - $time Uhr";
}

String translateCategory(String category, BuildContext context) {
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
    case "Safety":
      return AppLocalizations.of(context).explanation_safety;
    case "Met":
      return AppLocalizations.of(context).explanation_weather;
    case "Env":
    case "Drought":
    case "Geo":
      return AppLocalizations.of(context).explanation_environment;
    case "Other":
    case "Other incident":
      return AppLocalizations.of(context).explanation_other;
    default:
      return category;
  }
}

String translateMessageType(String messageType, BuildContext context) {
  switch (messageType) {
    case "Update":
      return AppLocalizations.of(context).explanation_warning_level_update;
    case "Cancel":
      return AppLocalizations.of(context).explanation_warning_level_all_clear;
    case "Alert":
      return AppLocalizations.of(context).explanation_warning_level_attention;
    default:
      return messageType;
  }
}

Color chooseMessageTypeColor(String messageType) {
  switch (messageType) {
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

Color chooseSeverityColor(String severity) {
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

/// translate the message Severity and return the german name
/// @todo: Add translation
String translateMessageSeverity(String severity) {
  switch(severity) {
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

String translateMessageStatus(String status) => (status == "Actual") ? "real" : status;

String translateMessageUrgency(String urgency) => (urgency == "Immediate") ? "unmittelbar" : urgency;

String translateMessageCertainty(String certainty) => (certainty == "Observed") ? "beobachtet" : certainty;
