import 'package:habit_engine/src/models/habit_coaching_report.dart';
import 'package:habit_engine/src/models/habit_session_record.dart';
import 'package:habit_engine/src/services/habit_service.dart';

class HabitCoachingEngine {
  const HabitCoachingEngine();

  HabitCoachingReport build({
    required HabitService habits,
    DateTime? referenceDate,
  }) {
    final DateTime reference = _dayKey(referenceDate ?? DateTime.now());
    final int todayCount = habits.countForDay(reference);
    final List<HabitSessionRecord> weeklyEntries = habits.recordsForLastDays(
      7,
      referenceDate: reference,
    );
    final List<HabitSessionRecord> recentEntries = habits.recordsForLastDays(
      21,
      referenceDate: reference,
    );
    final List<HabitSessionRecord> previousWeekEntries = _previousWeekEntries(
      habits: habits,
      referenceDate: reference,
    );
    final int weeklyCount = weeklyEntries.length;
    final int weeklyMinutes = _totalMinutes(weeklyEntries);
    final int previousWeekCount = previousWeekEntries.length;
    final int previousWeekMinutes = _totalMinutes(previousWeekEntries);
    final int activeDays = _activeDays(weeklyEntries);
    final int consistencyScore = _weeklyConsistencyScore(
      weeklyCount: weeklyCount,
      activeDays: activeDays,
      dailyGoal: habits.dailyGoal,
    );
    final HabitTrendDirection trendDirection = _trendDirection(
      weeklyCount: weeklyCount,
      previousWeekCount: previousWeekCount,
      dailyGoal: habits.dailyGoal,
    );
    final HabitTimeBucket? bestTimeBucket = _bestTimeBucket(recentEntries);
    final int suggestedDailyGoal = _suggestDailyGoal(
      habits: habits,
      referenceDate: reference,
      weeklyCount: weeklyCount,
      activeDays: activeDays,
    );
    final int remainingToday = _remainingToday(
      dailyGoal: habits.dailyGoal,
      todayCount: todayCount,
    );
    final HabitProgressStatus progressStatus = _progressStatus(
      referenceDate: referenceDate ?? DateTime.now(),
      dailyGoal: habits.dailyGoal,
      todayCount: todayCount,
    );
    final bool isStreakAtRisk = _isStreakAtRisk(
      habits: habits,
      referenceDate: referenceDate ?? DateTime.now(),
      todayCount: todayCount,
    );

    return HabitCoachingReport(
      dailyGoal: habits.dailyGoal,
      todayCount: todayCount,
      remainingToday: remainingToday,
      progressStatus: progressStatus,
      progressLabel: _progressLabel(progressStatus),
      progressMessage: _progressMessage(
        progressStatus: progressStatus,
        remainingToday: remainingToday,
      ),
      isStreakAtRisk: isStreakAtRisk,
      weeklyConsistencyScore: consistencyScore,
      suggestedDailyGoal: suggestedDailyGoal,
      weeklyCount: weeklyCount,
      weeklyMinutes: weeklyMinutes,
      previousWeekCount: previousWeekCount,
      previousWeekMinutes: previousWeekMinutes,
      activeDays: activeDays,
      trendDirection: trendDirection,
      bestTimeBucket: bestTimeBucket,
      trendInsight: _trendInsight(
        trendDirection: trendDirection,
        weeklyCount: weeklyCount,
        previousWeekCount: previousWeekCount,
      ),
      bestTimeInsight: _bestTimeInsight(bestTimeBucket),
      patternInsight: _patternInsight(
        weeklyEntries: weeklyEntries,
        weeklyCount: weeklyCount,
        activeDays: activeDays,
        referenceDate: reference,
      ),
      goalInsight: _goalInsight(
        currentGoal: habits.dailyGoal,
        suggestedDailyGoal: suggestedDailyGoal,
        weeklyCount: weeklyCount,
      ),
      warningMessage: _warningMessage(
        progressStatus: progressStatus,
        referenceDate: referenceDate ?? DateTime.now(),
      ),
      streakMessage: _streakMessage(
        isStreakAtRisk: isStreakAtRisk,
        currentStreak: habits.currentStreak,
      ),
    );
  }

  List<HabitSessionRecord> _previousWeekEntries({
    required HabitService habits,
    required DateTime referenceDate,
  }) {
    final DateTime start = referenceDate.subtract(const Duration(days: 13));
    final DateTime end = referenceDate.subtract(const Duration(days: 7));
    return habits
        .recordsForLastDays(14, referenceDate: referenceDate)
        .where((HabitSessionRecord entry) {
          final DateTime day = _dayKey(entry.completedAtLocal);
          return !day.isBefore(start) && !day.isAfter(end);
        })
        .toList(growable: false);
  }

  int _totalMinutes(List<HabitSessionRecord> entries) {
    return entries.fold<int>(
      0,
      (int sum, HabitSessionRecord entry) => sum + entry.durationMinutes,
    );
  }

