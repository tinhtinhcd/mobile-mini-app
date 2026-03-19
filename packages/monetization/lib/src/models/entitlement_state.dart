enum EntitlementSource { free, cachedPurchase, storePurchase, restoredPurchase }

class EntitlementState {
  const EntitlementState({
    required this.isPremium,
    required this.storeAvailable,
    required this.isProcessing,
    required this.ownedProductIds,
    required this.source,
    this.message,
  });

  const EntitlementState.free({
    this.storeAvailable = true,
    this.isProcessing = false,
    this.message,
  }) : isPremium = false,
       ownedProductIds = const <String>{},
       source = EntitlementSource.free;

  final bool isPremium;
  final bool storeAvailable;
  final bool isProcessing;
  final Set<String> ownedProductIds;
  final EntitlementSource source;
  final String? message;

  bool get adsEnabled => !isPremium;

  EntitlementState copyWith({
    bool? isPremium,
    bool? storeAvailable,
    bool? isProcessing,
    Set<String>? ownedProductIds,
    EntitlementSource? source,
    String? message,
    bool clearMessage = false,
  }) {
    return EntitlementState(
      isPremium: isPremium ?? this.isPremium,
      storeAvailable: storeAvailable ?? this.storeAvailable,
      isProcessing: isProcessing ?? this.isProcessing,
      ownedProductIds: ownedProductIds ?? this.ownedProductIds,
      source: source ?? this.source,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}
