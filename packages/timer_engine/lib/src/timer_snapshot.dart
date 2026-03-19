import 'package:timer_engine/src/timer_stats.dart';

class TimerSnapshot {
  const TimerSnapshot({
    required this.sessionId,
    required this.remainingSeconds,
    required this.wasRunning,
    required this.completedTrackedSessions,
    required this.trackedMinutes,
    this.history = const <TimerHistoryEntry>[],
  });

  factory TimerSnapshot.fromJson(Map<String, dynamic> json) {
    return TimerSnapshot(
      sessionId: json['sessionId'] as String,
      remainingSeconds: (json['remainingSeconds'] as num).toInt(),
      wasRunning: json['wasRunning'] as bool? ?? false,
      completedTrackedSessions:
          (json['completedTrackedSessions'] as num?)?.toInt() ?? 0,
      trackedMinutes: (json['trackedMinutes'] as num?)?.toInt() ?? 0,
      history:
          (json['history'] as List<dynamic>?)
              ?.whereType<Map<dynamic, dynamic>>()
              .map(
                (Map<dynamic, dynamic> entry) => TimerHistoryEntry.fromJson(
                  entry.map(
                    (dynamic key, dynamic value) =>
                        MapEntry(key.toString(), value),
                  ),
                ),
              )
              .toList(growable: false) ??
          const <TimerHistoryEntry>[],
    );
  }

  final String sessionId;
  final int remainingSeconds;
  final bool wasRunning;
  final int completedTrackedSessions;
  final int trackedMinutes;
  final List<TimerHistoryEntry> history;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sessionId': sessionId,
      'remainingSeconds': remainingSeconds,
      'wasRunning': wasRunning,
      'completedTrackedSessions': completedTrackedSessions,
      'trackedMinutes': trackedMinutes,
      'history': history
          .map((TimerHistoryEntry entry) => entry.toJson())
          .toList(growable: false),
    };
  }
}
