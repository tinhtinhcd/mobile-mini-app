import 'package:discipline_engine/src/models/discipline_goal.dart';
import 'package:discipline_engine/src/models/discipline_pressure.dart';
import 'package:discipline_engine/src/models/discipline_status.dart';
import 'package:discipline_engine/src/models/recovery_suggestion.dart';
import 'package:discipline_engine/src/rules/discipline_rules.dart';
import 'package:habit_engine/habit_engine.dart';

class DisciplineService {
  const DisciplineService();

  DisciplineGoal readGoal({
    required HabitService habits,
    required DisciplineRules rules,
    DateTime? referenceDate,
    int? suggestedTarget,
  }) {
    final DateTime reference = _dayKey(referenceDate ?? DateTime.now());
    final int completed = habits.countForDay(reference);
    final int target = habits.dailyGoal;
    final int remaining = _remaining(target: target, completed: completed);
    return DisciplineGoal(
      target: target,
      completed: completed,
      remaining: remaining,
      suggestedTarget: suggestedTarget ?? target,
    );
  }

  DisciplineStatus computeStatus({
    required DisciplineGoal goal,
    required DisciplineRules rules,
    DateTime? referenceDate,
  }) {
    final DateTime reference = referenceDate ?? DateTime.now();
    if (goal.completed >= goal.target) {
      return const DisciplineStatus(
        type: DisciplineStatusType.completed,
        label: 'Goal completed',
        message: 'Today is covered. Keep the habit alive tomorrow.',
      );
    }

    final int expectedCompleted = rules.expectedCompletedBy(
      goal: goal,
      referenceDate: reference,
    );
    if (goal.completed == 0 && expectedCompleted == 0) {
      return const DisciplineStatus(
        type: DisciplineStatusType.notStarted,
        label: 'Not started',
        message:
            'Today is still open. Start before the day gets away from you.',
      );
    }
    if (goal.completed >= expectedCompleted) {
      return const DisciplineStatus(
        type: DisciplineStatusType.onTrack,
        label: 'You are on track',
        message: 'Your pace still supports the goal.',
      );
    }
    return DisciplineStatus(
      type: DisciplineStatusType.behind,
      label: 'You are behind',
      message: 'You are $expectedCompleted behind the pace for today.',
    );
  }

  DisciplinePressure computePressure({
    required HabitService habits,
    required DisciplineGoal goal,
    required DisciplineStatus status,
    DateTime? referenceDate,
  }) {
    final DateTime reference = referenceDate ?? DateTime.now();
    final bool streakAtRisk =
        habits.currentStreak > 0 &&
        goal.completed == 0 &&
        reference.hour >= 18 &&
        status.type != DisciplineStatusType.completed;
    final String? warningMessage =
        status.type == DisciplineStatusType.behind
            ? reference.hour >= 20
                ? 'Urgency is rising. Move now if you want to keep today alive.'
                : 'You are behind today. A small action now will stop the slide.'
            : null;
    final String? streakMessage =
        streakAtRisk
            ? 'Your ${habits.currentStreak}-day streak is at risk today.'
            : null;

    return DisciplinePressure(
      gapToGoal: goal.remaining,
      streakAtRisk: streakAtRisk,
      currentStreak: habits.currentStreak,
      warningMessage: warningMessage,
      streakMessage: streakMessage,
    );
  }

  RecoverySuggestion? computeRecoverySuggestion({
    required DisciplineGoal goal,
    required DisciplineStatus status,
    required DisciplinePressure pressure,
    required DisciplineRules rules,
  }) {
    if (status.type != DisciplineStatusType.behind || pressure.gapToGoal <= 0) {
      return null;
    }
    return rules.buildRecoverySuggestion(goal: goal, pressure: pressure);
  }

  int _remaining({required int target, required int completed}) {
    final int remaining = target - completed;
    return remaining > 0 ? remaining : 0;
  }

  DateTime _dayKey(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
