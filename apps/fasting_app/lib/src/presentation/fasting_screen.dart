import 'package:app_core/app_core.dart';
import 'package:fasting_app/src/application/fasting_controller.dart';
import 'package:fasting_app/src/domain/fasting_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timer_engine/timer_engine.dart';
import 'package:ui_kit/ui_kit.dart';

class FastingScreen extends ConsumerWidget {
  const FastingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TimerState state = ref.watch(fastingControllerProvider);
    final FastingController controller =
        ref.read(fastingControllerProvider.notifier);
    final ThemeData theme = Theme.of(context);
    final FastingPlan selectedPlan = controller.selectedPlan;

    return FactoryScaffold(
      title: 'Fasting Flow',
      subtitle:
          'Track your current fast with shared timer infrastructure and app-specific fasting presets.',
      action: AppPrimaryButton(
        label: _primaryLabel(state),
        icon: Icon(_primaryIcon(state)),
        onPressed: controller.toggleTimer,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionCard(
            title: 'Plans',
            subtitle: 'Choose the fasting rhythm you want to follow today.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: FastingPlan.values.map((FastingPlan plan) {
                    return _PlanChip(
                      plan: plan,
                      selected: plan == selectedPlan,
                      onTap: () => controller.selectPlan(plan),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                StatTile(
                  label: 'Eating window',
                  value: selectedPlan.eatingWindowLabel,
                  detail: selectedPlan.description,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionCard(
            title: 'Current fast',
            subtitle: 'The shared engine handles the countdown. This app only defines fasting rules.',
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppRadius.large),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        selectedPlan.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _formatDuration(state.remaining),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        state.isRunning
                            ? 'Fast in progress'
                            : state.remaining == state.activeSession.duration
                                ? 'Ready to begin'
                                : 'Paused',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.small),
                        child: LinearProgressIndicator(
                          minHeight: 10,
                          value: _clampProgress(state.progress),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppSecondaryButton(
                  label: 'Reset fast',
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: controller.reset,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionCard(
            title: 'Progress',
            subtitle: 'A small proof that both timer apps share the same stats engine.',
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: StatTile(
                        label: 'Completed fasts',
                        value: '${state.stats.completedTrackedSessions}',
                        detail: 'Tracked sessions',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: StatTile(
                        label: 'Tracked hours',
                        value: _trackedHoursLabel(state.stats.trackedMinutes),
                        detail: 'Accumulated fasting time',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                StatTile(
                  label: 'Current plan',
                  value: selectedPlan.label,
                  detail: selectedPlan.description,
                ),
              ],
            ),
          ),
        ],
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
    final String minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
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

class _PlanChip extends StatelessWidget {
  const _PlanChip({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final FastingPlan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primary = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? primary : AppColors.divider,
          ),
        ),
        child: Text(
          plan.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
