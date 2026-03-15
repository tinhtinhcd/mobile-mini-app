class TimerStats {
  const TimerStats({
    this.completedTrackedSessions = 0,
    this.trackedMinutes = 0,
  });

  final int completedTrackedSessions;
  final int trackedMinutes;

  TimerStats copyWith({
    int? completedTrackedSessions,
    int? trackedMinutes,
  }) {
    return TimerStats(
      completedTrackedSessions:
          completedTrackedSessions ?? this.completedTrackedSessions,
      trackedMinutes: trackedMinutes ?? this.trackedMinutes,
    );
  }
}

