class HabitSession {
  const HabitSession({
    required this.type,
    required this.completedAtUtcMillis,
    required this.durationMinutes,
  });

  factory HabitSession.fromJson(Map<String, dynamic> json) {
    return HabitSession(
      type: json['type'] as String? ?? 'session',
      completedAtUtcMillis: (json['completedAtUtcMillis'] as num).toInt(),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
    );
  }

  final String type;
  final int completedAtUtcMillis;
  final int durationMinutes;

  DateTime get completedAtLocal =>
      DateTime.fromMillisecondsSinceEpoch(
        completedAtUtcMillis,
        isUtc: true,
      ).toLocal();

  Duration get duration => Duration(minutes: durationMinutes);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'completedAtUtcMillis': completedAtUtcMillis,
      'durationMinutes': durationMinutes,
    };
  }
}
