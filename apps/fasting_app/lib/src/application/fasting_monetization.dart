import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:monetization/monetization.dart';

const String fastingMonthlyProductId = 'fasting_premium_monthly';
const String fastingYearlyProductId = 'fasting_premium_yearly';
const String fastingEntitlementCacheKey = 'fasting_app.monetization.products';
final String fastingBannerAdUnitId = TestAdUnitIds.banner;

const UsageLimitPolicy fastingPlanPolicy = UsageLimitPolicy(
  featureKey: 'extended_plans',
  title: 'Extended fasting plans',
  freeLimit: 2,
  upgradeMessage:
      'Core fasting plans stay free. Premium adds longer plans, removes light ads, and unlocks deeper progress tools.',
);

const PaywallContent fastingPaywallContent = PaywallContent(
  title: 'Upgrade Fasting Flow',
  subtitle:
      'Go premium for an ad-free experience and the full set of advanced fasting tools.',
  benefits: <String>[
    'Remove the light banner ads',
    'Unlock extended 18:6 and 20:4 fasting plans',
    'Access deeper premium progress tools',
  ],
  monthlyProductId: fastingMonthlyProductId,
  yearlyProductId: fastingYearlyProductId,
  freeTierNote:
      'Starting, pausing, resuming, resetting, and core fasting plans stay free. Premium is for advanced plans and ad-free use.',
);

final fastingMonetizationServiceProvider =
    ChangeNotifierProvider<StoreMonetizationService>((_) {
      throw UnimplementedError(
        'fastingMonetizationServiceProvider must be overridden.',
      );
    });

final fastingAdServiceProvider = Provider<AdService>((_) {
  throw UnimplementedError('fastingAdServiceProvider must be overridden.');
});

Future<void> showFastingPaywall(BuildContext context, WidgetRef ref) {
  final PaywallController controller = PaywallController(
    service: ref.read(fastingMonetizationServiceProvider),
    content: fastingPaywallContent,
  );
  return showPaywallSheet(context: context, controller: controller);
}
