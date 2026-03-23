import 'package:flutter_test/flutter_test.dart';
import 'package:habit_engine/habit_engine.dart';
import 'package:pomodoro_app/src/application/pomodoro_coaching.dart';
import 'package:pomodoro_app/src/application/pomodoro_controller.dart';

void main() {
  test('build returns premium review data and a suggested preset', () async {
    final HabitService habits = HabitService(
      repository: _FakeHabitRepository(
        sessions: _buildSessions(),
        goal: const HabitGoal(dailyTarget: 4, completedToday: 4),
        streak: HabitStreak(
          current: 7,
          longest: 7,
          lastActiveDay: DateTime(2026, 3, 22),
        ),
      ),
      defaultDailyGoal: 4,
    );
    await habits.initialize();

    final PomodoroCoachingSnapshot snapshot = const PomodoroCoachingService()
        .build(habits: habits, referenceDate: DateTime(2026, 3, 22, 12));

    expect(snapshot.suggestedPreset, PomodoroDurationPreset.marathon);
    expect(snapshot.reviewEntries, hasLength(3));
    expect(snapshot.reviewEntries.first.label, 'Best focus window');
    expect(snapshot.reviewEntries.first.value, 'Morning');
    expect(snapshot.weeklyDelta, 7);
    expect(snapshot.recommendation, contains('5 focus sessions'));
  });
}

List<HabitSession> _buildSessions() {
  final List<HabitSession> sessions = <HabitSession>[];
  final DateTime reference = DateTime(2026, 3, 22);

  for (int offset = 0; offset < 7; offset++) {
    final DateTime day = reference.subtract(Duration(days: offset));
    for (int hour = 8; hour < 12; hour++) {
      sessions.add(_session(day, hour, 50));
    }
  }

  for (int offset = 7; offset < 14; offset++) {
    final DateTime day = reference.subtract(Duration(days: offset));
    for (int hour = 9; hour < 12; hour++) {
      sessions.add(_session(day, hour, 35));
    }
  }

  return sessions;
}

HabitSession _session(DateTime day, int hour, int durationMinutes) {
  return HabitSession(
    type: 'focus',
    completedAtUtcMillis:
        DateTime(
          day.year,
          day.month,
          day.day,
          hour,
        ).toUtc().millisecondsSinceEpoch,
    durationMinutes: durationMinutes,
  );
}

class _FakeHabitRepository implements HabitRepository {
  _FakeHabitRepository({
    required this.sessions,
    required this.goal,
    required this.streak,
  });

  final List<HabitSession> sessions;
  final HabitGoal goal;
  final HabitStreak streak;

  @override
  Future<DailySummary> getTodaySummary() async {
    return DailySummary(
      day: DateTime(2026, 3, 22),
      sessionCount: goal.completedToday,
      totalMinutes: sessions
          .where((HabitSession session) {
            final DateTime day = session.completedAtLocal;
            return day.year == 2026 && day.month == 3 && day.day == 22;
          })
          .fold<int>(
            0,
            (int sum, HabitSession session) => sum + session.durationMinutes,
          ),
    );
  }

  @override
  Future<HabitGoal> getGoal() async => goal;

  @override
  Future<List<HabitSession>> getSessions({
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    return sessions;
  }

  @override
  Future<HabitStreak> getStreak() async => streak;

  @override
  Future<DailySummary> getWeeklySummary() async {
    return DailySummary(
      day: DateTime(2026, 3, 22),
      sessionCount: 28,
      totalMinutes: 1400,
    );
  }

  @override
  Future<void> saveGoal(HabitGoal goal) async {}

  @override
  Future<void> saveSession(HabitSession session) async {}

  @override
  Future<HabitStreak> updateStreak(DateTime activeDay) async => streak;
}
