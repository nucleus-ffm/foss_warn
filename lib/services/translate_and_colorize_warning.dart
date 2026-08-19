import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatSentDate(String dateAndTime, BuildContext context) {
  final parsed = DateTime.tryParse(dateAndTime)?.toLocal();
  if (parsed == null) return dateAndTime;
  return DateFormat.yMd(Localizations.localeOf(context).toString())
      .add_Hms()
      .format(parsed);
}
