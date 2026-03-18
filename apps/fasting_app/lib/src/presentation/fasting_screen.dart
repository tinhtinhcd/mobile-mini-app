import 'package:app_core/app_core.dart';
import 'package:fasting_app/src/application/fasting_analytics.dart';
import 'package:fasting_app/src/application/fasting_controller.dart';
import 'package:fasting_app/src/application/fasting_monetization.dart';
import 'package:fasting_app/src/domain/fasting_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final AdService adService = ref.read(fastingAdServiceProvider);
    final ThemeData theme = Theme.of(context);
    final FastingPlan selectedPlan = controller.selectedPlan;

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
          const SizedBox(height: AppSpacing.sm),
          AppSecondaryButton(
            label: 'Reset fast',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.reset,
          ),
          const SizedBox(height: AppSpacing.lg),
          CompactSection(
            title: 'Plans',
            subtitle: 'Choose the fasting rhythm you want to follow today.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children:
                      FastingPlan.values.asMap().entries.map((
                        MapEntry<int, FastingPlan> entry,
                      ) {
                        final UsageLimitResult access = fastingPlanPolicy
                            .evaluate(
                              entitlement: monetization.entitlementState,
                              usageCount: entry.key + 1,
                            );

                        return SelectionPill(
                          label: entry.value.label,
                          selected:
                              entry.value == selectedPlan && access.allowed,
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
                if (!monetization.isPremium) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
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
                const SizedBox(height: AppSpacing.sm),
                SettingsTile(
                  title: 'Eating window',
                  subtitle: selectedPlan.description,
                  leading: const Icon(Icons.restaurant_rounded),
                  trailing: _PlanBadge(label: selectedPlan.eatingWindowLabel),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          CompactSection(
            title: 'Progress',
            subtitle: 'A compact summary of your fasting streak so far.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CompactStatStrip(
                  items: <CompactStatItem>[
                    CompactStatItem(
                      label: 'completed fasts',
                      value: '${state.stats.completedTrackedSessions}',
                    ),
                    CompactStatItem(
                      label: 'tracked hours',
                      value: _trackedHoursLabel(state.stats.trackedMinutes),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SettingsTile(
                  title: 'Current plan',
                  subtitle: selectedPlan.description,
                  leading: const Icon(Icons.schedule_rounded),
                  trailing: _PlanBadge(label: selectedPlan.label),
                ),
              ],
            ),
          ),
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
        entitlementState: monetization.entitlementState,
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
