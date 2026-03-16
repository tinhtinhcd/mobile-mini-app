import 'package:fasting_app/src/domain/fasting_plan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notifications/notifications.dart';
import 'package:storage/storage.dart';
import 'package:timer_engine/timer_engine.dart';

const int fastingCompletionNotificationId = 1;

final fastingControllerProvider =
    NotifierProvider<FastingController, TimerState>(FastingController.new);
final fastingNotificationServiceProvider = Provider<NotificationService>((_) {
  throw UnimplementedError(
    'fastingNotificationServiceProvider must be overridden.',
  );
});
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

  NotificationService get _notificationService =>
      ref.read(fastingNotificationServiceProvider);

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

  @override
  Future<void> onTimerStarted(TimerState state) {
    final FastingPlan plan = fastingPlanFromSession(state.activeSession);
    return _notificationService.scheduleNotification(
      id: fastingCompletionNotificationId,
      title: 'Fast Complete',
      body: _notificationBodyForPlan(plan),
      scheduledAt: DateTime.now().add(state.remaining),
    );
  }

  @override
  Future<void> onTimerPaused(TimerState state) {
    return _cancelScheduledNotification();
  }

  @override
  Future<void> onTimerReset(TimerState state) {
    return _cancelScheduledNotification();
  }

  @override
  Future<void> onSessionChanged(TimerState state) {
    return _cancelScheduledNotification();
  }

  @override
  Future<void> onSessionCompleted(
    TimerState completedState,
    TimerSession nextSession,
  ) {
    return _cancelScheduledNotification();
  }

  Future<void> _cancelScheduledNotification() {
    return _notificationService.cancelNotification(
      fastingCompletionNotificationId,
    );
  }

  String _notificationBodyForPlan(FastingPlan plan) {
    switch (plan) {
      case FastingPlan.reset12:
        return 'Your 12:12 fasting window has finished.';
      case FastingPlan.lean16:
        return 'Your fasting window has finished.';
      case FastingPlan.performance18:
        return 'Your 18:6 fasting window has finished.';
      case FastingPlan.deep20:
        return 'Your 20:4 fasting window has finished.';
    }
  }
}
