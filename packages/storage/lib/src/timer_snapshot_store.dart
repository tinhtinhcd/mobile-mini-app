class TimerSnapshot {
  const TimerSnapshot();
}

abstract class TimerSnapshotStore {
  Future<TimerSnapshot?> readSnapshot();
  Future<void> writeSnapshot(TimerSnapshot snapshot);
  Future<void> clearSnapshot();
}
