import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:monetization/src/ads/ad_service.dart';

class GoogleMobileAdsService implements AdService {
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    await MobileAds.instance.initialize();
    _isInitialized = true;
  }

  @override
  BannerAd createBannerAd({
    required String adUnitId,
    required AdSize size,
    required BannerAdListener listener,
  }) {
    return BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: size,
      listener: listener,
    );
  }

  @override
  Future<void> showInterstitial({
    required String adUnitId,
    FullScreenContentCallback<InterstitialAd>? fullScreenContentCallback,
  }) async {
    await initialize();

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          ad.fullScreenContentCallback =
              fullScreenContentCallback ??
              FullScreenContentCallback<InterstitialAd>(
                onAdDismissedFullScreenContent: (InterstitialAd ad) {
                  ad.dispose();
                },
                onAdFailedToShowFullScreenContent: (
                  InterstitialAd ad,
                  AdError error,
                ) {
                  ad.dispose();
                },
              );
          ad.show();
        },
        onAdFailedToLoad: (_) {},
      ),
    );
  }
}
