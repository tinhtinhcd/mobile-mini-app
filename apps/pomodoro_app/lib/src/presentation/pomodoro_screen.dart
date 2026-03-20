import 'dart:async';

import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_engine/habit_engine.dart';
import 'package:monetization/monetization.dart';
import 'package:pomodoro_app/src/application/pomodoro_analytics.dart';
import 'package:pomodoro_app/src/application/pomodoro_controller.dart';
import 'package:pomodoro_app/src/application/pomodoro_habits.dart';
import 'package:pomodoro_app/src/application/pomodoro_monetization.dart';
import 'package:pomodoro_app/src/presentation/pomodoro_app_menu.dart';
import 'package:pomodoro_app/src/presentation/pomodoro_weekly_summary_screen.dart';
import 'package:timer_engine/timer_engine.dart';
import 'package:ui_kit/ui_kit.dart';

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  static const List<int> _dailyGoalOptions = <int>[2, 4, 6];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final TimerState state = ref.watch(pomodoroControllerProvider);
    final PomodoroController controller = ref.read(
      pomodoroControllerProvider.notifier,
    );
    final EntitlementService entitlements = ref.watch(entitlementProvider);
    final AdService adService = ref.read(pomodoroAdServiceProvider);
    final HabitService habits = ref.watch(pomodoroHabitServiceProvider);
    final PomodoroMode currentMode = pomodoroModeFromSession(
      state.activeSession,
    );
    final PomodoroDurationPreset durationPreset = ref.watch(
      pomodoroDurationPresetProvider,
    );
    final HabitCoachingReport coaching = const HabitCoachingEngine().build(
      habits: habits,
    );
    final bool premiumCoachingUnlocked = entitlements.has(
      Entitlement.advancedStats,
    );
    final DateTime now = DateTime.now();
    final int todaySessions = habits.todayCount;
    final int weeklySessions = habits.weeklyCount;
    final int weeklyMinutes = habits.weeklyMinutes;
    final int streakDays = habits.currentStreak;
    final int dailyGoal = habits.dailyGoal;
    final List<WeeklyActivityEntry> weeklyActivity = _buildWeeklyActivity(
      context,
      habits,
      now,
    );
    final bool isFreshFocusStart =
        !state.isRunning &&
        currentMode == PomodoroMode.focus &&
        state.remaining == state.activeSession.duration;
    final UsageLimitResult unlimitedSessionsAccess =
        pomodoroUnlimitedSessionsPolicy.evaluateWithEntitlements(
          entitlementService: entitlements,
          premiumEntitlement: Entitlement.unlimitedSessions,
          usageCount: isFreshFocusStart ? todaySessions + 1 : todaySessions,
        );
    final UsageLimitResult customDurationsAccess = pomodoroCustomDurationsPolicy
        .evaluateWithEntitlements(
          entitlementService: entitlements,
          premiumEntitlement: Entitlement.customModes,
          usageCount: 1,
        );

    return FactoryScaffold(
      title: l10n.pomodoroTitle,
      appMenuSpec: pomodoroAppMenuSpec,
      scrollable: false,
      expandBody: true,
      contentPadding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      body: FixedUtilityScreenLayout(
        hero: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    l10n.pomodoroCurrentCycle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _ModeStatusBadge(label: _modeLabel(l10n, currentMode)),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Expanded(
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: TimerDisplayCard(
                    key: ValueKey<String>(state.activeSession.id),
                    label: _modeLabel(l10n, currentMode),
                    timeText: _formatDuration(state.remaining),
                    progress: state.progress,
                    statusText: _sessionStatusText(l10n, state, currentMode),
                    compact: true,
                  ),
                ),
              ),
            ),
          ],
        ),
        primaryAction: AppPrimaryButton(
          label: _primaryLabel(l10n, state, currentMode),
          icon: Icon(_primaryIcon(state)),
          onPressed: () {
            if (!unlimitedSessionsAccess.allowed) {
              openPomodoroPaywall(
                context: context,
                ref: ref,
                entryPoint: pomodoroHeaderButtonEntryPoint,
              );
              return;
            }
            controller.toggleTimer();
          },
        ),
        secondaryAction: Row(
          children: <Widget>[
            Expanded(
              child: AppSecondaryButton(
                label: l10n.pomodoroResetAction,
                icon: const Icon(Icons.refresh_rounded),
                onPressed: controller.reset,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppSecondaryButton(
                label: l10n.pomodoroSkipAction,
                icon: const Icon(Icons.skip_next_rounded),
                onPressed: controller.skipToNextMode,
              ),
            ),
          ],
        ),
        selector: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.commonMode,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children:
                  PomodoroMode.values.map((PomodoroMode mode) {
                    return SelectionPill(
                      label: _modeLabel(l10n, mode),
                      selected: currentMode == mode,
                      compact: true,
                      onTap: () => controller.selectMode(mode),
                    );
                  }).toList(),
            ),
            if (currentMode == PomodoroMode.focus) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children:
                    PomodoroDurationPreset.values.map((
                      PomodoroDurationPreset preset,
                    ) {
                      return SelectionPill(
                        label: preset.shortLabel,
                        selected: durationPreset == preset,
                        compact: true,
                        locked:
                            !customDurationsAccess.allowed &&
                            durationPreset != preset,
                        onTap: () {
                          if (customDurationsAccess.allowed) {
                            controller.selectDurationPreset(preset);
                            return;
                          }
                          openPomodoroPaywall(
                            context: context,
                            ref: ref,
                            entryPoint: pomodoroHeaderButtonEntryPoint,
                          );
                        },
                      );
                    }).toList(),
              ),
            ],
          ],
        ),
        compactPanel: SectionCard(
          compact: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CompactStatStrip(
                compact: true,
                items: <CompactStatItem>[
                  CompactStatItem(
                    label: 'Today',
                    value: '$todaySessions/$dailyGoal',
                  ),
                  CompactStatItem(label: 'Week', value: '$weeklySessions'),
                  CompactStatItem(
                    label: 'Streak',
                    value: '${streakDays}d',
                    highlight: theme.colorScheme.tertiary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: habits.goalProgress,
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children:
                    _dailyGoalOptions.map((int goal) {
                      return SelectionPill(
                        label: '$goal',
                        selected: dailyGoal == goal,
                        compact: true,
                        onTap: () {
                          if (dailyGoal == goal) {
                            return;
                          }
                          unawaited(habits.updateDailyGoal(goal));
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _CoachingStatusPill(
                      label: coaching.progressLabel,
                      status: coaching.progressStatus,
                    ),
                  ),
                  if (premiumCoachingUnlocked &&
                      coaching.suggestedDailyGoal != dailyGoal) ...<Widget>[
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Suggested ${coaching.suggestedDailyGoal}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                premiumCoachingUnlocked
                    ? _premiumCoachMessage(coaching)
                    : coaching.progressMessage,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _coachMessageColor(theme, coaching.progressStatus),
                  fontWeight:
                      coaching.progressStatus == HabitProgressStatus.behind
                          ? FontWeight.w600
                          : FontWeight.w500,
                ),
              ),
              if (premiumCoachingUnlocked &&
                  coaching.streakMessage != null) ...<Widget>[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  coaching.streakMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xxs),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '$weeklyMinutes min this week',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed:
                        () => context.push('/$pomodoroWeeklySummaryPath'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                    ),
                    child: const Text('Weekly summary'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),
              WeeklyActivityStrip(entries: weeklyActivity, compact: true),
            ],
          ),
        ),
      ),
      footer: MonetizationBanner(
        startupAppId: 'pomodoro_app',
        adService: adService,
        entitlementService: entitlements,
        adUnitId: pomodoroBannerAdUnitId,
      ),
    );
  }

  List<WeeklyActivityEntry> _buildWeeklyActivity(
    BuildContext context,
    HabitService habits,
    DateTime referenceDate,
  ) {
    return List<WeeklyActivityEntry>.generate(7, (int index) {
      final DateTime day = DateTime(
        referenceDate.year,
        referenceDate.month,
        referenceDate.day,
      ).subtract(Duration(days: 6 - index));
      return WeeklyActivityEntry(
        label: _weekdayLabel(context, day),
        value: habits.countForDay(day).toDouble(),
        emphasis: _isSameDay(day, referenceDate),
      );
    });
  }

  String _weekdayLabel(BuildContext context, DateTime day) {
    final List<String> labels =
        MaterialLocalizations.of(context).narrowWeekdays;
    return labels[day.weekday % 7];
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  String _formatDuration(Duration duration) {
    final String minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final String seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _sessionStatusText(
    AppLocalizations l10n,
    TimerState state,
    PomodoroMode mode,
  ) {
    if (state.isRunning) {
      return mode == PomodoroMode.focus
          ? l10n.pomodoroFocusInProgress
          : l10n.pomodoroBreakInProgress;
    }

    if (state.remaining == state.activeSession.duration) {
      return l10n.commonReadyToBegin;
    }

    return l10n.commonPaused;
  }

  String _primaryLabel(
    AppLocalizations l10n,
    TimerState state,
    PomodoroMode mode,
  ) {
    if (state.isRunning) {
      return mode == PomodoroMode.focus
          ? l10n.pomodoroPauseFocus
          : l10n.pomodoroPauseBreak;
    }

    if (state.remaining != state.activeSession.duration) {
      return mode == PomodoroMode.focus
          ? l10n.pomodoroResumeFocus
          : l10n.pomodoroResumeBreak;
    }

    return mode == PomodoroMode.focus
        ? l10n.pomodoroStartFocusSession
        : l10n.pomodoroStartBreak;
  }

  IconData _primaryIcon(TimerState state) {
    if (state.isRunning) {
      return Icons.pause_rounded;
    }

    return Icons.play_arrow_rounded;
  }

  String _modeLabel(AppLocalizations l10n, PomodoroMode mode) {
    return switch (mode) {
      PomodoroMode.focus => l10n.pomodoroModeFocus,
      PomodoroMode.shortBreak => l10n.pomodoroModeShortBreak,
      PomodoroMode.longBreak => l10n.pomodoroModeLongBreak,
    };
  }

  String _premiumCoachMessage(HabitCoachingReport coaching) {
    if (coaching.progressStatus == HabitProgressStatus.behind) {
      final String noun = coaching.remainingToday == 1 ? 'session' : 'sessions';
      return 'Recovery: do ${coaching.remainingToday} focus $noun now to stay on track.';
    }
    if (coaching.progressStatus == HabitProgressStatus.completed) {
      return 'Goal complete. Suggested goal tomorrow: ${coaching.suggestedDailyGoal}.';
    }
    if (coaching.suggestedDailyGoal != coaching.dailyGoal) {
      return 'Suggested goal today: ${coaching.suggestedDailyGoal}.';
    }
    return 'You are pacing well. Keep the next focus block close to the same time.';
  }

  Color _coachMessageColor(
    ThemeData theme,
    HabitProgressStatus progressStatus,
  ) {
    return switch (progressStatus) {
      HabitProgressStatus.behind => theme.colorScheme.error,
      HabitProgressStatus.completed => theme.colorScheme.tertiary,
      HabitProgressStatus.onTrack => theme.colorScheme.onSurfaceVariant,
    };
  }
}

class _ModeStatusBadge extends StatelessWidget {
  const _ModeStatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          theme.colorScheme.primary.withValues(alpha: 0.12),
          theme.colorScheme.surface,
        ),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CoachingStatusPill extends StatelessWidget {
  const _CoachingStatusPill({required this.label, required this.status});

  final String label;
  final HabitProgressStatus status;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color tone = switch (status) {
      HabitProgressStatus.behind => theme.colorScheme.error,
      HabitProgressStatus.completed => theme.colorScheme.tertiary,
      HabitProgressStatus.onTrack => theme.colorScheme.primary,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          tone.withValues(alpha: 0.14),
          theme.colorScheme.surface,
        ),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: tone.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: tone,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
