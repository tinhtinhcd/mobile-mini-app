import 'package:discipline_engine/discipline_engine.dart';
import 'package:fasting_app/src/application/fasting_discipline_rules.dart';
import 'package:fasting_app/src/domain/fasting_plan.dart';
import 'package:habit_engine/habit_engine.dart';
import 'package:timer_engine/timer_engine.dart';

class FastingReviewEntry {
  const FastingReviewEntry({
    required this.label,
    required this.value,
    required this.message,
  });

  final String label;
  final String value;
  final String message;
}

class FastingCoachingSnapshot {
  const FastingCoachingSnapshot({
    required this.discipline,
    required this.review,
    required this.selectedPlan,
    required this.suggestedPlan,
    required this.targetDuration,
    required this.achievedDurationToday,
    required this.durationStatus,
    required this.durationStatusMessage,
    required this.warningMessage,
    required this.streakMessage,
    required this.recoveryMessage,
    required this.reviewEntries,
    required this.recommendation,
  });

  final DisciplineSnapshot discipline;
  final HabitCoachingReport review;
  final FastingPlan selectedPlan;
  final FastingPlan suggestedPlan;
  final Duration targetDuration;
  final Duration achievedDurationToday;
  final DisciplineStatusType durationStatus;
  final String durationStatusMessage;
  final String? warningMessage;
  final String? streakMessage;
  final String? recoveryMessage;
  final List<FastingReviewEntry> reviewEntries;
  final String recommendation;

  String get goalProgressLabel {
    return '${_hoursLabel(achievedDurationToday)} / ${_hoursLabel(targetDuration)} target';
  }

  String get goalProgressSummary {
    final Duration remaining = targetDuration - achievedDurationToday;
    if (remaining <= Duration.zero) {
      return 'Today\'s fasting target is covered.';
    }
    return '${_hoursLabel(remaining)} left in today\'s target.';
  }

  String get reviewTeaser {
    final FastingReviewEntry entry = reviewEntries.first;
    return '${entry.label}: ${entry.value}. ${entry.message}';
  }

  String _hoursLabel(Duration duration) {
    final double hours = duration.inMinutes / 60;
    return hours == hours.roundToDouble()
        ? '${hours.round()}h'
        : '${hours.toStringAsFixed(1)}h';
  }
}

class FastingCoachingService {
  const FastingCoachingService({
    this.habitCoachingEngine = const HabitCoachingEngine(),
    this.disciplineService = const DisciplineService(),
    this.rules = const FastingDisciplineRules(),
  });

  final HabitCoachingEngine habitCoachingEngine;
  final DisciplineService disciplineService;
  final FastingDisciplineRules rules;

