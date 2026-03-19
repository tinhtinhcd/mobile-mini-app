import 'package:habit_engine/src/models/habit_snapshot.dart';

abstract class HabitSnapshotStore {
  Future<HabitSnapshot?> readSnapshot();

  Future<void> writeSnapshot(HabitSnapshot snapshot);

  Future<void> clearSnapshot();
}
