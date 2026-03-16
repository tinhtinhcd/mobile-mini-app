import 'package:analytics/analytics.dart';
import 'package:fasting_app/src/application/fasting_monetization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monetization/monetization.dart';
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

AnalyticsEvent fastingPurchaseStartedEvent(String productId) {
  return AnalyticsEvent(
    name: AnalyticsEventNames.purchaseStarted,
    parameters: <String, Object?>{
      'app_id': fastingAppId,
      'product_id': productId,
    },
  );
}

AnalyticsEvent fastingPurchaseRestoredEvent() {
  return const AnalyticsEvent(
    name: AnalyticsEventNames.purchaseRestored,
    parameters: <String, Object?>{'app_id': fastingAppId},
  );
}

AnalyticsEvent fastingEntitlementChangedEvent(EntitlementState state) {
  return AnalyticsEvent(
    name: AnalyticsEventNames.entitlementChanged,
    parameters: <String, Object?>{
      'app_id': fastingAppId,
      'is_premium': state.isPremium,
      'source': state.source.name,
      'owned_product_count': state.ownedProductIds.length,
    },
  );
}

class FastingPaywallController extends PaywallController {
  FastingPaywallController({
    required super.service,
    required super.content,
    required this.analytics,
  });

  final AnalyticsService analytics;

  @override
  Future<void> purchaseMonthly() async {
    try {
      await analytics.logEvent(
        fastingPurchaseStartedEvent(content.monthlyProductId),
      );
    } catch (_) {}
    await super.purchaseMonthly();
  }

  @override
  Future<void> purchaseYearly() async {
    try {
      await analytics.logEvent(
        fastingPurchaseStartedEvent(content.yearlyProductId),
      );
    } catch (_) {}
    await super.purchaseYearly();
  }

  @override
  Future<void> restorePurchases() async {
    try {
      await analytics.logEvent(fastingPurchaseRestoredEvent());
    } catch (_) {}
    await super.restorePurchases();
  }
}

class FastingMonetizationAnalyticsBinding {
  FastingMonetizationAnalyticsBinding({
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
    analytics.logEvent(fastingEntitlementChangedEvent(nextState));
  }
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

  final FastingPaywallController controller = FastingPaywallController(
    service: ref.read(fastingMonetizationServiceProvider),
    content: fastingPaywallContent,
    analytics: analytics,
  );
  await showPaywallSheet(context: context, controller: controller);
}
