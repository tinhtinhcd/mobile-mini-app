import 'dart:async';

import 'package:analytics/analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:notifications/notifications.dart';
import 'package:pomodoro_app/src/application/pomodoro_analytics.dart';
import 'package:pomodoro_app/src/application/pomodoro_habits.dart';
import 'package:storage/storage.dart';
import 'package:timer_engine/timer_engine.dart';

const int pomodoroCompletionNotificationId = 1;

final pomodoroControllerProvider =
    NotifierProvider<PomodoroController, TimerState>(PomodoroController.new);
final pomodoroNotificationServiceProvider = Provider<NotificationService>((_) {
  throw UnimplementedError(
    'pomodoroNotificationServiceProvider must be overridden.',
  );
});
final pomodoroSnapshotStoreProvider = Provider<TimerSnapshotStore>((_) {
  throw UnimplementedError('pomodoroSnapshotStoreProvider must be overridden.');
});
final pomodoroRestoredSnapshotProvider = Provider<TimerSnapshot?>((_) => null);
final pomodoroDurationPresetProvider = StateProvider<PomodoroDurationPreset>(
  (_) => PomodoroDurationPreset.classic,
);

enum PomodoroMode {
  focus('Focus'),
  shortBreak('Short break'),
  longBreak('Long break');

  const PomodoroMode(this.label);

  final String label;
}

extension PomodoroModeSession on PomodoroMode {
  TimerSession get session {
    switch (this) {
      case PomodoroMode.focus:
        return const TimerSession(
          id: 'focus',
          label: 'Focus',
          duration: Duration(minutes: 25),
          isTracked: true,
        );
      case PomodoroMode.shortBreak:
        return const TimerSession(
          id: 'shortBreak',
          label: 'Short break',
          duration: Duration(minutes: 5),
          isTracked: false,
        );
      case PomodoroMode.longBreak:
        return const TimerSession(
          id: 'longBreak',
          label: 'Long break',
          duration: Duration(minutes: 15),
          isTracked: false,
        );
    }
  }
}

enum PomodoroDurationPreset {
  classic(
    label: 'Classic',
    shortLabel: '25 min',
    focusDuration: Duration(minutes: 25),
    shortBreakDuration: Duration(minutes: 5),
    longBreakDuration: Duration(minutes: 15),
  ),
  deep(
    label: 'Deep',
    shortLabel: '35 min',
    focusDuration: Duration(minutes: 35),
    shortBreakDuration: Duration(minutes: 7),
    longBreakDuration: Duration(minutes: 20),
  ),
  marathon(
    label: 'Marathon',
    shortLabel: '50 min',
    focusDuration: Duration(minutes: 50),
    shortBreakDuration: Duration(minutes: 10),
    longBreakDuration: Duration(minutes: 25),
  );

  const PomodoroDurationPreset({
    required this.label,
    required this.shortLabel,
    required this.focusDuration,
    required this.shortBreakDuration,
    required this.longBreakDuration,
  });

  final String label;
  final String shortLabel;
  final Duration focusDuration;
  final Duration shortBreakDuration;
  final Duration longBreakDuration;
}

PomodoroMode pomodoroModeFromSession(TimerSession session) {
  return pomodoroModeFromSessionId(session.id);
}

PomodoroMode pomodoroModeFromSessionId(String sessionId) {
  switch (sessionId) {
    case 'focus':
      return PomodoroMode.focus;
    case 'shortBreak':
      return PomodoroMode.shortBreak;
    case 'longBreak':
      return PomodoroMode.longBreak;
  }
  return PomodoroMode.focus;
}

class PomodoroController extends TimerController {
  @override
  TimerSession get initialSession => _sessionForMode(PomodoroMode.focus);

  @override
  TimerSnapshot? get restoredSnapshot =>
      ref.read(pomodoroRestoredSnapshotProvider);

  AnalyticsService get _analytics => ref.read(pomodoroAnalyticsServiceProvider);

  NotificationService get _notificationService =>
      ref.read(pomodoroNotificationServiceProvider);

  @override
  Future<void> persistSnapshot(TimerSnapshot snapshot) {
    return ref.read(pomodoroSnapshotStoreProvider).writeSnapshot(snapshot);
  }

  @override
  TimerSession restoreSession(String sessionId) {
    return _sessionForMode(pomodoroModeFromSessionId(sessionId));
  }

