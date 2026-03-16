import 'package:flutter/foundation.dart';
import 'package:monetization/src/models/entitlement_state.dart';
import 'package:monetization/src/models/subscription_product.dart';

abstract class MonetizationService extends ChangeNotifier {
  EntitlementState get entitlementState;

  List<SubscriptionProduct> get products;

  bool get isPremium => entitlementState.isPremium;

  Future<void> initialize();

  Future<void> refreshProducts();

  Future<void> purchase(String productId);

  Future<void> restorePurchases();

  SubscriptionProduct? productForId(String productId);
}
