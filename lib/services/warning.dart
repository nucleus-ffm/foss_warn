import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foss_warn/class/abstract_place.dart';
import 'package:foss_warn/class/class_warn_message.dart';

final currentWarningProvider = StateProvider<ActiveWarning?>((ref) => null);

class ActiveWarning {
  final WarnMessage message;
  final Place? place;

  const ActiveWarning({
    required this.message,
    required this.place,
  });
}
