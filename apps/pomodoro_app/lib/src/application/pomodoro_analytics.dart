import 'package:analytics/analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monetization/monetization.dart';
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

AnalyticsEvent pomodoroPurchaseStartedEvent(String productId) {
  return AnalyticsEvent(
    name: AnalyticsEventNames.purchaseStarted,
    parameters: <String, Object?>{
      'app_id': pomodoroAppId,
      'product_id': productId,
    },
  );
}

AnalyticsEvent pomodoroPurchaseRestoredEvent() {
  return const AnalyticsEvent(
    name: AnalyticsEventNames.purchaseRestored,
    parameters: <String, Object?>{'app_id': pomodoroAppId},
  );
}

AnalyticsEvent pomodoroEntitlementChangedEvent(EntitlementState state) {
  return AnalyticsEvent(
    name: AnalyticsEventNames.entitlementChanged,
    parameters: <String, Object?>{
      'app_id': pomodoroAppId,
      'is_premium': state.isPremium,
      'source': state.source.name,
      'owned_product_count': state.ownedProductIds.length,
    },
  );
}

class PomodoroPaywallController extends PaywallController {
  PomodoroPaywallController({
    required super.service,
    required super.content,
    required this.analytics,
  });

  final AnalyticsService analytics;

  @override
  Future<void> purchaseMonthly() async {
    try {
      await analytics.logEvent(
        pomodoroPurchaseStartedEvent(content.monthlyProductId),
      );
    } catch (_) {}
    await super.purchaseMonthly();
  }

  @override
  Future<void> purchaseYearly() async {
    try {
      await analytics.logEvent(
        pomodoroPurchaseStartedEvent(content.yearlyProductId),
      );
    } catch (_) {}
    await super.purchaseYearly();
  }

  @override
  Future<void> restorePurchases() async {
    try {
      await analytics.logEvent(pomodoroPurchaseRestoredEvent());
    } catch (_) {}
    await super.restorePurchases();
  }
}

class PomodoroMonetizationAnalyticsBinding {
  PomodoroMonetizationAnalyticsBinding({
    required this.service,
    required this.analytics,
  }) : _previousState = service.entitlementState;

  final StoreMonetizationService service;
  final AnalyticsService analytics;

  EntitlementState _previousState;

  void attach() {
    service.addListener(_onMonetizationChanged);
  }

  void detach() {
    service.removeListener(_onMonetizationChanged);
  }

  void _onMonetizationChanged() {
    final EntitlementState nextState = service.entitlementState;
    final bool changed =
        nextState.isPremium != _previousState.isPremium ||
        nextState.source != _previousState.source ||
        nextState.ownedProductIds.length !=
            _previousState.ownedProductIds.length;

    if (!changed) {
      return;
    }

    _previousState = nextState;
    analytics.logEvent(pomodoroEntitlementChangedEvent(nextState));
  }
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

  final PomodoroPaywallController controller = PomodoroPaywallController(
    service: ref.read(pomodoroMonetizationServiceProvider),
    content: pomodoroPaywallContent,
    analytics: analytics,
  );
  await showPaywallSheet(context: context, controller: controller);
}
