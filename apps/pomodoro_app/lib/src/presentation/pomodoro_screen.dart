import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/src/application/pomodoro_controller.dart';
import 'package:ui_kit/ui_kit.dart';

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pomodoroControllerProvider);
    final controller = ref.read(pomodoroControllerProvider.notifier);
    final theme = Theme.of(context);
    final currentMode = pomodoroModeFromSession(state.activeSession);

    return FactoryScaffold(
      title: 'Focus Flow',
      subtitle:
          'A Phase 1 demo built on shared packages, with one clear action and reusable cards.',
      action: AppPrimaryButton(
        label: state.isRunning ? 'Pause session' : 'Start session',
        icon: Icon(
          state.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
        ),
        onPressed: controller.toggleTimer,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionCard(
            title: 'Current cycle',
            subtitle: 'Switch modes to preview the reusable timer layout.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: PomodoroMode.values.map((PomodoroMode mode) {
                    return _ModeChip(
                      mode: mode,
                      selected: currentMode == mode,
                      onTap: () => controller.selectMode(mode),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.xl),
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
                        state.activeSession.label.toUpperCase(),
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
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.small),
                        child: LinearProgressIndicator(
                          minHeight: 10,
                          value: state.progress < 0
                              ? 0
                              : state.progress > 1
                                  ? 1
                                  : state.progress,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: AppSecondaryButton(
                        label: 'Reset',
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: controller.reset,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppSecondaryButton(
                        label: 'Skip',
                        icon: const Icon(Icons.skip_next_rounded),
                        onPressed: controller.skipToNextMode,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionCard(
            title: 'Today',
            subtitle:
                'Shared stat tiles make it easy to spin up more timer apps later.',
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: StatTile(
                        label: 'Focus sessions',
                        value: '${state.stats.completedTrackedSessions}',
                        detail: 'Completed',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: StatTile(
                        label: 'Minutes deep work',
                        value: '${state.stats.trackedMinutes}',
                        detail: 'Tracked locally',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                StatTile(
                  label: 'Current rhythm',
                  value: _buildRhythmLabel(currentMode),
                  detail: currentMode == PomodoroMode.focus
                      ? 'Stay on task until the bell.'
                      : 'Use the break to reset before the next focus block.',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionCard(
            title: 'Session notes',
            subtitle:
                'A basic shared input is wired in for future app flows without adding Phase 2 storage yet.',
            child: const AppTextField(
              label: 'What matters in this sprint?',
              hintText:
                  'Outline the task you want to finish before the timer ends.',
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  String _buildRhythmLabel(PomodoroMode mode) {
    return switch (mode) {
      PomodoroMode.focus => '25 / 5 cadence',
      PomodoroMode.shortBreak => 'Quick recharge',
      PomodoroMode.longBreak => 'Extended reset',
    };
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final PomodoroMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

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
          mode.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
