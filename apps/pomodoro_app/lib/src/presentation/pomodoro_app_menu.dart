import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_engine/habit_engine.dart';
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
    final int weeklySessions = habits.weeklyCount;
    final int weeklyMinutes = habits.weeklyMinutes;
    final int streakDays = habits.currentStreak;
    final int longestStreak = habits.longestStreak;

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
                      label: l10n.pomodoroAverageFocus,
                      value: _averageMinutesLabel(
                        weeklySessions,
                        weeklyMinutes,
                      ),
                    ),
                    CompactStatItem(
                      label: l10n.commonStreak,
                      value:
                          '${longestStreak > streakDays ? longestStreak : streakDays}d',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.pomodoroAdvancedInsightsSummary(
                    habits.todayMinutes,
                    weeklyMinutes,
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: l10n.pomodoroCustomModesTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  PomodoroDurationPreset.values.map((
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
                  }).toList(),
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
            pomodoroPaywallContent.freeTierNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'View subscription options',
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
}
