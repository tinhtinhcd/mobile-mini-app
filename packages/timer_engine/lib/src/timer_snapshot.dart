class TimerSnapshot {
  const TimerSnapshot({
    required this.sessionId,
    required this.remainingSeconds,
    required this.wasRunning,
    required this.completedTrackedSessions,
    required this.trackedMinutes,
  });

  factory TimerSnapshot.fromJson(Map<String, dynamic> json) {
    return TimerSnapshot(
      sessionId: json['sessionId'] as String,
      remainingSeconds: (json['remainingSeconds'] as num).toInt(),
      wasRunning: json['wasRunning'] as bool? ?? false,
      completedTrackedSessions:
          (json['completedTrackedSessions'] as num?)?.toInt() ?? 0,
      trackedMinutes: (json['trackedMinutes'] as num?)?.toInt() ?? 0,
    );
  }

  final String sessionId;
  final int remainingSeconds;
  final bool wasRunning;
  final int completedTrackedSessions;
  final int trackedMinutes;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sessionId': sessionId,
      'remainingSeconds': remainingSeconds,
      'wasRunning': wasRunning,
      'completedTrackedSessions': completedTrackedSessions,
      'trackedMinutes': trackedMinutes,
    };
  }
}
