import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:monetization/monetization.dart';

const String pomodoroMonthlyProductId = 'pomodoro_premium_monthly';
const String pomodoroYearlyProductId = 'pomodoro_premium_yearly';
const String pomodoroEntitlementCacheKey =
    'pomodoro_app.monetization.products';
final String pomodoroBannerAdUnitId = TestAdUnitIds.banner;

const UsageLimitPolicy pomodoroSessionNotesPolicy =
    UsageLimitPolicy.premiumOnly(
      featureKey: 'session_notes',
      title: 'Session notes',
      upgradeMessage:
          'Premium unlocks session notes, ad-free focus sessions, and full insights.',
    );

const PaywallContent pomodoroPaywallContent = PaywallContent(
  title: 'Upgrade Focus Flow',
  subtitle:
      'Go premium to remove ads and unlock the deeper focus tools in Pomodoro.',
  benefits: <String>[
    'Ad-free focus sessions',
    'Unlimited advanced session notes',
    'Full access to premium productivity features',
  ],
  monthlyProductId: pomodoroMonthlyProductId,
  yearlyProductId: pomodoroYearlyProductId,
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
  return showPaywallSheet(
    context: context,
    controller: controller,
  );
}