  FastingCoachingSnapshot build({
    required HabitService habits,
    required TimerState state,
    required FastingPlan selectedPlan,
    DateTime? referenceDate,
  }) {
    final DateTime reference = referenceDate ?? DateTime.now();
    final HabitCoachingReport review = habitCoachingEngine.build(
      habits: habits,
      referenceDate: reference,
    );
    final DisciplineSnapshot discipline = disciplineService.buildSnapshot(
      habits: habits,
      rules: rules,
      referenceDate: reference,
      suggestedTarget: review.suggestedDailyGoal,
    );
    final Duration targetDuration = selectedPlan.fastingDuration;
    final Duration achievedDurationToday = _achievedDurationToday(
      habits: habits,
      state: state,
      referenceDate: reference,
    );
    final DisciplineStatusType durationStatus = _durationStatus(
      achievedDurationToday: achievedDurationToday,
      targetDuration: targetDuration,
      referenceDate: reference,
    );
    final FastingPlan suggestedPlan = _suggestedPlan(
      review: review,
      weeklyMinutes: review.weeklyMinutes,
      weeklyCount: review.weeklyCount,
    );
    final String? warningMessage = _warningMessage(
      durationStatus: durationStatus,
      referenceDate: reference,
    );
    final String? streakMessage = discipline.pressure.streakMessage;
    final String? recoveryMessage = _recoveryMessage(
      achievedDurationToday: achievedDurationToday,
      targetDuration: targetDuration,
      durationStatus: durationStatus,
      referenceDate: reference,
    );

    return FastingCoachingSnapshot(
      discipline: discipline,
      review: review,
      selectedPlan: selectedPlan,
      suggestedPlan: suggestedPlan,
      targetDuration: targetDuration,
      achievedDurationToday: achievedDurationToday,
      durationStatus: durationStatus,
      durationStatusMessage: _durationStatusMessage(
        durationStatus: durationStatus,
        targetDuration: targetDuration,
        achievedDurationToday: achievedDurationToday,
      ),
      warningMessage: warningMessage,
      streakMessage: streakMessage,
      recoveryMessage: recoveryMessage,
      reviewEntries: <FastingReviewEntry>[
        FastingReviewEntry(
          label: 'Longest fast',
          value: _hoursLabel(_longestFastDuration(habits)),
          message: 'Best completed fast in your recent history.',
        ),
        FastingReviewEntry(
          label: 'Consistency score',
          value: '${review.weeklyConsistencyScore}%',
          message: '${review.activeDays}/7 active days this week.',
        ),
        FastingReviewEntry(
          label: 'Common break pattern',
          value: _breakPatternLabel(review.bestTimeBucket),
          message: _breakPatternMessage(review.bestTimeBucket),
        ),
        FastingReviewEntry(
          label: 'Suggested plan',
          value: suggestedPlan.label,
          message: _planAdjustmentMessage(
            suggestedPlan: suggestedPlan,
            selectedPlan: selectedPlan,
          ),
        ),
      ],
      recommendation:
          'Recommended today: ${suggestedPlan.label}. Keep the plan steady before stretching longer.',
    );
  }

  Duration _achievedDurationToday({
    required HabitService habits,
    required TimerState state,
    required DateTime referenceDate,
  }) {
    final Duration completedToday = habits.recordsForDay(referenceDate).fold(
      Duration.zero,
      (Duration currentBest, HabitSessionRecord record) {
        final Duration next = record.duration;
        return next > currentBest ? next : currentBest;
      },
    );
    final Duration currentProgress =
        state.activeSession.isTracked
            ? state.activeSession.duration - state.remaining
            : Duration.zero;
    return currentProgress > completedToday ? currentProgress : completedToday;
  }

  DisciplineStatusType _durationStatus({
    required Duration achievedDurationToday,
    required Duration targetDuration,
    required DateTime referenceDate,
  }) {
    if (achievedDurationToday >= targetDuration) {
      return DisciplineStatusType.completed;
    }

    final double expectedShare = switch (referenceDate.hour) {
      < 10 => 0,
      < 14 => 0.35,
      < 18 => 0.6,
      < 21 => 0.85,
      _ => 1,
    };
    final Duration expectedDuration = Duration(
      minutes: (targetDuration.inMinutes * expectedShare).round(),
    );

    if (achievedDurationToday == Duration.zero &&
        expectedDuration == Duration.zero) {
      return DisciplineStatusType.notStarted;
    }
    if (achievedDurationToday >= expectedDuration) {
      return DisciplineStatusType.onTrack;
    }
    return DisciplineStatusType.behind;
  }

  String _durationStatusMessage({
    required DisciplineStatusType durationStatus,
    required Duration targetDuration,
    required Duration achievedDurationToday,
  }) {
    final Duration remaining = targetDuration - achievedDurationToday;
    return switch (durationStatus) {
      DisciplineStatusType.completed => 'Today\'s fasting target is covered.',
      DisciplineStatusType.onTrack =>
        'Your current fasting pace still supports the target.',
      DisciplineStatusType.behind =>
        '${_hoursLabel(remaining)} still stands between you and today\'s target.',
      DisciplineStatusType.notStarted =>
        'Today is still open. Start the fast before the day slips away.',
    };
  }

