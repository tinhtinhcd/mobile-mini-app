import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notifications/notifications.dart';
import 'package:storage/storage.dart';
import 'package:timer_engine/timer_engine.dart';

const int pomodoroCompletionNotificationId = 1;

final pomodoroControllerProvider =
    NotifierProvider<PomodoroController, TimerState>(PomodoroController.new);
final pomodoroNotificationServiceProvider = Provider<NotificationService>((_) {
  throw UnimplementedError(
    'pomodoroNotificationServiceProvider must be overridden.',
  );
});
final pomodoroSnapshotStoreProvider = Provider<TimerSnapshotStore>((_) {
  throw UnimplementedError('pomodoroSnapshotStoreProvider must be overridden.');
});
final pomodoroRestoredSnapshotProvider = Provider<TimerSnapshot?>((_) => null);

enum PomodoroMode {
  focus('Focus'),
  shortBreak('Short break'),
  longBreak('Long break');

  const PomodoroMode(this.label);

  final String label;
}

extension PomodoroModeSession on PomodoroMode {
  TimerSession get session {
    switch (this) {
      case PomodoroMode.focus:
        return const TimerSession(
          id: 'focus',
          label: 'Focus',
          duration: Duration(minutes: 25),
          isTracked: true,
        );
      case PomodoroMode.shortBreak:
        return const TimerSession(
          id: 'shortBreak',
          label: 'Short break',
          duration: Duration(minutes: 5),
          isTracked: false,
        );
      case PomodoroMode.longBreak:
        return const TimerSession(
          id: 'longBreak',
          label: 'Long break',
          duration: Duration(minutes: 15),
          isTracked: false,
        );
    }
  }
}

PomodoroMode pomodoroModeFromSession(TimerSession session) {
  return pomodoroModeFromSessionId(session.id);
}

PomodoroMode pomodoroModeFromSessionId(String sessionId) {
  switch (sessionId) {
    case 'focus':
      return PomodoroMode.focus;
    case 'shortBreak':
      return PomodoroMode.shortBreak;
    case 'longBreak':
      return PomodoroMode.longBreak;
  }
  return PomodoroMode.focus;
}

class PomodoroController extends TimerController {
  @override
  TimerSession get initialSession => PomodoroMode.focus.session;

  @override
  TimerSnapshot? get restoredSnapshot => ref.read(
        pomodoroRestoredSnapshotProvider,
      );

  NotificationService get _notificationService =>
      ref.read(pomodoroNotificationServiceProvider);

  @override
  Future<void> persistSnapshot(TimerSnapshot snapshot) {
    return ref.read(pomodoroSnapshotStoreProvider).writeSnapshot(snapshot);
  }

  @override
  TimerSession restoreSession(String sessionId) {
    return pomodoroModeFromSessionId(sessionId).session;
  }

  void selectMode(PomodoroMode mode) {
    selectSession(mode.session);
  }

  void skipToNextMode() {
    skipToNextSession();
  }

  @override
  TimerSession resolveNextSession(TimerState completedState) {
    final currentMode = pomodoroModeFromSession(completedState.activeSession);
    final completedFocusSessions = completedState.stats.completedTrackedSessions;

    switch (currentMode) {
      case PomodoroMode.focus:
        return completedFocusSessions % 4 == 0
            ? PomodoroMode.longBreak.session
            : PomodoroMode.shortBreak.session;
      case PomodoroMode.shortBreak:
      case PomodoroMode.longBreak:
        return PomodoroMode.focus.session;
    }
  }

  @override
  Future<void> onTimerStarted(TimerState state) {
    final (String title, String body) = _notificationContentForSession(
      pomodoroModeFromSession(state.activeSession),
    );
    return _notificationService.scheduleNotification(
      id: pomodoroCompletionNotificationId,
      title: title,
      body: body,
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
      pomodoroCompletionNotificationId,
    );
  }

  (String, String) _notificationContentForSession(PomodoroMode mode) {
    switch (mode) {
      case PomodoroMode.focus:
        return ('Pomodoro Complete', 'Time for a break.');
      case PomodoroMode.shortBreak:
      case PomodoroMode.longBreak:
        return ('Break Complete', 'Time to focus again.');
    }
  }
}
