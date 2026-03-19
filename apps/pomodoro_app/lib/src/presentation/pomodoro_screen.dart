import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_engine/habit_engine.dart';
import 'package:monetization/monetization.dart';
import 'package:pomodoro_app/src/application/pomodoro_analytics.dart';
import 'package:pomodoro_app/src/application/pomodoro_controller.dart';
import 'package:pomodoro_app/src/application/pomodoro_habits.dart';
import 'package:pomodoro_app/src/application/pomodoro_monetization.dart';
import 'package:pomodoro_app/src/presentation/pomodoro_app_menu.dart';
import 'package:timer_engine/timer_engine.dart';
import 'package:ui_kit/ui_kit.dart';

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final TimerState state = ref.watch(pomodoroControllerProvider);
    final PomodoroController controller = ref.read(
      pomodoroControllerProvider.notifier,
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
      title: l10n.pomodoroTitle,
      appMenuSpec: pomodoroAppMenuSpec,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.pomodoroCurrentCycle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _ModeStatusBadge(label: _modeLabel(l10n, currentMode)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: TimerDisplayCard(
              key: ValueKey<String>(state.activeSession.id),
              label: _modeLabel(l10n, currentMode),
              timeText: _formatDuration(state.remaining),
              progress: state.progress,
              statusText: _sessionStatusText(l10n, state, currentMode),
              footnote: _timerFootnote(l10n, currentMode),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppPrimaryButton(
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
          const SizedBox(height: AppSpacing.lg),
          CompactStatStrip(
            items: <CompactStatItem>[
              CompactStatItem(
                label: l10n.commonToday,
                value: l10n.pomodoroTodaySessionsValue(
                  todaySessions,
                  dailyGoal,
                ),
              ),
              CompactStatItem(
                label: l10n.pomodoroFocusTime,
                value: '${todayMinutes}m',
              ),
              CompactStatItem(
                label: l10n.commonStreak,
                value: '${streakDays}d',
                highlight: theme.colorScheme.tertiary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              l10n.pomodoroSevenDaySummary(weeklySessions, weeklyMinutes),
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.commonMode,
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
                    label: _modeLabel(l10n, mode),
                    selected: currentMode == mode,
                    leading: Icon(_modeIcon(mode)),
                    onTap: () => controller.selectMode(mode),
                  );
                }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          if (currentMode == PomodoroMode.focus) ...<Widget>[
            Text(
              l10n.pomodoroFocusLength,
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
              SelectionPill(
                label: durationPreset.shortLabel,
                selected: true,
                locked: true,
                onTap:
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
              label: l10n.pomodoroResetAction,
              icon: const Icon(Icons.refresh_rounded),
              onPressed: controller.reset,
            ),
            trailing: AppSecondaryButton(
              label: l10n.pomodoroSkipAction,
              icon: const Icon(Icons.skip_next_rounded),
              onPressed: controller.skipToNextMode,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (recentEntries.isNotEmpty) ...<Widget>[
            Text(
              l10n.commonRecentActivity,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...recentEntries.map(
              (HabitSessionRecord entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  _historyLabel(l10n, entry),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (advancedStatsUnlocked) ...<Widget>[
            Text(
              l10n.pomodoroAdvancedInsights,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            CompactStatStrip(
              items: <CompactStatItem>[
                CompactStatItem(
                  label: l10n.commonActiveDays,
                  value:
                      '${state.stats.activeDaysLastDays(7, referenceDate: now)}/7',
                ),
                CompactStatItem(
                  label: l10n.pomodoroAverageFocus,
                  value: _averageMinutesLabel(weeklySessions, weeklyMinutes),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(
            l10n.pomodoroFocusNote,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (sessionNotesAccess.allowed)
            AppTextField(
              label: l10n.pomodoroFocusNoteLabel,
              hintText: l10n.pomodoroFocusNoteHint,
              maxLines: 3,
            )
          else
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_outline_rounded),
              title: Text(l10n.pomodoroFocusNoteLabel),
              subtitle: Text(sessionNotesAccess.message),
              onTap:
                  () => openPomodoroPaywall(
                    context: context,
                    ref: ref,
                    entryPoint: pomodoroSessionNotesGateEntryPoint,
                  ),
            ),
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

  String _timerFootnote(AppLocalizations l10n, PomodoroMode mode) {
    return switch (mode) {
      PomodoroMode.focus => l10n.pomodoroFocusFootnote,
      PomodoroMode.shortBreak => l10n.pomodoroShortBreakFootnote,
      PomodoroMode.longBreak => l10n.pomodoroLongBreakFootnote,
    };
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

  String _modeLabel(AppLocalizations l10n, PomodoroMode mode) {
    return switch (mode) {
      PomodoroMode.focus => l10n.pomodoroModeFocus,
      PomodoroMode.shortBreak => l10n.pomodoroModeShortBreak,
      PomodoroMode.longBreak => l10n.pomodoroModeLongBreak,
    };
  }

  String _historyLabel(AppLocalizations l10n, HabitSessionRecord entry) {
    final DateTime completedAt = entry.completedAtLocal;
    final String hours = completedAt.hour.toString().padLeft(2, '0');
    final String minutes = completedAt.minute.toString().padLeft(2, '0');
    return l10n.pomodoroHistoryItem(
      entry.durationMinutes,
      completedAt.month,
      completedAt.day,
      '$hours:$minutes',
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
