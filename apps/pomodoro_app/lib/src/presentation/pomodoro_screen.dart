import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monetization/monetization.dart';
import 'package:pomodoro_app/src/application/pomodoro_analytics.dart';
import 'package:pomodoro_app/src/application/pomodoro_controller.dart';
import 'package:pomodoro_app/src/application/pomodoro_monetization.dart';
import 'package:timer_engine/timer_engine.dart';
import 'package:ui_kit/ui_kit.dart';

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TimerState state = ref.watch(pomodoroControllerProvider);
    final PomodoroController controller = ref.read(
      pomodoroControllerProvider.notifier,
    );
    final StoreMonetizationService monetization = ref.watch(
      pomodoroMonetizationServiceProvider,
    );
    final AdService adService = ref.read(pomodoroAdServiceProvider);
    final ThemeData theme = Theme.of(context);
    final PomodoroMode currentMode = pomodoroModeFromSession(
      state.activeSession,
    );
    final UsageLimitResult sessionNotesAccess = pomodoroSessionNotesPolicy
        .evaluate(entitlement: monetization.entitlementState, usageCount: 1);

    return FactoryScaffold(
      title: 'Focus Flow',
      subtitle:
          'A calm timer for focused work, deliberate breaks, and a cleaner daily rhythm.',
      headerTrailing: _PremiumButton(
        isPremium: monetization.isPremium,
        onPressed:
            () => openPomodoroPaywall(
              context: context,
              ref: ref,
              entryPoint: pomodoroHeaderButtonEntryPoint,
            ),
      ),
      action: AppPrimaryButton(
        label: _primaryLabel(state, currentMode),
        icon: Icon(_primaryIcon(state)),
        onPressed: controller.toggleTimer,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SectionCard(
            title: 'Current cycle',
            subtitle: 'Keep one task in focus and let the timer set the pace.',
            trailing: _ModeStatusBadge(label: currentMode.label),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: TimerDisplayCard(
                    key: ValueKey<String>(state.activeSession.id),
                    label: state.activeSession.label,
                    timeText: _formatDuration(state.remaining),
                    progress: state.progress,
                    statusText: _sessionStatusText(state, currentMode),
                    footnote: _timerFootnote(currentMode),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SupportPanel(
                  title: 'Mode',
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children:
                        PomodoroMode.values.map((PomodoroMode mode) {
                          return SelectionPill(
                            label: mode.label,
                            selected: currentMode == mode,
                            leading: Icon(_modeIcon(mode)),
                            onTap: () => controller.selectMode(mode),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Quick actions',
                  style: theme.textTheme.bodySmall?.copyWith(
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ResponsiveButtonRow(
                  leading: AppSecondaryButton(
                    label: 'Reset',
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: controller.reset,
                  ),
                  trailing: AppSecondaryButton(
                    label: 'Skip',
                    icon: const Icon(Icons.skip_next_rounded),
                    onPressed: controller.skipToNextMode,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionCard(
            title: 'Today at a glance',
            subtitle: 'A compact view of your focus momentum so far.',
            child: Column(
              children: <Widget>[
                _ResponsiveMetricRow(
                  leading: StatTile(
                    label: 'Focus sessions',
                    value: '${state.stats.completedTrackedSessions}',
                    detail:
                        state.stats.completedTrackedSessions == 0
                            ? 'Start one session to build momentum'
                            : 'Completed today',
                  ),
                  trailing: StatTile(
                    label: 'Minutes deep work',
                    value: '${state.stats.trackedMinutes}',
                    detail:
                        state.stats.trackedMinutes == 0
                            ? 'No tracked minutes yet'
                            : 'Tracked locally',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SettingsTile(
                  title: 'Current rhythm',
                  subtitle:
                      currentMode == PomodoroMode.focus
                          ? 'Stay on task until the bell.'
                          : 'Use the break to reset before the next focus block.',
                  leading: Icon(_modeIcon(currentMode)),
                  trailing: _ModeStatusBadge(
                    label: _buildRhythmLabel(currentMode),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionCard(
            title: 'Focus note',
            subtitle: 'Keep a short prompt for the task in front of you.',
            child:
                sessionNotesAccess.allowed
                    ? const AppTextField(
                      label: 'What matters right now?',
                      hintText: 'Write the one thing this session is for.',
                      maxLines: 3,
                    )
                    : PremiumCalloutCard(
                      title: 'Session notes are part of Premium',
                      subtitle: sessionNotesAccess.message,
                      actionLabel: 'Unlock premium',
                      onPressed:
                          () => openPomodoroPaywall(
                            context: context,
                            ref: ref,
                            entryPoint: pomodoroSessionNotesGateEntryPoint,
                          ),
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
          const SizedBox(height: AppSpacing.md),
          MonetizationBanner(
            adService: adService,
            entitlementState: monetization.entitlementState,
            adUnitId: pomodoroBannerAdUnitId,
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

  String _sessionStatusText(TimerState state, PomodoroMode mode) {
    if (state.isRunning) {
      return mode == PomodoroMode.focus
          ? 'Focus in progress'
          : 'Break in progress';
    }

    if (state.remaining == state.activeSession.duration) {
      return 'Ready to begin';
    }

    return 'Paused';
  }

  String _timerFootnote(PomodoroMode mode) {
    return switch (mode) {
      PomodoroMode.focus => 'Stay with a single task until the timer ends.',
      PomodoroMode.shortBreak =>
        'Take a quick reset, then come back with clarity.',
      PomodoroMode.longBreak =>
        'Step away for a longer recharge before the next block.',
    };
  }

  String _primaryLabel(TimerState state, PomodoroMode mode) {
    if (state.isRunning) {
      return mode == PomodoroMode.focus ? 'Pause focus' : 'Pause break';
    }

    if (state.remaining != state.activeSession.duration) {
      return mode == PomodoroMode.focus ? 'Resume focus' : 'Resume break';
    }

    return mode == PomodoroMode.focus ? 'Start focus session' : 'Start break';
  }

  IconData _primaryIcon(TimerState state) {
    if (state.isRunning) {
      return Icons.pause_rounded;
    }

    return Icons.play_arrow_rounded;
  }

  IconData _modeIcon(PomodoroMode mode) {
    return switch (mode) {
      PomodoroMode.focus => Icons.bolt_rounded,
      PomodoroMode.shortBreak => Icons.coffee_rounded,
      PomodoroMode.longBreak => Icons.hotel_rounded,
    };
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
        borderRadius: BorderRadius.circular(999),
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

class _SupportPanel extends StatelessWidget {
  const _SupportPanel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          theme.colorScheme.primary.withValues(alpha: 0.04),
          theme.colorScheme.surface,
        ),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title.toUpperCase(),
              style: theme.textTheme.bodySmall?.copyWith(
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}

class _ResponsiveButtonRow extends StatelessWidget {
  const _ResponsiveButtonRow({required this.leading, required this.trailing});

  final Widget leading;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 420) {
          return Column(
            children: <Widget>[
              leading,
              const SizedBox(height: AppSpacing.md),
              trailing,
            ],
          );
        }

        return Row(
          children: <Widget>[
            Expanded(child: leading),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: trailing),
          ],
        );
      },
    );
  }
}

class _ResponsiveMetricRow extends StatelessWidget {
  const _ResponsiveMetricRow({required this.leading, required this.trailing});

  final Widget leading;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 420) {
          return Column(
            children: <Widget>[
              leading,
              const SizedBox(height: AppSpacing.md),
              trailing,
            ],
          );
        }

        return Row(
          children: <Widget>[
            Expanded(child: leading),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: trailing),
          ],
        );
      },
    );
  }
}
