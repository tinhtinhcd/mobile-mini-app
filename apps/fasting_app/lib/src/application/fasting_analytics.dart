import 'package:analytics/analytics.dart';
import 'package:fasting_app/src/application/fasting_monetization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timer_engine/timer_engine.dart';

const String fastingAppId = 'fasting_app';
const String fastingHeaderButtonEntryPoint = 'header_button';
const String fastingLockedPlanEntryPoint = 'locked_plan';

final fastingAnalyticsServiceProvider = Provider<AnalyticsService>((_) {
  throw UnimplementedError(
    'fastingAnalyticsServiceProvider must be overridden.',
  );
});

Map<String, Object?> fastingSessionMetadata(TimerState state) {
  return <String, Object?>{
    'app_id': fastingAppId,
    'session_id': state.activeSession.id,
    'session_label': state.activeSession.label,
    'remaining_seconds': state.remaining.inSeconds,
  };
}

AnalyticsEvent fastingTimerStartedEvent(TimerState state) {
  return AnalyticsEvent(
    name: AnalyticsEventNames.timerStarted,
    parameters: fastingSessionMetadata(state),
  );
}

AnalyticsEvent fastingTimerPausedEvent(TimerState state) {
  return AnalyticsEvent(
    name: AnalyticsEventNames.timerPaused,
    parameters: fastingSessionMetadata(state),
  );
}

AnalyticsEvent fastingTimerResetEvent(TimerState state) {
  return AnalyticsEvent(
    name: AnalyticsEventNames.timerReset,
    parameters: fastingSessionMetadata(state),
  );
}

AnalyticsEvent fastingSessionCompletedEvent(TimerState state) {
  return AnalyticsEvent(
    name: AnalyticsEventNames.sessionCompleted,
    parameters: <String, Object?>{
      ...fastingSessionMetadata(state),
      'completed_tracked_sessions': state.stats.completedTrackedSessions,
      'tracked_minutes': state.stats.trackedMinutes,
    },
  );
}

AnalyticsEvent fastingSessionChangedEvent(TimerSession session) {
  return AnalyticsEvent(
    name: AnalyticsEventNames.sessionChanged,
    parameters: <String, Object?>{
      'app_id': fastingAppId,
      'session_id': session.id,
      'session_label': session.label,
      'remaining_seconds': session.duration.inSeconds,
      'change_source': 'plan_selected',
    },
  );
}

AnalyticsEvent fastingNotificationScheduledEvent(TimerSession session) {
  return AnalyticsEvent(
    name: AnalyticsEventNames.notificationScheduled,
    parameters: <String, Object?>{
      'app_id': fastingAppId,
      'session_id': session.id,
      'notification_kind': 'session_completion',
    },
  );
}

AnalyticsEvent fastingPaywallOpenedEvent(String entryPoint) {
  return AnalyticsEvent(
    name: AnalyticsEventNames.paywallOpened,
    parameters: <String, Object?>{
      'app_id': fastingAppId,
      'entry_point': entryPoint,
    },
  );
}

Future<void> openFastingPaywall({
  required BuildContext context,
  required WidgetRef ref,
  required String entryPoint,
}) async {
  final AnalyticsService analytics = ref.read(fastingAnalyticsServiceProvider);
  try {
    await analytics.logEvent(fastingPaywallOpenedEvent(entryPoint));
  } catch (_) {}
  if (!context.mounted) {
    return;
  }

  await showFastingPaywall(context, ref);
}
