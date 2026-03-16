import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:monetization/monetization.dart';

const String pomodoroMonthlyProductId = 'pomodoro_premium_monthly';
const String pomodoroYearlyProductId = 'pomodoro_premium_yearly';
const String pomodoroEntitlementCacheKey = 'pomodoro_app.monetization.products';
final String pomodoroBannerAdUnitId = TestAdUnitIds.banner;

const UsageLimitPolicy
pomodoroSessionNotesPolicy = UsageLimitPolicy.premiumOnly(
  featureKey: 'session_notes',
  title: 'Session notes',
  upgradeMessage:
      'Core timers stay free. Premium adds richer session notes, removes light ads, and unlocks deeper focus tools.',
);

const PaywallContent pomodoroPaywallContent = PaywallContent(
  title: 'Upgrade Focus Flow',
  subtitle:
      'Go premium for an ad-free experience and the advanced focus tools around your core Pomodoro flow.',
  benefits: <String>[
    'Remove the light banner ads',
    'Unlock advanced session notes and deeper focus tools',
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

Future<void> showPomodoroPaywall(BuildContext context, WidgetRef ref) {
  final PaywallController controller = PaywallController(
    service: ref.read(pomodoroMonetizationServiceProvider),
    content: pomodoroPaywallContent,
  );
  return showPaywallSheet(context: context, controller: controller);
}
