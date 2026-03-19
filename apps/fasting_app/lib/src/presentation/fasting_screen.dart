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
import 'package:timer_engine/timer_engine.dart';
import 'package:ui_kit/ui_kit.dart';

class FastingScreen extends ConsumerWidget {
  const FastingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TimerState state = ref.watch(fastingControllerProvider);
    final FastingController controller = ref.read(
      fastingControllerProvider.notifier,
    );
    final StoreMonetizationService monetization = ref.watch(
      fastingMonetizationServiceProvider,
    );
    final EntitlementService entitlements = ref.watch(entitlementProvider);
    final AdService adService = ref.read(fastingAdServiceProvider);
    final HabitService habits = ref.watch(fastingHabitServiceProvider);
    final ThemeData theme = Theme.of(context);
    final FastingPlan selectedPlan = controller.selectedPlan;
    final DateTime now = DateTime.now();
    final int todayFasts = habits.todayCount;
    final int weeklyFasts = habits.weeklyCount;
    final int weeklyMinutes = habits.weeklyMinutes;
    final int streakDays = habits.currentStreak;
    final Duration? lastFastDuration = habits.lastSessionDuration;
    final bool unlimitedHistoryUnlocked = entitlements.has(
      Entitlement.unlimitedSessions,
    );
    final List<HabitSessionRecord> recentEntries = habits.recentRecords(
      limit: unlimitedHistoryUnlocked ? 3 : 1,
    );
    final List<HabitSessionRecord> weeklyEntries = habits.recordsForLastDays(
      7,
      referenceDate: now,
    );
    final bool advancedInsightsUnlocked = entitlements.has(
      Entitlement.advancedStats,
    );

    return FactoryScaffold(
      title: 'Fasting Flow',
      headerTrailing: _PremiumButton(
        isPremium: monetization.isPremium,
        onPressed:
            () => openFastingPaywall(
              context: context,
              ref: ref,
              entryPoint: fastingHeaderButtonEntryPoint,
            ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Current fast',
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
                    ? 'Fast in progress'
                    : state.remaining == state.activeSession.duration
                    ? 'Ready to begin'
                    : 'Paused',
            footnote: selectedPlan.description,
          ),
          const SizedBox(height: AppSpacing.md),
          AppPrimaryButton(
            label: _primaryLabel(state),
            icon: Icon(_primaryIcon(state)),
            onPressed: controller.toggleTimer,
          ),
          const SizedBox(height: AppSpacing.md),
          CompactStatStrip(
            items: <CompactStatItem>[
              CompactStatItem(label: 'today', value: '$todayFasts/1 fast'),
              CompactStatItem(
                label: 'last fast',
                value: _durationLabel(lastFastDuration),
              ),
              CompactStatItem(
                label: 'streak',
                value: '${streakDays}d',
                highlight: theme.colorScheme.tertiary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              '7-day summary: $weeklyFasts fasts | ${_trackedHoursLabel(weeklyMinutes)} total fasting',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Plan',
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
            label: 'Reset fast',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.reset,
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              '${selectedPlan.label} plan | Eating window ${selectedPlan.eatingWindowLabel} | ${selectedPlan.description}',
              style: theme.textTheme.bodySmall,
            ),
          ),
          if (recentEntries.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Recent activity',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...recentEntries.map(
              (HabitSessionRecord entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  _historyLabel(entry),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
          ],
          if (!unlimitedHistoryUnlocked &&
              weeklyEntries.length > 1) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Text(
                'Premium unlocks your full fasting history.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
          if (advancedInsightsUnlocked) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Deeper insights',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            CompactStatStrip(
              items: <CompactStatItem>[
                CompactStatItem(
                  label: 'active days',
                  value:
                      '${state.stats.activeDaysLastDays(7, referenceDate: now)}/7',
                ),
                CompactStatItem(
                  label: 'longest fast',
                  value: _longestFastLabel(weeklyEntries),
                ),
              ],
            ),
          ],
          if (!advancedInsightsUnlocked ||
              !entitlements.has(Entitlement.advancedPlans)) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            PremiumCalloutCard(
              title: 'Premium unlocks extended fasting plans',
              subtitle: fastingPlanPolicy.upgradeMessage,
              actionLabel: 'See premium',
              onPressed:
                  () => openFastingPaywall(
                    context: context,
                    ref: ref,
                    entryPoint: fastingHeaderButtonEntryPoint,
                  ),
            ),
          ],
          if (monetization.entitlementState.message case final String message
              when message.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Text(message, style: theme.textTheme.bodySmall),
            ),
          ],
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

  String _primaryLabel(TimerState state) {
    if (state.isRunning) {
      return 'Pause fast';
    }

    if (state.remaining != state.activeSession.duration) {
      return 'Resume fast';
    }

    return 'Start fast';
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

  String _historyLabel(HabitSessionRecord entry) {
    final DateTime completedAt = entry.completedAtLocal;
    final String hours = completedAt.hour.toString().padLeft(2, '0');
    final String minutes = completedAt.minute.toString().padLeft(2, '0');
    return '${_trackedHoursLabel(entry.durationMinutes)} fast | ${completedAt.month}/${completedAt.day} at $hours:$minutes';
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

class _PremiumButton extends StatelessWidget {
  const _PremiumButton({required this.isPremium, required this.onPressed});

  final bool isPremium;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: FilledButton.tonalIcon(
          onPressed: onPressed,
          icon: Icon(
            isPremium
                ? Icons.workspace_premium_rounded
                : Icons.lock_open_rounded,
          ),
          label: Text(isPremium ? 'Premium' : 'Upgrade'),
        ),
      ),
    );
  }
}
