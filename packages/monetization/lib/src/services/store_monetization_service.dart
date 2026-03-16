import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:monetization/src/models/entitlement_state.dart';
import 'package:monetization/src/models/subscription_product.dart';
import 'package:monetization/src/services/monetization_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreMonetizationService extends MonetizationService {
  StoreMonetizationService({
    required List<String> productIds,
    required this.entitlementCacheKey,
    InAppPurchase? inAppPurchase,
  }) : _productIds = List<String>.unmodifiable(productIds),
       _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  final List<String> _productIds;
  final String entitlementCacheKey;
  final InAppPurchase _inAppPurchase;

  final Map<String, ProductDetails> _productDetailsById =
      <String, ProductDetails>{};

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  SharedPreferences? _preferences;
  EntitlementState _entitlementState = const EntitlementState.free();
  bool _isInitialized = false;

  @override
  EntitlementState get entitlementState => _entitlementState;

  @override
  List<SubscriptionProduct> get products {
    return _productIds
        .map(productForId)
        .whereType<SubscriptionProduct>()
        .toList(growable: false);
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _preferences = await SharedPreferences.getInstance();
    final List<String> cachedProducts =
        _preferences?.getStringList(entitlementCacheKey) ?? const <String>[];
    if (cachedProducts.isNotEmpty) {
      _entitlementState = EntitlementState(
        isPremium: true,
        storeAvailable: true,
        isProcessing: false,
        ownedProductIds: cachedProducts.toSet(),
        source: EntitlementSource.cachedPurchase,
      );
    }

    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object error) {
        _entitlementState = _entitlementState.copyWith(
          isProcessing: false,
          message: error.toString(),
        );
        notifyListeners();
      },
    );

    final bool storeAvailable = await _inAppPurchase.isAvailable();
    _entitlementState = _entitlementState.copyWith(
      storeAvailable: storeAvailable,
    );

    if (storeAvailable) {
      await refreshProducts();
    } else {
      notifyListeners();
    }

    _isInitialized = true;
  }

  @override
  Future<void> refreshProducts() async {
    final bool storeAvailable = await _inAppPurchase.isAvailable();
    _entitlementState = _entitlementState.copyWith(
      storeAvailable: storeAvailable,
      clearMessage: true,
    );

    if (!storeAvailable) {
      notifyListeners();
      return;
    }

    final ProductDetailsResponse response = await _inAppPurchase
        .queryProductDetails(_productIds.toSet());

    _productDetailsById
      ..clear()
      ..addEntries(
        response.productDetails.map(
          (ProductDetails details) => MapEntry(details.id, details),
        ),
      );

    final String? responseMessage = response.error?.message ??
        (response.notFoundIDs.isEmpty
            ? null
            : 'Missing store products: ${response.notFoundIDs.join(', ')}');

    _entitlementState = _entitlementState.copyWith(
      message: responseMessage,
    );
    notifyListeners();
  }

  @override
  Future<void> purchase(String productId) async {
    await initialize();

    if (!_entitlementState.storeAvailable) {
      _entitlementState = _entitlementState.copyWith(
        message: 'Store purchases are unavailable on this device.',
      );
      notifyListeners();
      return;
    }

    ProductDetails? details = _productDetailsById[productId];
    if (details == null) {
      await refreshProducts();
      details = _productDetailsById[productId];
    }

    if (details == null) {
      _entitlementState = _entitlementState.copyWith(
        message: 'This product is not available yet.',
      );
      notifyListeners();
      return;
    }

    _entitlementState = _entitlementState.copyWith(
      isProcessing: true,
      clearMessage: true,
    );
    notifyListeners();

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: details);
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Future<void> restorePurchases() async {
    await initialize();

    if (!_entitlementState.storeAvailable) {
      _entitlementState = _entitlementState.copyWith(
        message: 'Restore is unavailable on this device.',
      );
      notifyListeners();
      return;
    }

    _entitlementState = _entitlementState.copyWith(
      isProcessing: true,
      clearMessage: true,
    );
    notifyListeners();

    await _inAppPurchase.restorePurchases();

    _entitlementState = _entitlementState.copyWith(isProcessing: false);
    notifyListeners();
  }

  @override
  SubscriptionProduct? productForId(String productId) {
    final ProductDetails? details = _productDetailsById[productId];
    if (details == null) {
      return null;
    }

    return SubscriptionProduct(
      id: details.id,
      title: details.title,
      description: details.description,
      priceLabel: details.price,
    );
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    Set<String> ownedProductIds = _entitlementState.ownedProductIds;
    EntitlementSource source = _entitlementState.source;
    String? message = _entitlementState.message;
    bool isProcessing = _entitlementState.isProcessing;

    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          isProcessing = true;
          message = 'Waiting for store confirmation...';
        case PurchaseStatus.error:
          isProcessing = false;
          message = purchaseDetails.error?.message ?? 'Purchase failed.';
        case PurchaseStatus.purchased:
          isProcessing = false;
          if (_productIds.contains(purchaseDetails.productID)) {
            ownedProductIds = <String>{
              ...ownedProductIds,
              purchaseDetails.productID,
            };
            source = EntitlementSource.storePurchase;
            message = 'Premium unlocked.';
            await _persistOwnedProductIds(ownedProductIds);
          }
        case PurchaseStatus.restored:
          isProcessing = false;
          if (_productIds.contains(purchaseDetails.productID)) {
            ownedProductIds = <String>{
              ...ownedProductIds,
              purchaseDetails.productID,
            };
            source = EntitlementSource.restoredPurchase;
            message = 'Purchases restored.';
            await _persistOwnedProductIds(ownedProductIds);
          }
        case PurchaseStatus.canceled:
          isProcessing = false;
          message = 'Purchase canceled.';
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }

    _entitlementState = _entitlementState.copyWith(
      isPremium: ownedProductIds.isNotEmpty,
      isProcessing: isProcessing,
      ownedProductIds: ownedProductIds,
      source: source,
      message: message,
    );
    notifyListeners();
  }

  Future<void> _persistOwnedProductIds(Set<String> ownedProductIds) async {
    await _preferences?.setStringList(
      entitlementCacheKey,
      ownedProductIds.toList(growable: false),
    );
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
