import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Daytime { day, night }

final selectedDayTimeProvider = StateProvider<Daytime>((ref) => Daytime.day);