  int _activeDays(List<HabitSessionRecord> entries) {
    return entries
        .map(
          (HabitSessionRecord entry) => DateTime(
            entry.completedAtLocal.year,
            entry.completedAtLocal.month,
            entry.completedAtLocal.day,
          ),
        )
        .toSet()
        .length;
  }

  int _weeklyConsistencyScore({
    required int weeklyCount,
    required int activeDays,
    required int dailyGoal,
  }) {
    final double goalShare =
        dailyGoal <= 0 ? 0 : (weeklyCount / (dailyGoal * 7)).clamp(0, 1);
    final double spreadShare = activeDays / 7;
    return (((goalShare * 0.75) + (spreadShare * 0.25)) * 100).round();
  }

  int _remainingToday({required int dailyGoal, required int todayCount}) {
    final int remaining = dailyGoal - todayCount;
    return remaining > 0 ? remaining : 0;
  }

  HabitProgressStatus _progressStatus({
    required DateTime referenceDate,
    required int dailyGoal,
    required int todayCount,
  }) {
    if (todayCount >= dailyGoal) {
      return HabitProgressStatus.completed;
    }

    final int hour = referenceDate.hour;
    final int expectedCount;
    if (hour < 10) {
      expectedCount = 0;
    } else if (hour < 14) {
      expectedCount = dailyGoal > 1 ? 1 : 0;
    } else if (hour < 18) {
      expectedCount = ((dailyGoal * 0.5).ceil()).clamp(1, dailyGoal);
    } else if (hour < 21) {
      expectedCount = ((dailyGoal * 0.75).ceil()).clamp(1, dailyGoal);
    } else {
      expectedCount = dailyGoal;
    }

    return todayCount >= expectedCount
        ? HabitProgressStatus.onTrack
        : HabitProgressStatus.behind;
  }

  String _progressLabel(HabitProgressStatus progressStatus) {
    return switch (progressStatus) {
      HabitProgressStatus.completed => 'Goal completed',
      HabitProgressStatus.onTrack => 'You are on track',
      HabitProgressStatus.behind => 'You are behind',
    };
  }

  String _progressMessage({
    required HabitProgressStatus progressStatus,
    required int remainingToday,
  }) {
    return switch (progressStatus) {
      HabitProgressStatus.completed =>
        'Today is covered. Keep the streak alive by showing up again tomorrow.',
      HabitProgressStatus.onTrack =>
        'Your pace still supports the goal. Keep the next completion close to the same time.',
      HabitProgressStatus.behind =>
        'Today is slipping. $remainingToday more will get the goal back in reach.',
    };
  }

  String? _warningMessage({
    required HabitProgressStatus progressStatus,
    required DateTime referenceDate,
  }) {
    if (progressStatus != HabitProgressStatus.behind) {
      return null;
    }
    if (referenceDate.hour >= 20) {
      return 'Urgency is rising. Move now if you want to keep today alive.';
    }
    return 'You are behind today. A small action now will stop the slide.';
  }

  bool _isStreakAtRisk({
    required HabitService habits,
    required DateTime referenceDate,
    required int todayCount,
  }) {
    return habits.currentStreak > 0 &&
        todayCount == 0 &&
        referenceDate.hour >= 18;
  }

  String? _streakMessage({
    required bool isStreakAtRisk,
    required int currentStreak,
  }) {
    if (!isStreakAtRisk) {
      return null;
    }
    return 'Your $currentStreak-day streak is at risk today.';
  }

  HabitTrendDirection _trendDirection({
    required int weeklyCount,
    required int previousWeekCount,
    required int dailyGoal,
  }) {
    if (weeklyCount == 0 && previousWeekCount == 0) {
      return HabitTrendDirection.steady;
    }
    if (previousWeekCount == 0 && weeklyCount > 0) {
      return HabitTrendDirection.improving;
    }

    final int threshold = dailyGoal > 1 ? 2 : 1;
    final int delta = weeklyCount - previousWeekCount;
    if (delta >= threshold) {
      return HabitTrendDirection.improving;
    }
    if (delta <= -threshold) {
      return HabitTrendDirection.slipping;
    }
    return HabitTrendDirection.steady;
  }

