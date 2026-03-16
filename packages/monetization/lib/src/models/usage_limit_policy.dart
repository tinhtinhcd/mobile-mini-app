import 'package:monetization/src/models/entitlement_state.dart';
import 'package:monetization/src/models/usage_limit_result.dart';

class UsageLimitPolicy {
  const UsageLimitPolicy({
    required this.featureKey,
    required this.title,
    required this.freeLimit,
    required this.upgradeMessage,
  });

  const UsageLimitPolicy.premiumOnly({
    required this.featureKey,
    required this.title,
    required this.upgradeMessage,
  }) : freeLimit = 0;

  final String featureKey;
  final String title;
  final int freeLimit;
  final String upgradeMessage;

  UsageLimitResult evaluate({
    required EntitlementState entitlement,
    required int usageCount,
  }) {
    if (entitlement.isPremium) {
      return const UsageLimitResult(
        allowed: true,
        requiresPremium: false,
        remainingFreeUses: -1,
        message: '',
      );
    }

    if (usageCount <= freeLimit) {
      return UsageLimitResult(
        allowed: true,
        requiresPremium: false,
        remainingFreeUses: freeLimit - usageCount,
        message: '',
      );
    }

    return UsageLimitResult(
      allowed: false,
      requiresPremium: true,
      remainingFreeUses: 0,
      message: upgradeMessage,
    );
  }
}
