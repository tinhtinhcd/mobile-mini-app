import 'dart:async';

import 'package:app_core/app_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:monetization/src/ads/ad_service.dart';
import 'package:monetization/src/models/entitlement.dart';
import 'package:monetization/src/services/entitlement_service.dart';

class MonetizationBanner extends StatefulWidget {
  const MonetizationBanner({
    super.key,
    required this.adService,
    required this.entitlementService,
    required this.adUnitId,
    this.startupAppId,
  });

  final AdService adService;
  final EntitlementService entitlementService;
  final String adUnitId;
  final String? startupAppId;

  @override
  State<MonetizationBanner> createState() => _MonetizationBannerState();
}

class _MonetizationBannerState extends State<MonetizationBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _loadScheduled = false;
  Timer? _deferredLoadTimer;

  @override
  void initState() {
    super.initState();
    _scheduleLoadAdIfNeeded();
  }

  @override
  void didUpdateWidget(MonetizationBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool hidesAds = widget.entitlementService.has(Entitlement.noAds);
    final bool oldHidesAds = oldWidget.entitlementService.has(
      Entitlement.noAds,
    );
    if (hidesAds && !oldHidesAds) {
      _disposeBanner();
      return;
    }

    if (!hidesAds && (oldHidesAds || oldWidget.adUnitId != widget.adUnitId)) {
      _disposeBanner();
      _scheduleLoadAdIfNeeded();
    }
  }

  void _scheduleLoadAdIfNeeded() {
    if (_loadScheduled) {
      return;
    }

    _loadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScheduled = false;
      if (!mounted) {
        return;
      }
      _deferredLoadTimer?.cancel();
      _deferredLoadTimer = Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) {
          return;
        }
        unawaited(_loadAdIfNeeded());
      });
    });
  }

  Future<void> _loadAdIfNeeded() async {
    if (widget.entitlementService.has(Entitlement.noAds) ||
        widget.adUnitId.isEmpty ||
        _bannerAd != null) {
      return;
    }

    try {
      await widget.adService.initialize();

      final BannerAd ad = widget.adService.createBannerAd(
        adUnitId: widget.adUnitId,
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            if (!mounted) {
              ad.dispose();
              return;
            }

            setState(() {
              _bannerAd = ad as BannerAd;
              _isLoaded = true;
            });
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            ad.dispose();
            if (kDebugMode) {
              debugPrint(
                'Banner ad failed to load for ${widget.startupAppId ?? 'app'}: '
                '${error.code} ${error.message}',
              );
            }
            if (!mounted) {
              return;
            }
            setState(() {
              _bannerAd = null;
              _isLoaded = false;
            });
          },
        ),
      );

      ad.load();
      _bannerAd = ad;
    } catch (_) {
      _disposeBanner();
    }
  }

  void _disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isLoaded = false;
  }

  @override
  void dispose() {
    _deferredLoadTimer?.cancel();
    _disposeBanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (widget.entitlementService.has(Entitlement.noAds) ||
        !_isLoaded ||
        _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.xs,
            AppSpacing.sm,
            AppSpacing.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Sponsored',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