  HabitTimeBucket? _bestTimeBucket(List<HabitSessionRecord> entries) {
    if (entries.length < 3) {
      return null;
    }

    final Map<HabitTimeBucket, int> buckets = <HabitTimeBucket, int>{
      HabitTimeBucket.morning: 0,
      HabitTimeBucket.afternoon: 0,
      HabitTimeBucket.evening: 0,
      HabitTimeBucket.late: 0,
    };

    for (final HabitSessionRecord entry in entries) {
      final int hour = entry.completedAtLocal.hour;
      if (hour < 12) {
        buckets[HabitTimeBucket.morning] =
            buckets[HabitTimeBucket.morning]! + 1;
      } else if (hour < 17) {
        buckets[HabitTimeBucket.afternoon] =
            buckets[HabitTimeBucket.afternoon]! + 1;
      } else if (hour < 21) {
        buckets[HabitTimeBucket.evening] =
            buckets[HabitTimeBucket.evening]! + 1;
      } else {
        buckets[HabitTimeBucket.late] = buckets[HabitTimeBucket.late]! + 1;
      }
    }

    return buckets.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  int _suggestDailyGoal({
    required HabitService habits,
    required DateTime referenceDate,
    required int weeklyCount,
    required int activeDays,
  }) {
    final int currentGoal = habits.dailyGoal;
    if (weeklyCount == 0) {
      return 1;
    }

    final double goalShare =
        currentGoal <= 0 ? 0 : weeklyCount / (currentGoal * 7);
    final double averagePerDay =
        habits.countForLastDays(14, referenceDate: referenceDate) / 14;
    final int roundedAverage = averagePerDay.round().clamp(1, currentGoal + 1);

    if (goalShare >= 1 && activeDays >= 5) {
      return currentGoal + 1;
    }
    if (goalShare < 0.5 && currentGoal > 1) {
      return currentGoal - 1;
    }
    return roundedAverage;
  }

  String _trendInsight({
    required HabitTrendDirection trendDirection,
    required int weeklyCount,
    required int previousWeekCount,
  }) {
    if (weeklyCount == 0 && previousWeekCount == 0) {
      return 'No weekly trend yet. Finish one session today and the coaching layer will start learning your rhythm.';
    }

    return switch (trendDirection) {
      HabitTrendDirection.improving =>
        'You improved versus last week. Keep the same rhythm while momentum is working.',
      HabitTrendDirection.slipping =>
        'This week is behind last week. Return to your easiest repeatable session to recover momentum.',
      HabitTrendDirection.steady =>
        'You are holding close to last week. Consistency, not intensity, is the clearest next gain.',
    };
  }

  String _bestTimeInsight(HabitTimeBucket? bestTimeBucket) {
    if (bestTimeBucket == null) {
      return 'Need a few more completed sessions before the best time of day becomes clear.';
    }
    return 'Your strongest window is ${bestTimeBucket.label}. Protect that slot first before adding more volume.';
  }

  String _patternInsight({
    required List<HabitSessionRecord> weeklyEntries,
    required int weeklyCount,
    required int activeDays,
    required DateTime referenceDate,
  }) {
    if (weeklyCount == 0) {
      return 'No stable pattern yet. Start with one easy completion today and repeat it tomorrow.';
    }

    final int longestGap = _longestGapDays(
      weeklyEntries: weeklyEntries,
      referenceDate: referenceDate,
    );
    final int weekendCompletions =
        weeklyEntries.where((HabitSessionRecord entry) {
          final int weekday = entry.completedAtLocal.weekday;
          return weekday == DateTime.saturday || weekday == DateTime.sunday;
        }).length;

    if (longestGap >= 2) {
      return 'The common drop-off happens after $longestGap inactive days. Keep a minimum version ready before the gap grows.';
    }
    if (weekendCompletions == 0 && activeDays >= 3) {
      return 'Weekends are the weak spot right now. Plan a lighter version for Saturday or Sunday.';
    }
    if (activeDays < 5) {
      return 'Missed days are costing more than short sessions. Showing up briefly will help more than pushing harder.';
    }
    return 'Your pattern is stable. Repeating the same start window is the easiest next improvement.';
  }

  int _longestGapDays({
    required List<HabitSessionRecord> weeklyEntries,
    required DateTime referenceDate,
  }) {
    final Set<DateTime> completedDays =
        weeklyEntries
            .map((HabitSessionRecord entry) => _dayKey(entry.completedAtLocal))
            .toSet();

    int currentGap = 0;
    int longestGap = 0;
    for (int offset = 6; offset >= 0; offset--) {
      final DateTime day = referenceDate.subtract(Duration(days: offset));
      if (completedDays.contains(day)) {
        currentGap = 0;
        continue;
      }
      currentGap += 1;
      if (currentGap > longestGap) {
        longestGap = currentGap;
      }
    }
    return longestGap;
  }

  String _goalInsight({
    required int currentGoal,
    required int suggestedDailyGoal,
    required int weeklyCount,
  }) {
    if (weeklyCount == 0) {
      return 'Suggested goal today: 1. Start with the smallest win and rebuild the loop.';
    }
    if (suggestedDailyGoal > currentGoal) {
      return 'Suggested goal today: $suggestedDailyGoal. You are clearing the current target often enough to stretch a little.';
    }
    if (suggestedDailyGoal < currentGoal) {
      return 'Suggested goal today: $suggestedDailyGoal. Lower the target slightly and rebuild consistency before pushing again.';
    }
    return 'Suggested goal today: $suggestedDailyGoal. Hold the current target and repeat the pattern before changing it.';
  }

  DateTime _dayKey(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
