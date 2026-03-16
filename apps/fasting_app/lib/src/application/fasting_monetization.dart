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
      'Premium unlocks longer fasting plans, removes ads, and keeps your advanced progress tools open.',
);

const PaywallContent fastingPaywallContent = PaywallContent(
  title: 'Upgrade Fasting Flow',
  subtitle:
      'Go premium to remove ads and unlock the full fasting plan library.',
  benefits: <String>[
    'Ad-free fasting sessions',
    'Access to extended 18:6 and 20:4 plans',
    'Unlimited premium fasting tools',
  ],
  monthlyProductId: fastingMonthlyProductId,
  yearlyProductId: fastingYearlyProductId,
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
  return showPaywallSheet(
    context: context,
    controller: controller,
  );
}
