import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:timer_engine/src/timer_snapshot.dart';
import 'package:timer_engine/src/timer_session.dart';
import 'package:timer_engine/src/timer_state.dart';
import 'package:timer_engine/src/timer_stats.dart';

abstract class TimerController extends Notifier<TimerState> {
  Timer? _timer;

  TimerSession get initialSession;

  TimerSnapshot? get restoredSnapshot => null;

  Future<void> persistSnapshot(TimerSnapshot snapshot) async {}

  TimerSession restoreSession(String sessionId);

  TimerSession resolveNextSession(TimerState completedState);

  @override
  TimerState build() {
    ref.onDispose(() => _timer?.cancel());

    final TimerSnapshot? snapshot = restoredSnapshot;
    if (snapshot == null) {
      return TimerState.initial(session: initialSession);
    }

    final TimerState restoredState = TimerState.restored(
      session: restoreSession(snapshot.sessionId),
      snapshot: snapshot,
    );
    unawaited(persistSnapshot(restoredState.toSnapshot()));
    return restoredState;
  }

  void start() {
    _timer?.cancel();
    _setState(state.copyWith(isRunning: true));
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  void pause() {
    _timer?.cancel();
    _setState(state.copyWith(isRunning: false));
  }

  void toggleTimer() {
    if (state.isRunning) {
      pause();
      return;
    }

    start();
  }

  void reset() {
    _timer?.cancel();
    _setState(state.copyWith(
      isRunning: false,
      remaining: state.activeSession.duration,
    ));
  }

  void selectSession(TimerSession session) {
    _timer?.cancel();
    _moveToSession(session);
  }

  void skipToNextSession() {
    _timer?.cancel();
    _moveToSession(resolveNextSession(state));
  }

  void _tick() {
    if (state.remaining.inSeconds <= 1) {
      _completeSession();
      return;
    }

    _setState(state.copyWith(
      remaining: Duration(seconds: state.remaining.inSeconds - 1),
    ));
  }

  void _onTick(Timer _) {
    _tick();
  }

  void _completeSession() {
    _timer?.cancel();

    final updatedStats = _updatedStats(state.activeSession, state.stats);
    final completedState = state.copyWith(
      isRunning: false,
      remaining: Duration.zero,
      stats: updatedStats,
    );
    final nextSession = resolveNextSession(completedState);
    _setState(completedState.copyWith(
      activeSession: nextSession,
      remaining: nextSession.duration,
      isRunning: false,
    ));
  }

  void _moveToSession(TimerSession session) {
    _setState(state.copyWith(
      activeSession: session,
      remaining: session.duration,
      isRunning: false,
    ));
  }

  TimerStats _updatedStats(TimerSession session, TimerStats stats) {
    if (!session.isTracked) {
      return stats;
    }

    return stats.copyWith(
      completedTrackedSessions: stats.completedTrackedSessions + 1,
      trackedMinutes: stats.trackedMinutes + session.duration.inMinutes,
    );
  }

  void _setState(TimerState nextState) {
    state = nextState;
    unawaited(persistSnapshot(nextState.toSnapshot()));
  }
}
