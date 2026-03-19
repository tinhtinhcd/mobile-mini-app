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
      'Go premium for an ad-free experience and the advanced focus tools around your core Pomodoro flow.',
  benefits: <String>[
    'Remove the light banner ads',
    'Unlock custom focus durations and advanced session notes',
    'See deeper weekly focus insights and consistency progress',
    'Keep your core timer flow calm and distraction-free',
  ],
  monthlyProductId: pomodoroMonthlyProductId,
  yearlyProductId: pomodoroYearlyProductId,
  freeTierNote:
      'Focus, pause, resume, reset, and notifications stay free. Premium is for ad-free sessions and advanced focus tools.',
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
