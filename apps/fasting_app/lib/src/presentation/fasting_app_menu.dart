import 'package:app_core/app_core.dart';
import 'package:fasting_app/src/application/fasting_analytics.dart';
import 'package:fasting_app/src/application/fasting_controller.dart';
import 'package:fasting_app/src/application/fasting_habits.dart';
import 'package:fasting_app/src/application/fasting_monetization.dart';
import 'package:fasting_app/src/domain/fasting_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_engine/habit_engine.dart';
import 'package:ui_kit/ui_kit.dart';

Future<bool> _requestFastingNotifications(BuildContext context) {
  final ProviderContainer container = ProviderScope.containerOf(
    context,
    listen: false,
  );
  return container.read(fastingNotificationServiceProvider).requestPermission();
}

final AppMenuSpec fastingAppMenuSpec = AppMenuSpec(
  appTitle: 'Fasting Tracker',
  aboutDescription:
      'A clean fasting utility focused on consistent plans, progress, and calm daily tracking.',
  versionLabel: '0.1.0 placeholder',
  privacyBody:
      'Fasting Tracker keeps privacy guidance simple for now. This screen is ready for the full policy when it is available.',
  feedbackBody:
      'Use this screen as the future home for support, bug reports, and fasting flow feedback.',
  requestNotificationPermission: _requestFastingNotifications,
);

class FastingPremiumScreen extends ConsumerWidget {
  const FastingPremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final HabitService habits = ref.watch(fastingHabitServiceProvider);
    final int weeklyMinutes = habits.weeklyMinutes;
    final int weeklyCount = habits.weeklyCount;
    final List<HabitSessionRecord> weeklyEntries = habits.recordsForLastDays(7);

    return FactoryScaffold(
      title: context.l10n.shellSubscriptionPlan,
      appMenuSpec: fastingAppMenuSpec,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            fastingPaywallContent.subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: l10n.fastingAdvancedPlansTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  <FastingPlan>[
                    FastingPlan.performance18,
                    FastingPlan.deep20,
                  ].map((FastingPlan plan) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Icon(Icons.schedule_rounded, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              '${plan.label} • ${plan.eatingWindowLabel} • ${plan.description}',
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: l10n.fastingDeeperInsights,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CompactStatStrip(
                  items: <CompactStatItem>[
                    CompactStatItem(
                      label: l10n.commonToday,
                      value: '${habits.todayCount}/${habits.dailyGoal}',
                    ),
                    CompactStatItem(
                      label: l10n.fastingLongestFast,
                      value: _longestFastLabel(weeklyEntries),
                    ),
                    CompactStatItem(
                      label: l10n.commonStreak,
                      value: '${habits.currentStreak}d',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.fastingWeeklyConsistencySummary(
                    _activeDays(weeklyEntries),
                    _trackedHoursLabel(weeklyMinutes),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...fastingPaywallContent.benefits.map(
            (String benefit) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.check_circle_rounded, size: 18),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(benefit)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            weeklyCount == 0
                ? fastingPaywallContent.freeTierNote
                : l10n.fastingWeeklyConsistencySummary(
                  _activeDays(weeklyEntries),
                  _trackedHoursLabel(weeklyMinutes),
                ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'View subscription options',
            onPressed:
                () => openFastingPaywall(
                  context: context,
                  ref: ref,
                  entryPoint: fastingHeaderButtonEntryPoint,
                ),
          ),
        ],
      ),
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

  String _trackedHoursLabel(int trackedMinutes) {
    final double trackedHours = trackedMinutes / 60;
    return '${trackedHours.toStringAsFixed(1)}h';
  }

  String _longestFastLabel(List<HabitSessionRecord> entries) {
    if (entries.isEmpty) {
      return '0h';
    }
    final int longestMinutes = entries
        .map((HabitSessionRecord entry) => entry.durationMinutes)
        .reduce((int a, int b) => a > b ? a : b);
    return _trackedHoursLabel(longestMinutes);
  }
}