  void selectMode(PomodoroMode mode) {
    selectSession(_sessionForMode(mode));
    unawaited(
      _logEventSafely(
        pomodoroSessionChangedEvent(
          session: _sessionForMode(mode),
          changeSource: 'mode_selected',
        ),
      ),
    );
  }

  void selectDurationPreset(PomodoroDurationPreset preset) {
    ref.read(pomodoroDurationPresetProvider.notifier).state = preset;

    if (!state.isRunning) {
      selectSession(
        _sessionForMode(pomodoroModeFromSession(state.activeSession)),
      );
    }

    unawaited(
      _logEventSafely(
        AnalyticsEvent(
          name: 'pomodoro_duration_preset_changed',
          parameters: <String, Object?>{'preset': preset.label},
        ),
      ),
    );
  }

  void skipToNextMode() {
    final TimerSession nextSession = resolveNextSession(state);
    skipToNextSession();
    unawaited(
      _logEventSafely(
        pomodoroSessionChangedEvent(
          session: nextSession,
          changeSource: 'skip_to_next_mode',
        ),
      ),
    );
  }

  @override
  TimerSession resolveNextSession(TimerState completedState) {
    final currentMode = pomodoroModeFromSession(completedState.activeSession);
    final completedFocusSessions =
        completedState.stats.completedTrackedSessions;

    switch (currentMode) {
      case PomodoroMode.focus:
        return completedFocusSessions % 4 == 0
            ? _sessionForMode(PomodoroMode.longBreak)
            : _sessionForMode(PomodoroMode.shortBreak);
      case PomodoroMode.shortBreak:
      case PomodoroMode.longBreak:
        return _sessionForMode(PomodoroMode.focus);
    }
  }

  TimerSession _sessionForMode(PomodoroMode mode) {
    final PomodoroDurationPreset preset = ref.read(
      pomodoroDurationPresetProvider,
    );
    switch (mode) {
      case PomodoroMode.focus:
        return TimerSession(
          id: 'focus',
          label: 'Focus',
          duration: preset.focusDuration,
          isTracked: true,
        );
      case PomodoroMode.shortBreak:
        return TimerSession(
          id: 'shortBreak',
          label: 'Short break',
          duration: preset.shortBreakDuration,
          isTracked: false,
        );
      case PomodoroMode.longBreak:
        return TimerSession(
          id: 'longBreak',
          label: 'Long break',
          duration: preset.longBreakDuration,
          isTracked: false,
        );
    }
  }

  @override
  Future<void> onTimerStarted(TimerState state) async {
    await _logEventSafely(pomodoroTimerStartedEvent(state));
    final (String title, String body) = _notificationContentForSession(
      pomodoroModeFromSession(state.activeSession),
    );
    await _notificationService.scheduleNotification(
      id: pomodoroCompletionNotificationId,
      title: title,
      body: body,
      scheduledAt: DateTime.now().add(state.remaining),
    );
    await _logEventSafely(
      pomodoroNotificationScheduledEvent(state.activeSession),
    );
  }

  @override
  Future<void> onTimerPaused(TimerState state) async {
    await _logEventSafely(pomodoroTimerPausedEvent(state));
    await _cancelScheduledNotification();
  }

  @override
  Future<void> onTimerReset(TimerState state) async {
    await _logEventSafely(pomodoroTimerResetEvent(state));
    await _cancelScheduledNotification();
  }

  @override
  Future<void> onSessionChanged(TimerState state) {
    return _cancelScheduledNotification();
  }

  @override
  Future<void> onSessionCompleted(
    TimerState completedState,
    TimerSession nextSession,
  ) async {
    await _logEventSafely(pomodoroSessionCompletedEvent(completedState));
    await _cancelScheduledNotification();
    await ref
        .read(pomodoroHabitTrackerProvider)
        .trackCompletedSession(completedState);
  }

  Future<void> _cancelScheduledNotification() {
    return _notificationService.cancelNotification(
      pomodoroCompletionNotificationId,
    );
  }

  (String, String) _notificationContentForSession(PomodoroMode mode) {
    switch (mode) {
      case PomodoroMode.focus:
        return ('Pomodoro Complete', 'Time for a break.');
      case PomodoroMode.shortBreak:
      case PomodoroMode.longBreak:
        return ('Break Complete', 'Time to focus again.');
    }
  }

  Future<void> _logEventSafely(AnalyticsEvent event) async {
    try {
      await _analytics.logEvent(event);
    } catch (_) {}
  }
}
