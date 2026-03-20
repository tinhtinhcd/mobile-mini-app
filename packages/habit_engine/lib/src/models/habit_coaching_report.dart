enum HabitTrendDirection { improving, steady, slipping }

enum HabitProgressStatus { onTrack, behind, completed }

enum HabitTimeBucket {
  morning('Morning'),
  afternoon('Afternoon'),
  evening('Evening'),
  late('Late');

  const HabitTimeBucket(this.label);

  final String label;
}

class HabitCoachingReport {
  const HabitCoachingReport({
    required this.dailyGoal,
    required this.todayCount,
    required this.remainingToday,
    required this.progressStatus,
    required this.progressLabel,
    required this.progressMessage,
    required this.isStreakAtRisk,
    required this.weeklyConsistencyScore,
    required this.suggestedDailyGoal,
    required this.weeklyCount,
    required this.weeklyMinutes,
    required this.previousWeekCount,
    required this.previousWeekMinutes,
    required this.activeDays,
    required this.trendDirection,
    required this.trendInsight,
    required this.bestTimeInsight,
    required this.patternInsight,
    required this.goalInsight,
    this.warningMessage,
    this.streakMessage,
    this.bestTimeBucket,
  });

  final int dailyGoal;
  final int todayCount;
  final int remainingToday;
  final HabitProgressStatus progressStatus;
  final String progressLabel;
  final String progressMessage;
  final bool isStreakAtRisk;
  final int weeklyConsistencyScore;
  final int suggestedDailyGoal;
  final int weeklyCount;
  final int weeklyMinutes;
  final int previousWeekCount;
  final int previousWeekMinutes;
  final int activeDays;
  final HabitTrendDirection trendDirection;
  final HabitTimeBucket? bestTimeBucket;
  final String trendInsight;
  final String bestTimeInsight;
  final String patternInsight;
  final String goalInsight;
  final String? warningMessage;
  final String? streakMessage;
}
