import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storage/storage.dart';
import 'package:timer_engine/timer_engine.dart';

final pomodoroControllerProvider =
    NotifierProvider<PomodoroController, TimerState>(PomodoroController.new);
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
}
