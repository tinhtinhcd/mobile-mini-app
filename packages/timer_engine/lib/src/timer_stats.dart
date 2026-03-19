import 'package:timer_engine/src/timer_session.dart';

class TimerHistoryEntry {
  const TimerHistoryEntry({
    required this.sessionId,
    required this.completedAtUtcMillis,
    required this.trackedMinutes,
  });

  factory TimerHistoryEntry.fromJson(Map<String, dynamic> json) {
    return TimerHistoryEntry(
      sessionId: json['sessionId'] as String,
      completedAtUtcMillis: (json['completedAtUtcMillis'] as num).toInt(),
      trackedMinutes: (json['trackedMinutes'] as num?)?.toInt() ?? 0,
    );
  }

  final String sessionId;
  final int completedAtUtcMillis;
  final int trackedMinutes;

  DateTime get completedAtLocal =>
      DateTime.fromMillisecondsSinceEpoch(
        completedAtUtcMillis,
        isUtc: true,
      ).toLocal();

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sessionId': sessionId,
      'completedAtUtcMillis': completedAtUtcMillis,
      'trackedMinutes': trackedMinutes,
    };
  }
}

class TimerStats {
  const TimerStats({
    this.completedTrackedSessions = 0,
    this.trackedMinutes = 0,
    this.history = const <TimerHistoryEntry>[],
  });

  static const int maxHistoryEntries = 60;

  final int completedTrackedSessions;
  final int trackedMinutes;
  final List<TimerHistoryEntry> history;

  int completedSessionsOnDay(DateTime day) {
    return entriesForDay(day).length;
  }

  int trackedMinutesOnDay(DateTime day) {
    return entriesForDay(day).fold<int>(
      0,
      (int sum, TimerHistoryEntry entry) => sum + entry.trackedMinutes,
    );
  }

  int completedSessionsLastDays(int days, {DateTime? referenceDate}) {
    return entriesForLastDays(days, referenceDate: referenceDate).length;
  }

  int trackedMinutesLastDays(int days, {DateTime? referenceDate}) {
    return entriesForLastDays(days, referenceDate: referenceDate).fold<int>(
      0,
      (int sum, TimerHistoryEntry entry) => sum + entry.trackedMinutes,
    );
  }

  int activeDaysLastDays(int days, {DateTime? referenceDate}) {
    final Set<DateTime> daysWithActivity = <DateTime>{};
    for (final TimerHistoryEntry entry in entriesForLastDays(
      days,
      referenceDate: referenceDate,
    )) {
      daysWithActivity.add(_dayKey(entry.completedAtLocal));
    }
    return daysWithActivity.length;
  }

  int streakDays({DateTime? referenceDate}) {
    final DateTime today = _dayKey(referenceDate ?? DateTime.now());
    final Set<DateTime> activeDays =
        history
            .map((TimerHistoryEntry entry) => _dayKey(entry.completedAtLocal))
            .toSet();

    int streak = 0;
    DateTime cursor = today;
    while (activeDays.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  List<TimerHistoryEntry> recentEntries({int limit = 3}) {
    final List<TimerHistoryEntry> sorted = List<TimerHistoryEntry>.from(history)
      ..sort(
        (TimerHistoryEntry a, TimerHistoryEntry b) =>
            b.completedAtUtcMillis.compareTo(a.completedAtUtcMillis),
      );
    if (sorted.length <= limit) {
      return sorted;
    }
    return sorted.sublist(0, limit);
  }

  List<TimerHistoryEntry> entriesForDay(DateTime day) {
    final DateTime target = _dayKey(day);
    return history
        .where(
          (TimerHistoryEntry entry) =>
              _dayKey(entry.completedAtLocal) == target,
        )
        .toList(growable: false);
  }

  List<TimerHistoryEntry> entriesForLastDays(
    int days, {
    DateTime? referenceDate,
  }) {
    final DateTime end = _dayKey(referenceDate ?? DateTime.now());
    final DateTime start = end.subtract(Duration(days: days - 1));
    return history
        .where((TimerHistoryEntry entry) {
          final DateTime day = _dayKey(entry.completedAtLocal);
          return !day.isBefore(start) && !day.isAfter(end);
        })
        .toList(growable: false);
  }

  TimerStats recordCompletion(TimerSession session, {DateTime? completedAt}) {
    if (!session.isTracked) {
      return this;
    }

    final TimerHistoryEntry entry = TimerHistoryEntry(
      sessionId: session.id,
      completedAtUtcMillis:
          (completedAt ?? DateTime.now()).toUtc().millisecondsSinceEpoch,
      trackedMinutes: session.duration.inMinutes,
    );

    final List<TimerHistoryEntry> updatedHistory = <TimerHistoryEntry>[
      ...history,
      entry,
    ];
    if (updatedHistory.length > maxHistoryEntries) {
      updatedHistory.removeRange(0, updatedHistory.length - maxHistoryEntries);
    }

    return copyWith(
      completedTrackedSessions: completedTrackedSessions + 1,
      trackedMinutes: trackedMinutes + session.duration.inMinutes,
      history: updatedHistory,
    );
  }

  TimerStats copyWith({
    int? completedTrackedSessions,
    int? trackedMinutes,
    List<TimerHistoryEntry>? history,
  }) {
    return TimerStats(
      completedTrackedSessions:
          completedTrackedSessions ?? this.completedTrackedSessions,
      trackedMinutes: trackedMinutes ?? this.trackedMinutes,
      history: history ?? this.history,
    );
  }

  static DateTime _dayKey(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
