import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_engine/habit_engine.dart';
import 'package:monetization/monetization.dart';
import 'package:pomodoro_app/src/application/pomodoro_analytics.dart';
import 'package:pomodoro_app/src/application/pomodoro_controller.dart';
import 'package:pomodoro_app/src/application/pomodoro_habits.dart';
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
    final EntitlementService entitlements = ref.watch(entitlementProvider);
    final AdService adService = ref.read(pomodoroAdServiceProvider);
    final HabitService habits = ref.watch(pomodoroHabitServiceProvider);
    final ThemeData theme = Theme.of(context);
    final PomodoroMode currentMode = pomodoroModeFromSession(
      state.activeSession,
    );
    final PomodoroDurationPreset durationPreset = ref.watch(
      pomodoroDurationPresetProvider,
    );
    final DateTime now = DateTime.now();
    final int todaySessions = habits.todayCount;
    final int todayMinutes = habits.todayMinutes;
    final int weeklySessions = habits.weeklyCount;
    final int weeklyMinutes = habits.weeklyMinutes;
    final int streakDays = habits.currentStreak;
    final int dailyGoal = habits.dailyGoal;
    final List<HabitSessionRecord> recentEntries = habits.recentRecords(
      limit: 3,
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
    final UsageLimitResult sessionNotesAccess = pomodoroSessionNotesPolicy
        .evaluateWithEntitlements(
          entitlementService: entitlements,
          premiumEntitlement: Entitlement.advancedStats,
          usageCount: 1,
        );
    final UsageLimitResult customDurationsAccess = pomodoroCustomDurationsPolicy
        .evaluateWithEntitlements(
          entitlementService: entitlements,
          premiumEntitlement: Entitlement.customModes,
          usageCount: 1,
        );
    final bool advancedStatsUnlocked = entitlements.has(
      Entitlement.advancedStats,
    );

    return FactoryScaffold(
      title: 'Focus Flow',
      headerTrailing: _PremiumButton(
        isPremium: monetization.isPremium,
        onPressed:
            () => openPomodoroPaywall(
              context: context,
              ref: ref,
              entryPoint: pomodoroHeaderButtonEntryPoint,
            ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Current cycle',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _ModeStatusBadge(label: currentMode.label),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
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
          const SizedBox(height: AppSpacing.md),
          AppPrimaryButton(
            label: _primaryLabel(state, currentMode),
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
          const SizedBox(height: AppSpacing.lg),
          CompactStatStrip(
            items: <CompactStatItem>[
              CompactStatItem(
                label: 'today',
                value: '$todaySessions/$dailyGoal sessions',
              ),
              CompactStatItem(label: 'focus time', value: '${todayMinutes}m'),
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
              '7-day summary: $weeklySessions sessions | $weeklyMinutes minutes deep work',
              style: theme.textTheme.bodySmall,
            ),
          ),
          if (!entitlements.has(Entitlement.unlimitedSessions))
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.xs,
                left: AppSpacing.xs,
                right: AppSpacing.xs,
              ),
              child: Text(
                unlimitedSessionsAccess.allowed
                    ? '${unlimitedSessionsAccess.remainingFreeUses} free focus sessions left today.'
                    : pomodoroUnlimitedSessionsPolicy.upgradeMessage,
                style: theme.textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Mode',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
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
          const SizedBox(height: AppSpacing.md),
          if (currentMode == PomodoroMode.focus) ...<Widget>[
            Text(
              'Focus length',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (customDurationsAccess.allowed)
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children:
                    PomodoroDurationPreset.values.map((
                      PomodoroDurationPreset preset,
                    ) {
                      return SelectionPill(
                        label: preset.shortLabel,
                        selected: durationPreset == preset,
                        onTap: () => controller.selectDurationPreset(preset),
                      );
                    }).toList(),
              )
            else
              PremiumCalloutCard(
                title: 'Custom focus lengths are Premium',
                subtitle: customDurationsAccess.message,
                actionLabel: 'Unlock premium',
                onPressed:
                    () => openPomodoroPaywall(
                      context: context,
                      ref: ref,
                      entryPoint: pomodoroHeaderButtonEntryPoint,
                    ),
              ),
            const SizedBox(height: AppSpacing.md),
          ],
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
          const SizedBox(height: AppSpacing.lg),
          if (recentEntries.isNotEmpty) ...<Widget>[
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
            const SizedBox(height: AppSpacing.md),
          ],
          if (advancedStatsUnlocked) ...<Widget>[
            Text(
              'Advanced insights',
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
                  label: 'avg focus',
                  value: _averageMinutesLabel(weeklySessions, weeklyMinutes),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(
            'Focus note',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (sessionNotesAccess.allowed)
            const AppTextField(
              label: 'What matters right now?',
              hintText: 'Write the one thing this session is for.',
              maxLines: 3,
            )
          else
            PremiumCalloutCard(
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
        startupAppId: 'pomodoro_app',
        adService: adService,
        entitlementService: entitlements,
        adUnitId: pomodoroBannerAdUnitId,
      ),
    );
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

  String _averageMinutesLabel(int weeklySessions, int weeklyMinutes) {
    if (weeklySessions == 0) {
      return '0m';
    }
    return '${(weeklyMinutes / weeklySessions).round()}m';
  }

  String _historyLabel(HabitSessionRecord entry) {
    final DateTime completedAt = entry.completedAtLocal;
    final String hours = completedAt.hour.toString().padLeft(2, '0');
    final String minutes = completedAt.minute.toString().padLeft(2, '0');
    return '${entry.durationMinutes}m focus | ${completedAt.month}/${completedAt.day} at $hours:$minutes';
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
