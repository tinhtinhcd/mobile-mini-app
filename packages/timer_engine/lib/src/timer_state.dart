import 'package:timer_engine/src/timer_session.dart';
import 'package:timer_engine/src/timer_snapshot.dart';
import 'package:timer_engine/src/timer_stats.dart';

class TimerState {
  const TimerState({
    required this.activeSession,
    required this.remaining,
    required this.isRunning,
    required this.stats,
  });

  factory TimerState.initial({
    required TimerSession session,
  }) {
    return TimerState(
      activeSession: session,
      remaining: session.duration,
      isRunning: false,
      stats: const TimerStats(),
    );
  }

  factory TimerState.restored({
    required TimerSession session,
    required TimerSnapshot snapshot,
  }) {
    final int boundedRemainingSeconds;
    if (snapshot.remainingSeconds <= 0) {
      boundedRemainingSeconds = session.duration.inSeconds;
    } else if (snapshot.remainingSeconds > session.duration.inSeconds) {
      boundedRemainingSeconds = session.duration.inSeconds;
    } else {
      boundedRemainingSeconds = snapshot.remainingSeconds;
    }

    return TimerState(
      activeSession: session,
      remaining: Duration(seconds: boundedRemainingSeconds),
      isRunning: false,
      stats: TimerStats(
        completedTrackedSessions: snapshot.completedTrackedSessions,
        trackedMinutes: snapshot.trackedMinutes,
      ),
    );
  }

  final TimerSession activeSession;
  final Duration remaining;
  final bool isRunning;
  final TimerStats stats;

  double get progress {
    if (activeSession.duration.inSeconds == 0) {
      return 0;
    }

    final completedSeconds = activeSession.duration.inSeconds - remaining.inSeconds;
    return completedSeconds / activeSession.duration.inSeconds;
  }

  TimerState copyWith({
    TimerSession? activeSession,
    Duration? remaining,
    bool? isRunning,
    TimerStats? stats,
  }) {
    return TimerState(
      activeSession: activeSession ?? this.activeSession,
      remaining: remaining ?? this.remaining,
      isRunning: isRunning ?? this.isRunning,
      stats: stats ?? this.stats,
    );
  }

  TimerSnapshot toSnapshot() {
    return TimerSnapshot(
      sessionId: activeSession.id,
      remainingSeconds: remaining.inSeconds,
      wasRunning: isRunning,
      completedTrackedSessions: stats.completedTrackedSessions,
      trackedMinutes: stats.trackedMinutes,
    );
  }
}
