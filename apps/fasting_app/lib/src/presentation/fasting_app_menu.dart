import 'package:app_core/app_core.dart';
import 'package:fasting_app/src/application/fasting_analytics.dart';
import 'package:fasting_app/src/application/fasting_controller.dart';
import 'package:fasting_app/src/application/fasting_habits.dart';
import 'package:fasting_app/src/application/fasting_monetization.dart';
import 'package:fasting_app/src/domain/fasting_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_engine/habit_engine.dart';
import 'package:monetization/monetization.dart';
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
    final EntitlementService entitlements = ref.watch(entitlementProvider);
    final bool advancedInsightsUnlocked = entitlements.has(
      Entitlement.advancedStats,
    );
    final bool advancedPlansUnlocked = entitlements.has(
      Entitlement.advancedPlans,
    );
    final HabitCoachingReport coaching = const HabitCoachingEngine().build(
      habits: habits,
    );
    final int weeklyMinutes = coaching.weeklyMinutes;
    final int weeklyCount = coaching.weeklyCount;
    final List<HabitSessionRecord> weeklyEntries = habits.recordsForLastDays(7);
    final List<HabitSessionRecord> recentEntries = habits.recordsForLastDays(
      21,
    );
    final FastingPlan suggestedPlan = _suggestedPlan(
      coaching: coaching,
      weeklyCount: weeklyCount,
      weeklyMinutes: weeklyMinutes,
    );

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
              children: <Widget>[
                Text(
                  advancedPlansUnlocked
                      ? 'Suggested today: ${coaching.suggestedDailyGoal} fast with the ${suggestedPlan.label} plan.'
                      : 'Premium recommends the right plan and daily fasting target from your recent rhythm.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                ...<FastingPlan>[
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
                }),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: l10n.fastingDeeperInsights,
            child:
                advancedInsightsUnlocked
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CompactStatStrip(
                          items: <CompactStatItem>[
                            CompactStatItem(
                              label: 'Longest fast',
                              value: _longestFastLabel(weeklyEntries),
                            ),
                            CompactStatItem(
                              label: 'Consistency',
                              value: '${coaching.weeklyConsistencyScore}%',
                            ),
                            CompactStatItem(
                              label: 'Pattern',
                              value: _dominantPatternLabel(recentEntries),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          coaching.trendInsight,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          coaching.patternInsight,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          coaching.goalInsight,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _fastingRecommendation(
                            coaching: coaching,
                            suggestedPlan: suggestedPlan,
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    )
                    : PremiumCalloutCard(
                      title: 'Unlock your fasting coach',
                      subtitle: _premiumPreviewSubtitle(
                        coaching: coaching,
                        suggestedPlan: suggestedPlan,
                      ),
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
            advancedInsightsUnlocked
                ? l10n.fastingWeeklyConsistencySummary(
                  coaching.activeDays,
                  _trackedHoursLabel(weeklyMinutes),
                )
                : fastingPaywallContent.freeTierNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label:
                advancedInsightsUnlocked
                    ? 'Manage subscription'
                    : 'View subscription options',
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

  FastingPlan _suggestedPlan({
    required HabitCoachingReport coaching,
    required int weeklyCount,
    required int weeklyMinutes,
  }) {
    if (weeklyCount == 0) {
      return FastingPlan.reset12;
    }

    final double averageHours = (weeklyMinutes / weeklyCount) / 60;
    if (coaching.weeklyConsistencyScore >= 92 && averageHours >= 19) {
      return FastingPlan.deep20;
    }
    if (coaching.weeklyConsistencyScore >= 78 && averageHours >= 17) {
      return FastingPlan.performance18;
    }
    if (coaching.weeklyConsistencyScore < 55) {
      return FastingPlan.reset12;
    }
    return FastingPlan.lean16;
  }

  String _dominantPatternLabel(List<HabitSessionRecord> entries) {
    if (entries.isEmpty) {
      return 'Not enough data';
    }

    final Map<String, int> plans = <String, int>{
      '12:12': 0,
      '16:8': 0,
      '18:6': 0,
      '20:4': 0,
    };

    for (final HabitSessionRecord entry in entries) {
      final double hours = entry.durationMinutes / 60;
      if (hours < 14) {
        plans['12:12'] = plans['12:12']! + 1;
      } else if (hours < 17) {
        plans['16:8'] = plans['16:8']! + 1;
      } else if (hours < 19) {
        plans['18:6'] = plans['18:6']! + 1;
      } else {
        plans['20:4'] = plans['20:4']! + 1;
      }
    }

    return plans.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  String _premiumPreviewSubtitle({
    required HabitCoachingReport coaching,
    required FastingPlan suggestedPlan,
  }) {
    return 'Premium turns your history into a weekly consistency score, a suggested goal of ${coaching.suggestedDailyGoal}, and a ${suggestedPlan.label} plan recommendation.';
  }

  String _fastingRecommendation({
    required HabitCoachingReport coaching,
    required FastingPlan suggestedPlan,
  }) {
    return 'Recommended today: ${coaching.suggestedDailyGoal} fast with ${suggestedPlan.label}. Keep the plan steady before stretching longer.';
  }
}
