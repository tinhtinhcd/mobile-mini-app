import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_engine/habit_engine.dart';
import 'package:pomodoro_app/src/application/pomodoro_habits.dart';
import 'package:pomodoro_app/src/presentation/pomodoro_app_menu.dart';
import 'package:ui_kit/ui_kit.dart';

const String pomodoroWeeklySummaryPath = 'weekly-summary';

class PomodoroWeeklySummaryScreen extends ConsumerWidget {
  const PomodoroWeeklySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final HabitService habits = ref.watch(pomodoroHabitServiceProvider);
    final DateTime now = DateTime.now();
    final int weeklySessions = habits.weeklyCount;
    final int weeklyMinutes = habits.weeklyMinutes;
    final double averagePerDay = weeklySessions / 7;
    final int lastWeekSessions =
        habits.countForLastDays(14, referenceDate: now) - weeklySessions;
    final List<WeeklyBreakdownItem> breakdown = _buildBreakdown(habits, now);

    return FactoryScaffold(
      title: 'Weekly summary',
      appMenuSpec: pomodoroAppMenuSpec,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _weeklyNarrative(
              weeklySessions: weeklySessions,
              weeklyMinutes: weeklyMinutes,
              lastWeekSessions: lastWeekSessions,
            ),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: 'This week',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CompactStatStrip(
                  items: <CompactStatItem>[
                    CompactStatItem(
                      label: 'Total sessions',
                      value: '$weeklySessions',
                    ),
                    CompactStatItem(
                      label: 'Average/day',
                      value: averagePerDay.toStringAsFixed(1),
                    ),
                    CompactStatItem(
                      label: 'Focus time',
                      value: '${weeklyMinutes}m',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _weeklyGuidance(
                    weeklySessions: weeklySessions,
                    averagePerDay: averagePerDay,
                  ),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: 'Daily breakdown',
            subtitle: 'Small daily wins matter more than perfect days.',
            child: WeeklyBreakdownList(items: breakdown),
          ),
        ],
      ),
    );
  }

  List<WeeklyBreakdownItem> _buildBreakdown(
    HabitService habits,
    DateTime referenceDate,
  ) {
    final int maxCount = List<int>.generate(
      7,
      (int index) => habits.countForDay(
        DateTime(
          referenceDate.year,
          referenceDate.month,
          referenceDate.day,
        ).subtract(Duration(days: 6 - index)),
      ),
    ).fold<int>(1, (int max, int value) => value > max ? value : max);

    return List<WeeklyBreakdownItem>.generate(7, (int index) {
      final DateTime day = DateTime(
        referenceDate.year,
        referenceDate.month,
        referenceDate.day,
      ).subtract(Duration(days: 6 - index));
      final int sessions = habits.countForDay(day);
      final int minutes = habits.minutesForDay(day);
      return WeeklyBreakdownItem(
        label: _weekdayLabel(day),
        primaryValue: '$sessions sessions',
        secondaryValue: '${minutes}m',
        progress: sessions / maxCount,
        emphasis: _isSameDay(day, referenceDate),
      );
    });
  }

  String _weeklyNarrative({
    required int weeklySessions,
    required int weeklyMinutes,
    required int lastWeekSessions,
  }) {
    if (weeklySessions == 0) {
      return 'No sessions yet this week. One short focus block is enough to restart momentum.';
    }

    if (weeklySessions > lastWeekSessions) {
      return 'You are ahead of last week with $weeklySessions focus sessions and $weeklyMinutes minutes logged.';
    }

    if (weeklySessions < lastWeekSessions) {
      return 'You are slightly behind last week. A steady restart today will lift the trend quickly.';
    }

    return 'You matched last week with $weeklySessions focus sessions. Consistency is holding.';
  }

  String _weeklyGuidance({
    required int weeklySessions,
    required double averagePerDay,
  }) {
    if (weeklySessions == 0) {
      return 'Start with one 25 minute session today. Momentum matters more than volume.';
    }
    if (averagePerDay >= 2) {
      return 'You are building a reliable rhythm. Keep your first session at the same time each day.';
    }
    return 'Your focus is showing up, but not yet consistently. Protect one anchor session each morning.';
  }

  String _weekdayLabel(DateTime day) {
    const List<String> labels = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[day.weekday - 1];
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
