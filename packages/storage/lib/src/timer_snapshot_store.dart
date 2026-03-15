import 'package:timer_engine/timer_engine.dart';

abstract class TimerSnapshotStore {
  Future<TimerSnapshot?> readSnapshot();

  Future<void> writeSnapshot(TimerSnapshot snapshot);

  Future<void> clearSnapshot();
}

