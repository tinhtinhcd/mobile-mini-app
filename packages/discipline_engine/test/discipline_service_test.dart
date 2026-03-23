import 'package:discipline_engine/discipline_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_engine/habit_engine.dart';

void main() {
  test('buildSnapshot returns a deterministic behind coaching state', () async {
    final HabitService habits = HabitService(
      repository: _FakeHabitRepository(
        sessions: const <HabitSession>[],
        goal: const HabitGoal(dailyTarget: 4, completedToday: 0),
        streak: HabitStreak(
          current: 5,
          longest: 5,
          lastActiveDay: DateTime(2026, 3, 21),
        ),
      ),
      defaultDailyGoal: 4,
    );
    await habits.initialize();

    final DisciplineSnapshot snapshot = const DisciplineService().buildSnapshot(
      habits: habits,
      rules: const _TestRules(),
      referenceDate: DateTime(2026, 3, 22, 21),
    );

    expect(snapshot.expectedCompleted, 3);
    expect(snapshot.status.type, DisciplineStatusType.behind);
    expect(snapshot.status.message, contains('3 steps behind'));
    expect(snapshot.pressure.streakAtRisk, isTrue);
    expect(snapshot.recoverySuggestion?.remainingActions, 4);
    expect(snapshot.paceGap, 3);
  });
}

class _TestRules extends DisciplineRules {
  const _TestRules();

  @override
  int expectedCompletedBy({
    required DisciplineGoal goal,
    required DateTime referenceDate,
  }) {
    return 3;
  }

  @override
  RecoverySuggestion? buildRecoverySuggestion({
    required DisciplineGoal goal,
    required DisciplinePressure pressure,
  }) {
    return RecoverySuggestion(
      remainingActions: pressure.gapToGoal,
      message: 'Complete ${pressure.gapToGoal} more actions today.',
    );
  }
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
    final DateTime now = DateTime.now();
    return DailySummary(
      day: DateTime(now.year, now.month, now.day),
      sessionCount: goal.completedToday,
      totalMinutes: 0,
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
    final DateTime now = DateTime.now();
    return DailySummary(
      day: DateTime(now.year, now.month, now.day),
      sessionCount: sessions.length,
      totalMinutes: sessions.fold<int>(
        0,
        (int sum, HabitSession session) => sum + session.durationMinutes,
      ),
    );
  }

  @override
  Future<void> saveGoal(HabitGoal goal) async {}

  @override
  Future<void> saveSession(HabitSession session) async {}

  @override
  Future<HabitStreak> updateStreak(DateTime activeDay) async => streak;
}
