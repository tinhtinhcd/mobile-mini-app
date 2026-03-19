import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:habit_engine/habit_engine.dart';
import 'package:storage/storage.dart';
import 'package:timer_engine/timer_engine.dart';

final pomodoroHabitServiceProvider = ChangeNotifierProvider<HabitService>((_) {
  throw UnimplementedError('pomodoroHabitServiceProvider must be overridden.');
});

final pomodoroHabitTrackerProvider = Provider<PomodoroHabitTracker>((ref) {
  return PomodoroHabitTracker(ref.read(pomodoroHabitServiceProvider));
});

HabitService buildPomodoroHabitService() {
  return HabitService(
    snapshotStore: JsonHabitSnapshotStore(
      storeLoader:
          () => SharedPreferencesJsonObjectStore.create(
            storageKey: 'pomodoro_app.habit_snapshot',
          ),
    ),
    defaultDailyGoal: 4,
  );
}

class PomodoroHabitTracker {
  const PomodoroHabitTracker(this._habitService);

  final HabitService _habitService;

  Future<void> trackCompletedSession(TimerState completedState) async {
    final TimerSession session = completedState.activeSession;
    if (!session.isTracked) {
      return;
    }

    await _habitService.recordSession(
      type: session.id,
      duration: session.duration,
    );
  }
}
