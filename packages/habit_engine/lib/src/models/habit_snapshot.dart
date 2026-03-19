import 'package:habit_engine/src/models/habit_session_record.dart';

class HabitSnapshot {
  const HabitSnapshot({
    required this.dailyGoal,
    required this.currentStreak,
    required this.longestStreak,
    required this.records,
    this.lastActiveDayUtcMillis,
  });

  factory HabitSnapshot.initial({required int dailyGoal}) {
    return HabitSnapshot(
      dailyGoal: dailyGoal,
      currentStreak: 0,
      longestStreak: 0,
      records: const <HabitSessionRecord>[],
    );
  }

  factory HabitSnapshot.fromJson(Map<String, dynamic> json) {
    return HabitSnapshot(
      dailyGoal: (json['dailyGoal'] as num?)?.toInt() ?? 1,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      lastActiveDayUtcMillis: (json['lastActiveDayUtcMillis'] as num?)?.toInt(),
      records:
          (json['records'] as List<dynamic>?)
              ?.whereType<Map<dynamic, dynamic>>()
              .map(
                (Map<dynamic, dynamic> entry) => HabitSessionRecord.fromJson(
                  entry.map(
                    (dynamic key, dynamic value) =>
                        MapEntry(key.toString(), value),
                  ),
                ),
              )
              .toList(growable: false) ??
          const <HabitSessionRecord>[],
    );
  }

  static const int maxRecords = 120;

  final int dailyGoal;
  final int currentStreak;
  final int longestStreak;
  final int? lastActiveDayUtcMillis;
  final List<HabitSessionRecord> records;

  HabitSnapshot copyWith({
    int? dailyGoal,
    int? currentStreak,
    int? longestStreak,
    int? lastActiveDayUtcMillis,
    List<HabitSessionRecord>? records,
  }) {
    return HabitSnapshot(
      dailyGoal: dailyGoal ?? this.dailyGoal,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDayUtcMillis:
          lastActiveDayUtcMillis ?? this.lastActiveDayUtcMillis,
      records: records ?? this.records,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'dailyGoal': dailyGoal,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDayUtcMillis': lastActiveDayUtcMillis,
      'records': records
          .map((HabitSessionRecord entry) => entry.toJson())
          .toList(growable: false),
    };
  }
}
