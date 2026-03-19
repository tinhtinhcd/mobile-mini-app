import 'dart:async';

import 'package:app_core/app_core.dart';
import 'package:fasting_app/src/application/fasting_analytics.dart';
import 'package:fasting_app/src/application/fasting_controller.dart';
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

class FastingScreen extends ConsumerWidget {
  const FastingScreen({super.key});

  static const List<int> _dailyGoalOptions = <int>[1, 2];

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
    final FastingPlan selectedPlan = controller.selectedPlan;
    final DateTime now = DateTime.now();
    final int todayFasts = habits.todayCount;
    final int dailyGoal = habits.dailyGoal;
    final int weeklyFasts = habits.weeklyCount;
    final int weeklyMinutes = habits.weeklyMinutes;
    final int streakDays = habits.currentStreak;
    final Duration? lastFastDuration = habits.lastSessionDuration;
    final List<HabitSessionRecord> recentEntries = habits.recentRecords(
      limit: entitlements.has(Entitlement.unlimitedSessions) ? 3 : 1,
    );
    final List<HabitSessionRecord> weeklyEntries = habits.recordsForLastDays(
      7,
      referenceDate: now,
    );
    final int weeklyActiveDays = _activeDays(weeklyEntries);
    final List<WeeklyActivityEntry> weeklyActivity = _buildWeeklyActivity(
      context,
      habits,
      now,
    );
    final bool advancedInsightsUnlocked = entitlements.has(
      Entitlement.advancedStats,
    );

    return FactoryScaffold(
      title: l10n.fastingTitle,
      appMenuSpec: fastingAppMenuSpec,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.fastingCurrentFast,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _PlanBadge(label: selectedPlan.label),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          TimerDisplayCard(
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
          ),
          const SizedBox(height: AppSpacing.md),
          AppPrimaryButton(
            label: _primaryLabel(l10n, state),
            icon: Icon(_primaryIcon(state)),
            onPressed: controller.toggleTimer,
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: l10n.commonMomentum,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CompactStatStrip(
                  items: <CompactStatItem>[
                    CompactStatItem(
                      label: l10n.commonToday,
                      value: l10n.fastingTodayFastsValue(todayFasts, dailyGoal),
                    ),
                    CompactStatItem(
                      label: l10n.fastingLastFast,
                      value: _durationLabel(lastFastDuration),
                    ),
                    CompactStatItem(
                      label: l10n.commonStreak,
                      value: '${streakDays}d',
                      highlight: theme.colorScheme.tertiary,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.commonDailyGoal,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: habits.goalProgress,
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children:
                      _dailyGoalOptions.map((int goal) {
                        return SelectionPill(
                          label: '$goal',
                          selected: dailyGoal == goal,
                          onTap: () {
                            if (dailyGoal == goal) {
                              return;
                            }
                            unawaited(habits.updateDailyGoal(goal));
                          },
                        );
                      }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.commonWeeklyRhythm,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                WeeklyActivityStrip(
                  entries: weeklyActivity,
                  maxValue: selectedPlan.fastingDuration.inHours.toDouble(),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.fastingSevenDaySummary(
                    weeklyFasts,
                    _trackedHoursLabel(weeklyMinutes),
                  ),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.commonPlan,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
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
          const SizedBox(height: AppSpacing.md),
          AppSecondaryButton(
            label: l10n.fastingResetFast,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.reset,
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionCard(
            title: l10n.fastingAdvancedPlansTitle,
            subtitle: l10n.fastingPlanSummary(
              selectedPlan.label,
              _eatingWindowLabel(l10n, selectedPlan),
              _planDescription(l10n, selectedPlan),
            ),
            child: Text(
              l10n.fastingWeeklyConsistencySummary(
                weeklyActiveDays,
                _trackedHoursLabel(weeklyMinutes),
              ),
              style: theme.textTheme.bodySmall,
            ),
          ),
          if (recentEntries.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            SectionCard(
              title: l10n.commonRecentActivity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    recentEntries.map((HabitSessionRecord entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text(
                          _historyLabel(l10n, entry),
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (advancedInsightsUnlocked)
            SectionCard(
              title: l10n.fastingDeeperInsights,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CompactStatStrip(
                    items: <CompactStatItem>[
                      CompactStatItem(
                        label: l10n.commonActiveDays,
                        value: '$weeklyActiveDays/7',
                      ),
                      CompactStatItem(
                        label: l10n.fastingLongestFast,
                        value: _longestFastLabel(weeklyEntries),
                      ),
                      CompactStatItem(
                        label: l10n.commonToday,
                        value: _durationLabel(lastFastDuration),
                        highlight: theme.colorScheme.tertiary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.fastingWeeklyConsistencySummary(
                      weeklyActiveDays,
                      _trackedHoursLabel(weeklyMinutes),
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            )
          else
            PremiumCalloutCard(
              title: l10n.fastingPremiumTeaserTitle,
              subtitle: l10n.fastingPremiumTeaserSubtitle,
              actionLabel: l10n.commonSeePremium,
              onPressed:
                  () => openFastingPaywall(
                    context: context,
                    ref: ref,
                    entryPoint: fastingHeaderButtonEntryPoint,
                  ),
            ),
        ],
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

  String _durationLabel(Duration? duration) {
    if (duration == null) {
      return '0h';
    }
    return _trackedHoursLabel(duration.inMinutes);
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

  String _planDescription(AppLocalizations l10n, FastingPlan plan) {
    return switch (plan) {
      FastingPlan.reset12 => l10n.fastingPlanReset12Description,
      FastingPlan.lean16 => l10n.fastingPlanLean16Description,
      FastingPlan.performance18 => l10n.fastingPlanPerformance18Description,
      FastingPlan.deep20 => l10n.fastingPlanDeep20Description,
    };
  }

  String _eatingWindowLabel(AppLocalizations l10n, FastingPlan plan) {
    return switch (plan) {
      FastingPlan.reset12 => l10n.fastingEatingWindow12,
      FastingPlan.lean16 => l10n.fastingEatingWindow8,
      FastingPlan.performance18 => l10n.fastingEatingWindow6,
      FastingPlan.deep20 => l10n.fastingEatingWindow4,
    };
  }

  String _historyLabel(AppLocalizations l10n, HabitSessionRecord entry) {
    final DateTime completedAt = entry.completedAtLocal;
    final String hours = completedAt.hour.toString().padLeft(2, '0');
    final String minutes = completedAt.minute.toString().padLeft(2, '0');
    return l10n.fastingHistoryItem(
      _trackedHoursLabel(entry.durationMinutes),
      completedAt.month,
      completedAt.day,
      '$hours:$minutes',
    );
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
