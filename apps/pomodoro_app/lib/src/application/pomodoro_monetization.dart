import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:monetization/monetization.dart';

const String pomodoroMonthlyProductId = 'pomodoro_premium_monthly';
const String pomodoroYearlyProductId = 'pomodoro_premium_yearly';
const String pomodoroEntitlementCacheKey = 'pomodoro_app.monetization.products';
final String pomodoroBannerAdUnitId = TestAdUnitIds.banner;

const UsageLimitPolicy pomodoroUnlimitedSessionsPolicy = UsageLimitPolicy(
  featureKey: 'unlimited_sessions',
  title: 'Unlimited focus sessions',
  freeLimit: 4,
  upgradeMessage:
      'Free includes 4 focus sessions per day. Premium removes the daily session cap and unlocks advanced tools.',
);

const UsageLimitPolicy
pomodoroSessionNotesPolicy = UsageLimitPolicy.premiumOnly(
  featureKey: 'session_notes',
  title: 'Session notes',
  upgradeMessage:
      'Core timers stay free. Premium adds richer session notes, removes light ads, and unlocks deeper focus tools.',
);

const UsageLimitPolicy
pomodoroCustomDurationsPolicy = UsageLimitPolicy.premiumOnly(
  featureKey: 'custom_durations',
  title: 'Custom focus durations',
  upgradeMessage:
      'Premium unlocks longer focus presets, deeper stats, and richer focus tools around your free timer flow.',
);

const PaywallContent pomodoroPaywallContent = PaywallContent(
  title: 'Upgrade Focus Flow',
  subtitle:
      'Go premium for an ad-free experience and a focus coach that tells you when you are behind, what to do next, and how your week is trending.',
  benefits: <String>[
    'Remove the light banner ads',
    'Unlock on-track or behind status with recovery actions',
    'See a weekly consistency score, weekly review, and best focus window',
    'Get a suggested session target and what to do next when momentum slips',
    'Keep your core timer flow calm and distraction-free',
  ],
  monthlyProductId: pomodoroMonthlyProductId,
  yearlyProductId: pomodoroYearlyProductId,
  freeTierNote:
      'Focus, pause, resume, reset, and notifications stay free. Premium is for accountability, recovery guidance, weekly review, and an ad-free flow.',
);

final pomodoroMonetizationServiceProvider =
    ChangeNotifierProvider<StoreMonetizationService>((_) {
      throw UnimplementedError(
        'pomodoroMonetizationServiceProvider must be overridden.',
      );
    });

final pomodoroAdServiceProvider = Provider<AdService>((_) {
  throw UnimplementedError('pomodoroAdServiceProvider must be overridden.');
});

final entitlementProvider = ChangeNotifierProvider<EntitlementService>((ref) {
  final StoreMonetizationService monetization = ref.watch(
    pomodoroMonetizationServiceProvider,
  );
  return MonetizationEntitlementService(
    monetizationService: monetization,
    premiumEntitlements: const <Entitlement>{
      Entitlement.unlimitedSessions,
      Entitlement.advancedStats,
      Entitlement.customModes,
      Entitlement.noAds,
    },
  );
});

Future<void> showPomodoroPaywall(BuildContext context, WidgetRef ref) {
  final PaywallController controller = PaywallController(
    service: ref.read(pomodoroMonetizationServiceProvider),
    content: pomodoroPaywallContent,
  );
  return showPaywallSheet(context: context, controller: controller);
}
