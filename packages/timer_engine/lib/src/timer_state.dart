import 'package:timer_engine/src/timer_session.dart';
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
}

