import 'dart:async';

import 'package:app_core/app_core.dart';
import 'package:discipline_engine/discipline_engine.dart';
import 'package:fasting_app/src/application/fasting_analytics.dart';
import 'package:fasting_app/src/application/fasting_coaching.dart';
import 'package:fasting_app/src/application/fasting_controller.dart';
import 'package:fasting_app/src/application/fasting_habits.dart';
import 'package:fasting_app/src/application/fasting_monetization.dart';
import 'package:fasting_app/src/domain/fasting_plan.dart';
import 'package:fasting_app/src/presentation/fasting_app_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_engine/habit_engine.dart';
import 'package:monetization/monetization.dart';
import 'package:timer_engine/timer_engine.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:fasting_app/src/presentation/fasting_weekly_summary_screen.dart';

class FastingScreen extends ConsumerWidget {
  const FastingScreen({super.key});

  static const List<int> _dailyGoalOptions = <int>[1, 2];
  static const FastingCoachingService _coachingService =
      FastingCoachingService();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);
    final TimerState state = ref.watch(fastingControllerProvider);
    final FastingController controller = ref.read(
      fastingControllerProvider.notifier,
    );
    final EntitlementService entitlements = ref.watch(entitlementProvider);
    final AdService adService = ref.read(fastingAdServiceProvider);
    final HabitService habits = ref.watch(fastingHabitServiceProvider);
    final bool premiumCoachingUnlocked = entitlements.has(
      Entitlement.advancedStats,
    );
    final FastingPlan selectedPlan = controller.selectedPlan;
    final FastingCoachingSnapshot coaching = _coachingService.build(
      habits: habits,
      state: state,
      selectedPlan: selectedPlan,
    );
    final DateTime now = DateTime.now();
    final int todayFasts = habits.todayCount;
    final int dailyGoal = habits.dailyGoal;
    final int weeklyFasts = habits.weeklyCount;
    final int weeklyMinutes = habits.weeklyMinutes;
    final int streakDays = habits.currentStreak;
    final List<WeeklyActivityEntry> weeklyActivity = _buildWeeklyActivity(
      context,
      habits,
      now,
    );

    return FactoryScaffold(
      title: l10n.fastingTitle,
      appMenuSpec: fastingAppMenuSpec,
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
                    l10n.fastingCurrentFast,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _PlanBadge(label: selectedPlan.label),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Expanded(
              child: Center(
                child: TimerDisplayCard(
                  label: selectedPlan.label,
                  timeText: _formatDuration(state.remaining),
                  progress: _clampProgress(state.progress),
                  statusText:
                      state.isRunning
                          ? l10n.fastingFastInProgress
                          : state.remaining == state.activeSession.duration
                          ? l10n.commonReadyToBegin
                          : l10n.commonPaused,
                  footnote: _planDescription(l10n, selectedPlan),
                  compact: true,
                ),
              ),
            ),
          ],
        ),
        primaryAction: AppPrimaryButton(
          label: _primaryLabel(l10n, state),
          icon: Icon(_primaryIcon(state)),
          onPressed: controller.toggleTimer,
        ),
        secondaryAction: AppSecondaryButton(
          label: l10n.fastingResetFast,
          icon: const Icon(Icons.refresh_rounded),
          onPressed: controller.reset,
        ),
        selector: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.commonPlan,
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
                  FastingPlan.values.asMap().entries.map((
                    MapEntry<int, FastingPlan> entry,
                  ) {
                    final UsageLimitResult access = fastingPlanPolicy
                        .evaluateWithEntitlements(
                          entitlementService: entitlements,
                          premiumEntitlement: Entitlement.advancedPlans,
                          usageCount: entry.key + 1,
                        );

                    return SelectionPill(
                      label: entry.value.label,
                      selected: entry.value == selectedPlan && access.allowed,
                      locked: !access.allowed,
                      compact: true,
                      onTap: () {
                        if (access.allowed) {
                          controller.selectPlan(entry.value);
                          return;
                        }

                        openFastingPaywall(
                          context: context,
                          ref: ref,
                          entryPoint: fastingLockedPlanEntryPoint,
                        );
                      },
                    );
                  }).toList(),
            ),
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
                    value: '$todayFasts/$dailyGoal',
                  ),
                  CompactStatItem(label: 'Week', value: '$weeklyFasts'),
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
              if (premiumCoachingUnlocked) ...<Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _CoachingStatusPill(
                        label: _statusLabel(coaching.durationStatus),
                        status: coaching.durationStatus,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${coaching.review.weeklyConsistencyScore}% week',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
              ],
              Text(
                coaching.goalProgressLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              if (premiumCoachingUnlocked &&
                  coaching.warningMessage != null) ...<Widget>[
                Text(
                  coaching.warningMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
              ],
              Text(
                premiumCoachingUnlocked
                    ? coaching.recoveryMessage ?? coaching.durationStatusMessage
                    : coaching.goalProgressSummary,
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      premiumCoachingUnlocked
                          ? _coachMessageColor(theme, coaching.durationStatus)
                          : theme.colorScheme.onSurfaceVariant,
                  fontWeight:
                      premiumCoachingUnlocked &&
                              coaching.durationStatus ==
                                  DisciplineStatusType.behind
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
              ] else if (!premiumCoachingUnlocked) ...<Widget>[
                const SizedBox(height: AppSpacing.xxs),
                TextButton(
                  onPressed:
                      () => openFastingPaywall(
                        context: context,
                        ref: ref,
                        entryPoint: fastingHeaderButtonEntryPoint,
                      ),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Unlock coaching'),
                ),
              ],
              const SizedBox(height: AppSpacing.xxs),
              if (premiumCoachingUnlocked) ...<Widget>[
                Text(
                  coaching.reviewTeaser,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
              ],
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${_trackedHoursLabel(weeklyMinutes)} this week',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/$fastingWeeklySummaryPath'),
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
              WeeklyActivityStrip(
                entries: weeklyActivity,
                maxValue: selectedPlan.fastingDuration.inHours.toDouble(),
                compact: true,
              ),
            ],
          ),
        ),
      ),
      footer: MonetizationBanner(
        startupAppId: 'fasting_app',
        adService: adService,
        entitlementService: entitlements,
        adUnitId: fastingBannerAdUnitId,
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
        value: habits.minutesForDay(day) / 60,
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

  double _clampProgress(double progress) {
    if (progress < 0) {
      return 0;
    }
    if (progress > 1) {
      return 1;
    }
    return progress;
  }

  String _formatDuration(Duration duration) {
    final int totalHours = duration.inHours;
    final String hours = totalHours.toString().padLeft(2, '0');
    final String minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final String seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _primaryLabel(AppLocalizations l10n, TimerState state) {
    if (state.isRunning) {
      return l10n.fastingPauseFast;
    }

    if (state.remaining != state.activeSession.duration) {
      return l10n.fastingResumeFast;
    }

    return l10n.fastingStartFast;
  }

  IconData _primaryIcon(TimerState state) {
    if (state.isRunning) {
      return Icons.pause_rounded;
    }

    return Icons.play_arrow_rounded;
  }

  String _trackedHoursLabel(int trackedMinutes) {
    final double trackedHours = trackedMinutes / 60;
    return '${trackedHours.toStringAsFixed(1)}h';
  }

  Color _coachMessageColor(
    ThemeData theme,
    DisciplineStatusType progressStatus,
  ) {
    return switch (progressStatus) {
      DisciplineStatusType.behind => theme.colorScheme.error,
      DisciplineStatusType.completed => theme.colorScheme.tertiary,
      DisciplineStatusType.notStarted => theme.colorScheme.onSurfaceVariant,
      DisciplineStatusType.onTrack => theme.colorScheme.onSurfaceVariant,
    };
  }

  String _statusLabel(DisciplineStatusType progressStatus) {
    return switch (progressStatus) {
      DisciplineStatusType.behind => 'You are behind',
      DisciplineStatusType.completed => 'Goal completed',
      DisciplineStatusType.notStarted => 'Not started',
      DisciplineStatusType.onTrack => 'You are on track',
    };
  }

  String _planDescription(AppLocalizations l10n, FastingPlan plan) {
    return switch (plan) {
      FastingPlan.reset12 => l10n.fastingPlanReset12Description,
      FastingPlan.lean16 => l10n.fastingPlanLean16Description,
      FastingPlan.performance18 => l10n.fastingPlanPerformance18Description,
      FastingPlan.deep20 => l10n.fastingPlanDeep20Description,
    };
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge({required this.label});

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
  final DisciplineStatusType status;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color tone = switch (status) {
      DisciplineStatusType.behind => theme.colorScheme.error,
      DisciplineStatusType.completed => theme.colorScheme.tertiary,
      DisciplineStatusType.notStarted => theme.colorScheme.outline,
      DisciplineStatusType.onTrack => theme.colorScheme.primary,
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
