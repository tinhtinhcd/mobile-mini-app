import 'package:flutter/foundation.dart';
import 'package:monetization/src/models/paywall_content.dart';
import 'package:monetization/src/models/subscription_product.dart';
import 'package:monetization/src/services/monetization_service.dart';

class PaywallController extends ChangeNotifier {
  PaywallController({
    required this.service,
    required this.content,
  }) {
    service.addListener(_onServiceChanged);
  }

  final MonetizationService service;
  final PaywallContent content;

  String? _errorMessage;

  bool get isPremium => service.entitlementState.isPremium;

  bool get isBusy => service.entitlementState.isProcessing;

  String? get message => _errorMessage ?? service.entitlementState.message;

  SubscriptionProduct? get monthlyProduct =>
      service.productForId(content.monthlyProductId);

  SubscriptionProduct? get yearlyProduct =>
      service.productForId(content.yearlyProductId);

  Future<void> initialize() async {
    await service.initialize();
    await service.refreshProducts();
  }

  Future<void> purchaseMonthly() {
    return _purchase(content.monthlyProductId);
  }

  Future<void> purchaseYearly() {
    return _purchase(content.yearlyProductId);
  }

  Future<void> restorePurchases() async {
    _errorMessage = null;
    notifyListeners();
    await service.restorePurchases();
  }

  Future<void> _purchase(String productId) async {
    _errorMessage = null;
    notifyListeners();
    await service.purchase(productId);
  }

  void _onServiceChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    service.removeListener(_onServiceChanged);
    super.dispose();
  }
}
