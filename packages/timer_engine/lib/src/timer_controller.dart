import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerState {
  const TimerState();
}

abstract class TimerController extends Notifier<TimerState> {}
