import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract class AdService {
  Future<void> initialize();

  BannerAd createBannerAd({
    required String adUnitId,
    required AdSize size,
    required BannerAdListener listener,
  });

  Future<void> showInterstitial({
    required String adUnitId,
    FullScreenContentCallback<InterstitialAd>? fullScreenContentCallback,
  });
}
