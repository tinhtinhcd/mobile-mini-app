import 'package:fasting_app/src/application/fasting_coaching.dart';
import 'package:fasting_app/src/domain/fasting_plan.dart';
import 'package:discipline_engine/discipline_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_engine/habit_engine.dart';
import 'package:timer_engine/timer_engine.dart';

void main() {
  test(
    'build returns duration progress and review insight for active fasts',
    () async {
      final HabitService habits = HabitService(
        repository: _FakeHabitRepository(
          sessions: _buildSessions(),
          goal: const HabitGoal(dailyTarget: 1, completedToday: 0),
          streak: HabitStreak(
            current: 5,
            longest: 8,
            lastActiveDay: DateTime(2026, 3, 21),
          ),
        ),
        defaultDailyGoal: 1,
      );
      await habits.initialize();

      final TimerState state = TimerState.initial(
        session: FastingPlan.lean16.session,
      ).copyWith(remaining: const Duration(hours: 4));

      final FastingCoachingSnapshot snapshot = const FastingCoachingService()
          .build(
            habits: habits,
            state: state,
            selectedPlan: FastingPlan.lean16,
            referenceDate: DateTime(2026, 3, 22, 17),
          );

      expect(snapshot.goalProgressLabel, '12h / 16h target');
      expect(snapshot.durationStatus, isNot(DisciplineStatusType.behind));
      expect(snapshot.reviewEntries, hasLength(4));
      expect(snapshot.reviewEntries.first.label, 'Longest fast');
      expect(snapshot.reviewEntries[2].label, 'Common break pattern');
      expect(snapshot.recommendation, contains(snapshot.suggestedPlan.label));
    },
  );
}

List<HabitSession> _buildSessions() {
  final List<HabitSession> sessions = <HabitSession>[];
  final DateTime reference = DateTime(2026, 3, 22);

  for (int offset = 1; offset <= 7; offset++) {
    final DateTime day = reference.subtract(Duration(days: offset));
    sessions.add(
      HabitSession(
        type: FastingPlan.lean16.name,
        completedAtUtcMillis:
            DateTime(
              day.year,
              day.month,
              day.day,
              11,
            ).toUtc().millisecondsSinceEpoch,
        durationMinutes: 16 * 60,
      ),
    );
  }

  sessions.add(
    HabitSession(
      type: FastingPlan.performance18.name,
      completedAtUtcMillis:
          DateTime(2026, 3, 20, 12).toUtc().millisecondsSinceEpoch,
      durationMinutes: 18 * 60,
    ),
  );

  return sessions;
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
      sessionCount: 0,
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
    return DailySummary(
      day: DateTime(2026, 3, 22),
      sessionCount: 7,
      totalMinutes: 16 * 60 * 7,
    );
  }

  @override
  Future<void> saveGoal(HabitGoal goal) async {}

  @override
  Future<void> saveSession(HabitSession session) async {}

  @override
  Future<HabitStreak> updateStreak(DateTime activeDay) async => streak;
}
