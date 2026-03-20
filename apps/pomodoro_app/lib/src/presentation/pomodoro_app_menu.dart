import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_engine/habit_engine.dart';
import 'package:monetization/monetization.dart';
import 'package:pomodoro_app/src/application/pomodoro_analytics.dart';
import 'package:pomodoro_app/src/application/pomodoro_controller.dart';
import 'package:pomodoro_app/src/application/pomodoro_habits.dart';
import 'package:pomodoro_app/src/application/pomodoro_monetization.dart';
import 'package:ui_kit/ui_kit.dart';

Future<bool> _requestPomodoroNotifications(BuildContext context) {
  final ProviderContainer container = ProviderScope.containerOf(
    context,
    listen: false,
  );
  return container
      .read(pomodoroNotificationServiceProvider)
      .requestPermission();
}

final AppMenuSpec pomodoroAppMenuSpec = AppMenuSpec(
  appTitle: 'Pomodoro App',
  aboutDescription:
      'A calm focus timer built on the shared mobile app shell and timer engine.',
  versionLabel: '0.1.0 placeholder',
  privacyBody:
      'Pomodoro App keeps privacy guidance lightweight for now. Add the full policy here when the legal copy is ready.',
  feedbackBody:
      'Share focus flow feedback or support needs here. This screen is ready to connect to email or issue reporting later.',
  requestNotificationPermission: _requestPomodoroNotifications,
);

class PomodoroPremiumScreen extends ConsumerWidget {
  const PomodoroPremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final HabitService habits = ref.watch(pomodoroHabitServiceProvider);
    final EntitlementService entitlements = ref.watch(entitlementProvider);
    final bool advancedInsightsUnlocked = entitlements.has(
      Entitlement.advancedStats,
    );
    final bool customModesUnlocked = entitlements.has(Entitlement.customModes);
    final HabitCoachingReport coaching = const HabitCoachingEngine().build(
      habits: habits,
    );
    final int weeklySessions = coaching.weeklyCount;
    final int weeklyMinutes = coaching.weeklyMinutes;
    final PomodoroDurationPreset suggestedPreset = _suggestedPreset(
      coaching: coaching,
      weeklySessions: weeklySessions,
      weeklyMinutes: weeklyMinutes,
    );

    return FactoryScaffold(
      title: context.l10n.shellSubscriptionPlan,
      appMenuSpec: pomodoroAppMenuSpec,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            pomodoroPaywallContent.subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: l10n.pomodoroAdvancedInsights,
            child:
                advancedInsightsUnlocked
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CompactStatStrip(
                          items: <CompactStatItem>[
                            CompactStatItem(
                              label: 'Best focus time',
                              value:
                                  coaching.bestTimeBucket?.label ??
                                  'Not enough data',
                            ),
                            CompactStatItem(
                              label: 'Consistency',
                              value: '${coaching.weeklyConsistencyScore}%',
                            ),
                            CompactStatItem(
                              label: 'Average session',
                              value: _averageMinutesLabel(
                                weeklySessions,
                                weeklyMinutes,
                              ),
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
                          coaching.bestTimeInsight,
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
                          _pomodoroRecommendation(
                            coaching: coaching,
                            suggestedPreset: suggestedPreset,
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    )
                    : PremiumCalloutCard(
                      title: 'Unlock your focus coach',
                      subtitle: _premiumPreviewSubtitle(
                        coaching: coaching,
                        suggestedPreset: suggestedPreset,
                      ),
                    ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: l10n.pomodoroCustomModesTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  customModesUnlocked
                      ? 'Suggested today: ${coaching.suggestedDailyGoal} focus sessions using ${suggestedPreset.shortLabel}.'
                      : 'Premium can recommend a daily session target and the best duration preset for your current rhythm.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                ...PomodoroDurationPreset.values.map((
                  PomodoroDurationPreset preset,
                ) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Icon(Icons.tune_rounded, size: 18),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            '${preset.label} • ${preset.focusDuration.inMinutes}/${preset.shortBreakDuration.inMinutes}/${preset.longBreakDuration.inMinutes}',
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
          ...pomodoroPaywallContent.benefits.map(
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
                ? coaching.goalInsight
                : pomodoroPaywallContent.freeTierNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label:
                advancedInsightsUnlocked
                    ? 'Manage subscription'
                    : 'View subscription options',
            onPressed:
                () => openPomodoroPaywall(
                  context: context,
                  ref: ref,
                  entryPoint: pomodoroHeaderButtonEntryPoint,
                ),
          ),
        ],
      ),
    );
  }

  String _averageMinutesLabel(int weeklySessions, int weeklyMinutes) {
    if (weeklySessions == 0) {
      return '0m';
    }
    return '${(weeklyMinutes / weeklySessions).round()}m';
  }

  PomodoroDurationPreset _suggestedPreset({
    required HabitCoachingReport coaching,
    required int weeklySessions,
    required int weeklyMinutes,
  }) {
    if (weeklySessions == 0) {
      return PomodoroDurationPreset.classic;
    }

    final double averageMinutes = weeklyMinutes / weeklySessions;
    if (coaching.weeklyConsistencyScore >= 92 && averageMinutes >= 40) {
      return PomodoroDurationPreset.marathon;
    }
    if (coaching.weeklyConsistencyScore >= 75 && averageMinutes >= 28) {
      return PomodoroDurationPreset.deep;
    }
    return PomodoroDurationPreset.classic;
  }

  String _premiumPreviewSubtitle({
    required HabitCoachingReport coaching,
    required PomodoroDurationPreset suggestedPreset,
  }) {
    final String window =
        coaching.bestTimeBucket?.label.toLowerCase() ?? 'best focus window';
    return 'Premium turns your history into a weekly score, a suggested goal of ${coaching.suggestedDailyGoal} sessions, and a ${suggestedPreset.shortLabel} recommendation for your $window.';
  }

  String _pomodoroRecommendation({
    required HabitCoachingReport coaching,
    required PomodoroDurationPreset suggestedPreset,
  }) {
    final String window =
        coaching.bestTimeBucket?.label.toLowerCase() ?? 'first open block';
    return 'Recommended today: ${coaching.suggestedDailyGoal} focus sessions at ${suggestedPreset.shortLabel}, ideally in the $window.';
  }
}
