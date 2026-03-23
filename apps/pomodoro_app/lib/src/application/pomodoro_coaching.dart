import 'package:discipline_engine/discipline_engine.dart';
import 'package:habit_engine/habit_engine.dart';
import 'package:pomodoro_app/src/application/pomodoro_controller.dart';
import 'package:pomodoro_app/src/application/pomodoro_discipline_rules.dart';

class PomodoroReviewEntry {
  const PomodoroReviewEntry({
    required this.label,
    required this.value,
    required this.message,
  });

  final String label;
  final String value;
  final String message;
}

class PomodoroCoachingSnapshot {
  const PomodoroCoachingSnapshot({
    required this.discipline,
    required this.review,
    required this.suggestedPreset,
    required this.weeklyDelta,
    required this.reviewEntries,
    required this.recommendation,
  });

  final DisciplineSnapshot discipline;
  final HabitCoachingReport review;
  final PomodoroDurationPreset suggestedPreset;
  final int weeklyDelta;
  final List<PomodoroReviewEntry> reviewEntries;
  final String recommendation;

  String get goalProgressLabel {
    return '${discipline.goal.completed} / ${discipline.goal.target} sessions today';
  }

  String get goalProgressSummary {
    if (discipline.goal.remaining == 0) {
      return 'Daily goal reached. Keep the next session easy tomorrow.';
    }
    final String noun = discipline.goal.remaining == 1 ? 'session' : 'sessions';
    return '${discipline.goal.remaining} more $noun to hit today\'s goal.';
  }

  String get reviewTeaser {
    final PomodoroReviewEntry entry = reviewEntries.first;
    return '${entry.label}: ${entry.value}. ${entry.message}';
  }
}

class PomodoroCoachingService {
  const PomodoroCoachingService({
    this.habitCoachingEngine = const HabitCoachingEngine(),
    this.disciplineService = const DisciplineService(),
    this.rules = const PomodoroDisciplineRules(),
  });

  final HabitCoachingEngine habitCoachingEngine;
  final DisciplineService disciplineService;
  final PomodoroDisciplineRules rules;

  PomodoroCoachingSnapshot build({
    required HabitService habits,
    DateTime? referenceDate,
  }) {
    final HabitCoachingReport review = habitCoachingEngine.build(
      habits: habits,
      referenceDate: referenceDate,
    );
    final DisciplineSnapshot discipline = disciplineService.buildSnapshot(
      habits: habits,
      rules: rules,
      referenceDate: referenceDate,
      suggestedTarget: review.suggestedDailyGoal,
    );
    final PomodoroDurationPreset suggestedPreset = _suggestedPreset(
      review: review,
    );
    final int weeklyDelta = review.weeklyCount - review.previousWeekCount;

    return PomodoroCoachingSnapshot(
      discipline: discipline,
      review: review,
      suggestedPreset: suggestedPreset,
      weeklyDelta: weeklyDelta,
      reviewEntries: <PomodoroReviewEntry>[
        PomodoroReviewEntry(
          label: 'Best focus window',
          value: review.bestTimeBucket?.label ?? 'Learning',
          message:
              review.bestTimeBucket == null
                  ? 'Complete a few more sessions before the strongest window becomes reliable.'
                  : 'Protect this slot first before adding more volume.',
        ),
        PomodoroReviewEntry(
          label: 'Consistency score',
          value: '${review.weeklyConsistencyScore}%',
          message: '${review.activeDays}/7 active days this week.',
        ),
        PomodoroReviewEntry(
          label: 'Improvement',
          value: _weeklyDeltaLabel(weeklyDelta),
          message: review.trendInsight,
        ),
      ],
      recommendation:
          'Recommended today: ${discipline.goal.suggestedTarget} focus sessions at ${suggestedPreset.shortLabel}.',
    );
  }

  PomodoroDurationPreset _suggestedPreset({
    required HabitCoachingReport review,
  }) {
    if (review.weeklyCount == 0) {
      return PomodoroDurationPreset.classic;
    }

    final double averageMinutes = review.weeklyMinutes / review.weeklyCount;
    if (review.weeklyConsistencyScore >= 92 && averageMinutes >= 40) {
      return PomodoroDurationPreset.marathon;
    }
    if (review.weeklyConsistencyScore >= 75 && averageMinutes >= 28) {
      return PomodoroDurationPreset.deep;
    }
    return PomodoroDurationPreset.classic;
  }

  String _weeklyDeltaLabel(int weeklyDelta) {
    if (weeklyDelta > 0) {
      return '+$weeklyDelta sessions';
    }
    if (weeklyDelta < 0) {
      return '$weeklyDelta sessions';
    }
    return 'Steady';
  }
}
