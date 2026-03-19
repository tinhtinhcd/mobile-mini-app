import 'package:habit_engine/src/models/habit_session.dart';

class HabitSessionRecord extends HabitSession {
  const HabitSessionRecord({
    required super.type,
    required super.completedAtUtcMillis,
    required super.durationMinutes,
  });

  factory HabitSessionRecord.fromJson(Map<String, dynamic> json) {
    return HabitSessionRecord(
      type: json['type'] as String? ?? 'session',
      completedAtUtcMillis: (json['completedAtUtcMillis'] as num).toInt(),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
    );
  }
}
