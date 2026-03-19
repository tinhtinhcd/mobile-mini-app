import 'package:fasting_app/src/domain/fasting_plan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:habit_engine/habit_engine.dart';
import 'package:storage/storage.dart';
import 'package:timer_engine/timer_engine.dart';

final fastingHabitServiceProvider = ChangeNotifierProvider<HabitService>((_) {
  throw UnimplementedError('fastingHabitServiceProvider must be overridden.');
});

final fastingHabitTrackerProvider = Provider<FastingHabitTracker>((ref) {
  return FastingHabitTracker(ref.read(fastingHabitServiceProvider));
});

HabitService buildFastingHabitService() {
  return HabitService(
    snapshotStore: JsonHabitSnapshotStore(
      storeLoader:
          () => SharedPreferencesJsonObjectStore.create(
            storageKey: 'fasting_app.habit_snapshot',
          ),
    ),
    defaultDailyGoal: 1,
  );
}

class FastingHabitTracker {
  const FastingHabitTracker(this._habitService);

  final HabitService _habitService;

  Future<void> trackCompletedSession(TimerState completedState) async {
    final TimerSession session = completedState.activeSession;
    if (!session.isTracked) {
      return;
    }

    final FastingPlan plan = fastingPlanFromSession(session);
    await _habitService.recordSession(
      type: plan.name,
      duration: session.duration,
    );
  }
}
