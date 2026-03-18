import 'dart:async';

import 'package:app_core/app_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:monetization/src/ads/ad_service.dart';
import 'package:monetization/src/models/entitlement_state.dart';

class MonetizationBanner extends StatefulWidget {
  const MonetizationBanner({
    super.key,
    required this.adService,
    required this.entitlementState,
    required this.adUnitId,
    this.startupAppId,
  });

  final AdService adService;
  final EntitlementState entitlementState;
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
    if (kDebugMode) {
      return;
    }
    _scheduleLoadAdIfNeeded();
  }

  @override
  void didUpdateWidget(MonetizationBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (kDebugMode) {
      return;
    }
    if (widget.entitlementState.isPremium &&
        !oldWidget.entitlementState.isPremium) {
      _disposeBanner();
      return;
    }

    if (!widget.entitlementState.isPremium &&
        (oldWidget.entitlementState.isPremium ||
            oldWidget.adUnitId != widget.adUnitId)) {
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
    if (widget.entitlementState.isPremium ||
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

    if (kDebugMode) {
      return const SizedBox.shrink();
    }

    if (widget.entitlementState.isPremium || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Sponsored',
                  style: theme.textTheme.bodySmall?.copyWith(
                    letterSpacing: 0.7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
