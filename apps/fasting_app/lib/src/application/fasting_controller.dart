import 'package:fasting_app/src/domain/fasting_plan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storage/storage.dart';
import 'package:timer_engine/timer_engine.dart';

final fastingControllerProvider =
    NotifierProvider<FastingController, TimerState>(FastingController.new);
final fastingSnapshotStoreProvider = Provider<TimerSnapshotStore>((_) {
  throw UnimplementedError('fastingSnapshotStoreProvider must be overridden.');
});
final fastingRestoredSnapshotProvider = Provider<TimerSnapshot?>((_) => null);

class FastingController extends TimerController {
  @override
  TimerSession get initialSession => FastingPlan.lean16.session;

  @override
  TimerSnapshot? get restoredSnapshot => ref.read(
        fastingRestoredSnapshotProvider,
      );

  @override
  Future<void> persistSnapshot(TimerSnapshot snapshot) {
    return ref.read(fastingSnapshotStoreProvider).writeSnapshot(snapshot);
  }

  @override
  TimerSession restoreSession(String sessionId) {
    return fastingPlanFromSessionId(sessionId).session;
  }

  FastingPlan get selectedPlan => fastingPlanFromSession(state.activeSession);

  void selectPlan(FastingPlan plan) {
    selectSession(plan.session);
  }

  @override
  TimerSession resolveNextSession(TimerState completedState) {
    return completedState.activeSession;
  }
}
