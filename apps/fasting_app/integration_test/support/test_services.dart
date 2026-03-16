import 'package:analytics/analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:monetization/monetization.dart';
import 'package:notifications/notifications.dart';
import 'package:storage/storage.dart';
import 'package:timer_engine/timer_engine.dart';

class TestAnalyticsService implements AnalyticsService {
  final List<AnalyticsEvent> events = <AnalyticsEvent>[];
  bool initialized = false;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    events.add(event);
  }
}

class TestNotificationService extends NotificationService {
  TestNotificationService()
    : super(
        defaultChannel: const NotificationChannel(
          id: 'test',
          name: 'Test',
          description: 'Test notifications',
        ),
      );

  final List<int> scheduledIds = <int>[];
  final List<int> canceledIds = <int>[];
  bool initialized = false;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
    NotificationChannel? channel,
  }) async {
    scheduledIds.add(id);
  }

  @override
  Future<void> cancelNotification(int id) async {
    canceledIds.add(id);
  }
}

class InMemoryTimerSnapshotStore implements TimerSnapshotStore {
  InMemoryTimerSnapshotStore({this.snapshot});

  TimerSnapshot? snapshot;
  int writeCount = 0;
  int clearCount = 0;

  @override
  Future<TimerSnapshot?> readSnapshot() async => snapshot;

  @override
  Future<void> writeSnapshot(TimerSnapshot snapshot) async {
    this.snapshot = snapshot;
    writeCount += 1;
  }

  @override
  Future<void> clearSnapshot() async {
    snapshot = null;
    clearCount += 1;
  }
}

class TestAdService implements AdService {
  bool initialized = false;

  @override
  bool get interstitialsEnabled => false;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  BannerAd createBannerAd({
    required String adUnitId,
    required AdSize size,
    required BannerAdListener listener,
  }) {
    throw UnsupportedError('Banner ads are disabled in integration tests.');
  }

  @override
  Future<void> showInterstitial({
    required String adUnitId,
    FullScreenContentCallback<InterstitialAd>? fullScreenContentCallback,
  }) async {}
}

class TestMonetizationService extends StoreMonetizationService {
  TestMonetizationService({
    this.initialEntitlement = const EntitlementState.free(),
    List<SubscriptionProduct>? products,
  }) : _products = List<SubscriptionProduct>.unmodifiable(
         products ??
             const <SubscriptionProduct>[
               SubscriptionProduct(
                 id: 'fasting_premium_monthly',
                 title: 'Monthly',
                 description: 'Monthly premium',
                 priceLabel: '\$0.99',
               ),
               SubscriptionProduct(
                 id: 'fasting_premium_yearly',
                 title: 'Yearly',
                 description: 'Yearly premium',
                 priceLabel: '\$9.99',
               ),
             ],
       ),
       super(
         productIds: (products ??
                 const <SubscriptionProduct>[
                   SubscriptionProduct(
                     id: 'fasting_premium_monthly',
                     title: 'Monthly',
                     description: 'Monthly premium',
                     priceLabel: '\$0.99',
                   ),
                   SubscriptionProduct(
                     id: 'fasting_premium_yearly',
                     title: 'Yearly',
                     description: 'Yearly premium',
                     priceLabel: '\$9.99',
                   ),
                 ])
             .map((SubscriptionProduct product) => product.id)
             .toList(growable: false),
         entitlementCacheKey: 'fasting_test_entitlements',
       ) {
    _entitlement = initialEntitlement;
  }

  final EntitlementState initialEntitlement;
  final List<SubscriptionProduct> _products;
  late EntitlementState _entitlement;
  bool initialized = false;

  @override
  EntitlementState get entitlementState => _entitlement;

  @override
  List<SubscriptionProduct> get products => _products;

  @override
  Future<void> initialize() async {
    initialized = true;
    notifyListeners();
  }

  @override
  Future<void> refreshProducts() async {}

  @override
  Future<void> purchase(String productId) async {
    _entitlement = EntitlementState(
      isPremium: true,
      storeAvailable: true,
      isProcessing: false,
      ownedProductIds: <String>{productId},
      source: EntitlementSource.storePurchase,
      message: 'Premium unlocked.',
    );
    notifyListeners();
  }

  @override
  Future<void> restorePurchases() async {
    _entitlement = EntitlementState(
      isPremium: true,
      storeAvailable: true,
      isProcessing: false,
      ownedProductIds: _products.map((SubscriptionProduct p) => p.id).toSet(),
      source: EntitlementSource.restoredPurchase,
      message: 'Purchases restored.',
    );
    notifyListeners();
  }

  @override
  SubscriptionProduct? productForId(String productId) {
    for (final SubscriptionProduct product in _products) {
      if (product.id == productId) {
        return product;
      }
    }
    return null;
  }
}

Future<void> pumpUntilVisible(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 8),
  Duration step = const Duration(milliseconds: 100),
}) async {
  final DateTime end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  throw TestFailure('Timed out waiting for $finder');
}
