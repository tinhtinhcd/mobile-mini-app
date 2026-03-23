import 'package:app_core/app_core.dart';
import 'package:fasting_app/src/application/fasting_coaching.dart';
import 'package:fasting_app/src/application/fasting_habits.dart';
import 'package:fasting_app/src/application/fasting_monetization.dart';
import 'package:fasting_app/src/domain/fasting_plan.dart';
import 'package:fasting_app/src/presentation/fasting_app_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_engine/habit_engine.dart';
import 'package:monetization/monetization.dart';
import 'package:timer_engine/timer_engine.dart';
import 'package:ui_kit/ui_kit.dart';

const String fastingWeeklySummaryPath = 'weekly-summary';

class FastingWeeklySummaryScreen extends ConsumerWidget {
  const FastingWeeklySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final HabitService habits = ref.watch(fastingHabitServiceProvider);
    final EntitlementService entitlements = ref.watch(entitlementProvider);
    final DateTime now = DateTime.now();
    final int weeklyCount = habits.weeklyCount;
    final int weeklyMinutes = habits.weeklyMinutes;
    final double averagePerDay = weeklyCount / 7;
    final int lastWeekCount =
        habits.countForLastDays(14, referenceDate: now) - weeklyCount;
    final bool premiumCoachingUnlocked = entitlements.has(
      Entitlement.advancedStats,
    );
    final FastingPlan currentPlan = _currentPlan(habits);
    final FastingCoachingSnapshot coaching = const FastingCoachingService()
        .build(
          habits: habits,
          state: TimerState.initial(session: currentPlan.session),
          selectedPlan: currentPlan,
          referenceDate: now,
        );
    final List<WeeklyBreakdownItem> breakdown = _buildBreakdown(habits, now);

    return FactoryScaffold(
      title: 'Weekly summary',
      appMenuSpec: fastingAppMenuSpec,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _weeklyNarrative(
              weeklyCount: weeklyCount,
              weeklyMinutes: weeklyMinutes,
              lastWeekCount: lastWeekCount,
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
                      label: 'Total fasts',
                      value: '$weeklyCount',
                    ),
                    CompactStatItem(
                      label: 'Average/day',
                      value: averagePerDay.toStringAsFixed(1),
                    ),
                    CompactStatItem(
                      label: 'Total hours',
                      value: _trackedHoursLabel(weeklyMinutes),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _weeklyGuidance(
                    weeklyCount: weeklyCount,
                    weeklyMinutes: weeklyMinutes,
                  ),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: 'Coach review',
            child:
                premiumCoachingUnlocked
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ...coaching.reviewEntries.map((
                          FastingReviewEntry entry,
                        ) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sm,
                            ),
                            child: _ReviewEntryView(
                              label: entry.label,
                              value: entry.value,
                              message: entry.message,
                            ),
                          );
                        }),
                        Text(
                          coaching.recommendation,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                    : PremiumCalloutCard(
                      title: 'Unlock weekly coaching review',
                      subtitle:
                          'Premium adds longest fast, weekly consistency, common break pattern, and suggested plan adjustments.',
                    ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: 'Daily breakdown',
            subtitle: 'Stable repetition beats extreme days.',
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
    final int maxMinutes = List<int>.generate(
      7,
      (int index) => habits.minutesForDay(
        DateTime(
          referenceDate.year,
          referenceDate.month,
          referenceDate.day,
        ).subtract(Duration(days: 6 - index)),
      ),
    ).fold<int>(60, (int max, int value) => value > max ? value : max);

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
        primaryValue: sessions == 0 ? 'No fast' : '$sessions fast',
        secondaryValue: _trackedHoursLabel(minutes),
        progress: minutes / maxMinutes,
        emphasis: _isSameDay(day, referenceDate),
      );
    });
  }

  String _weeklyNarrative({
    required int weeklyCount,
    required int weeklyMinutes,
    required int lastWeekCount,
  }) {
    if (weeklyCount == 0) {
      return 'No completed fasts yet this week. A clean reset today is enough to start building rhythm again.';
    }

    if (weeklyCount > lastWeekCount) {
      return 'You completed more fasts than last week and logged ${_trackedHoursLabel(weeklyMinutes)} total fasting time.';
    }

    if (weeklyCount < lastWeekCount) {
      return 'You are a bit behind last week. Returning to your easiest repeatable plan will steady the pattern.';
    }

    return 'You matched last week. Your fasting rhythm is holding steady.';
  }

  String _weeklyGuidance({
    required int weeklyCount,
    required int weeklyMinutes,
  }) {
    if (weeklyCount == 0) {
      return 'Restart with your most comfortable plan today. Consistency is more valuable than intensity.';
    }

    if (weeklyMinutes / 60 >= 60) {
      return 'You are maintaining strong volume. Keep meal timing consistent so the streak stays easy.';
    }

    return 'Your pattern is forming, but it still needs repetition. Aim for the same fasting window on consecutive days.';
  }

  String _trackedHoursLabel(int trackedMinutes) {
    final double trackedHours = trackedMinutes / 60;
    return '${trackedHours.toStringAsFixed(1)}h';
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

  FastingPlan _currentPlan(HabitService habits) {
    final String? type = habits.lastRecord?.type;
    for (final FastingPlan plan in FastingPlan.values) {
      if (plan.name == type) {
        return plan;
      }
    }
    return FastingPlan.lean16;
  }
}

class _ReviewEntryView extends StatelessWidget {
  const _ReviewEntryView({
    required this.label,
    required this.value,
    required this.message,
  });

  final String label;
  final String value;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(message, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
