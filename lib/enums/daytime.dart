import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Daytime { day, night }

final selectedDayTimeProvider = StateProvider<Daytime>((ref) => Daytime.day);

int _dayTimeToMinutes(TimeOfDay time) {
  return time.hour * 60 + time.minute;
}

/// returns if the users thinks it is day or night at the moment
/// convert to minutes first to check for wrapped around more easily
bool isDay(TimeOfDay startOfDay, TimeOfDay endOfDay) {
  TimeOfDay now = TimeOfDay.now();

  int nowMin = _dayTimeToMinutes(now);
  int startMin = _dayTimeToMinutes(startOfDay);
  int endMin = _dayTimeToMinutes(endOfDay);

  if (startMin < endMin) {
    return nowMin >= startMin && nowMin < endMin;
  } else {
    return nowMin >= startMin || nowMin < endMin;
  }
}