  String? _warningMessage({
    required DisciplineStatusType durationStatus,
    required DateTime referenceDate,
  }) {
    if (durationStatus != DisciplineStatusType.behind) {
      return null;
    }
    if (referenceDate.hour >= 20) {
      return 'Your fasting target is late. Protect today with the smallest clean finish you can sustain.';
    }
    return 'You are behind today. A clean stretch now will keep the plan recoverable.';
  }

  String? _recoveryMessage({
    required Duration achievedDurationToday,
    required Duration targetDuration,
    required DisciplineStatusType durationStatus,
    required DateTime referenceDate,
  }) {
    if (durationStatus != DisciplineStatusType.behind) {
      return null;
    }

    final Duration remaining = targetDuration - achievedDurationToday;
    if (achievedDurationToday >= const Duration(hours: 6) &&
        remaining <= const Duration(hours: 6)) {
      return 'Finish the next ${_hoursLabel(remaining)} to complete today\'s ${_hoursLabel(targetDuration)} target.';
    }
    if (referenceDate.hour >= 18) {
      return 'Complete a ${FastingPlan.reset12.label} fast today to protect your streak.';
    }
    return 'Stay with your ${_hoursLabel(targetDuration)} target and protect the next ${_hoursLabel(remaining)}.';
  }

  Duration _longestFastDuration(HabitService habits) {
    final List<HabitSessionRecord> recentEntries = habits.recordsForLastDays(
      21,
    );
    if (recentEntries.isEmpty) {
      return Duration.zero;
    }
    return recentEntries
        .map((HabitSessionRecord record) => record.duration)
        .reduce((Duration left, Duration right) => left > right ? left : right);
  }

  FastingPlan _suggestedPlan({
    required HabitCoachingReport review,
    required int weeklyMinutes,
    required int weeklyCount,
  }) {
    if (weeklyCount == 0) {
      return FastingPlan.reset12;
    }

    final double averageHours = (weeklyMinutes / weeklyCount) / 60;
    if (review.weeklyConsistencyScore >= 92 && averageHours >= 19) {
      return FastingPlan.deep20;
    }
    if (review.weeklyConsistencyScore >= 78 && averageHours >= 17) {
      return FastingPlan.performance18;
    }
    if (review.weeklyConsistencyScore < 55) {
      return FastingPlan.reset12;
    }
    return FastingPlan.lean16;
  }

  String _breakPatternLabel(HabitTimeBucket? bucket) {
    if (bucket == null) {
      return 'Learning';
    }
    return switch (bucket) {
      HabitTimeBucket.morning => 'Morning breaks',
      HabitTimeBucket.afternoon => 'Afternoon breaks',
      HabitTimeBucket.evening => 'Evening breaks',
      HabitTimeBucket.late => 'Late breaks',
    };
  }

  String _breakPatternMessage(HabitTimeBucket? bucket) {
    if (bucket == null) {
      return 'A few more finished fasts will make the break pattern reliable.';
    }
    return 'Most fasts end in the ${bucket.label.toLowerCase()}. Keep meal timing steady around that window.';
  }

  String _planAdjustmentMessage({
    required FastingPlan suggestedPlan,
    required FastingPlan selectedPlan,
  }) {
    if (suggestedPlan == selectedPlan) {
      return 'Stay with the current plan until it feels easy on repeat.';
    }
    if (suggestedPlan.fastingDuration > selectedPlan.fastingDuration) {
      return 'You are consistent enough to stretch slightly beyond the current plan.';
    }
    return 'Step down briefly, rebuild consistency, then stretch longer again.';
  }

  String _hoursLabel(Duration duration) {
    final double hours = duration.inMinutes / 60;
    return hours == hours.roundToDouble()
        ? '${hours.round()}h'
        : '${hours.toStringAsFixed(1)}h';
  }
}
