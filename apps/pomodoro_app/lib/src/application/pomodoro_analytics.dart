import 'package:analytics/analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/src/application/pomodoro_monetization.dart';
import 'package:timer_engine/timer_engine.dart';

const String pomodoroAppId = 'pomodoro_app';
const String pomodoroHeaderButtonEntryPoint = 'header_button';
const String pomodoroSessionNotesGateEntryPoint = 'session_notes_gate';

final pomodoroAnalyticsServiceProvider = Provider<AnalyticsService>((_) {
  throw UnimplementedError(
    'pomodoroAnalyticsServiceProvider must be overridden.',
  );
});

Map<String, Object?> pomodoroSessionMetadata(TimerState state) {
  return <String, Object?>{
    'app_id': pomodoroAppId,
    'session_id': state.activeSession.id,
    'session_label': state.activeSession.label,
    'remaining_seconds': state.remaining.inSeconds,
  };
}

AnalyticsEvent pomodoroTimerStartedEvent(TimerState state) {
  return AnalyticsEvent(
    name: AnalyticsEventNames.timerStarted,
    parameters: pomodoroSessionMetadata(state),
  );
}

AnalyticsEvent pomodoroTimerPausedEvent(TimerState state) {
  return AnalyticsEvent(
    name: AnalyticsEventNames.timerPaused,
    parameters: pomodoroSessionMetadata(state),
  );
}

AnalyticsEvent pomodoroTimerResetEvent(TimerState state) {
  return AnalyticsEvent(
    name: AnalyticsEventNames.timerReset,
    parameters: pomodoroSessionMetadata(state),
  );
}

AnalyticsEvent pomodoroSessionCompletedEvent(TimerState state) {
  return AnalyticsEvent(
    name: AnalyticsEventNames.sessionCompleted,
    parameters: <String, Object?>{
      ...pomodoroSessionMetadata(state),
      'completed_tracked_sessions': state.stats.completedTrackedSessions,
      'tracked_minutes': state.stats.trackedMinutes,
    },
  );
}

AnalyticsEvent pomodoroSessionChangedEvent({
  required TimerSession session,
  required String changeSource,
}) {
  return AnalyticsEvent(
    name: AnalyticsEventNames.sessionChanged,
    parameters: <String, Object?>{
      'app_id': pomodoroAppId,
      'session_id': session.id,
      'session_label': session.label,
      'remaining_seconds': session.duration.inSeconds,
      'change_source': changeSource,
    },
  );
}

AnalyticsEvent pomodoroNotificationScheduledEvent(TimerSession session) {
  return AnalyticsEvent(
    name: AnalyticsEventNames.notificationScheduled,
    parameters: <String, Object?>{
      'app_id': pomodoroAppId,
      'session_id': session.id,
      'notification_kind': 'session_completion',
    },
  );
}

AnalyticsEvent pomodoroPaywallOpenedEvent(String entryPoint) {
  return AnalyticsEvent(
    name: AnalyticsEventNames.paywallOpened,
    parameters: <String, Object?>{
      'app_id': pomodoroAppId,
      'entry_point': entryPoint,
    },
  );
}

Future<void> openPomodoroPaywall({
  required BuildContext context,
  required WidgetRef ref,
  required String entryPoint,
}) async {
  final AnalyticsService analytics = ref.read(pomodoroAnalyticsServiceProvider);
  try {
    await analytics.logEvent(pomodoroPaywallOpenedEvent(entryPoint));
  } catch (_) {}
  if (!context.mounted) {
    return;
  }

  await showPomodoroPaywall(context, ref);
}
