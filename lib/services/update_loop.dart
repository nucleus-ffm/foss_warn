import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangeEventTimerNotifier extends StateNotifier<ChangeEvent> {
  ChangeEventTimerNotifier() : super(ChangeEvent(tick: 0));

  late Timer _timer;

  void _tick() {
    state = ChangeEvent(tick: state.tick + 1);
  }

  void _stop() {
    _timer.cancel();
  }

  void _start() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _tick();
    });
  }
}

class ChangeEvent {
  ChangeEvent({required this.tick});

  final int tick;
}

final changeEventProvider =
    StateNotifierProvider<ChangeEventTimerNotifier, ChangeEvent>((ref) {
  var notifier = ChangeEventTimerNotifier();
  notifier._start();

  ref.onCancel(notifier._stop);
  ref.onDispose(notifier._stop);
  ref.onResume(notifier._start);

  return notifier;
});

final tickingChangeProvider = Provider.family<ChangeEvent, int>(
  (ref, ticks) {
    ref.listen(changeEventProvider, (previous, next) {
      if (next.tick % ticks == 0) {
        ref.invalidateSelf();
      }
    });
    return ref.read(changeEventProvider);
  },
);
