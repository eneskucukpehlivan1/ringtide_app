import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class PersistentBanner extends StatefulWidget {
  final String adUnitId;
  const PersistentBanner({super.key, required this.adUnitId});

  @override
  State<PersistentBanner> createState() => _PersistentBannerState();
}

class _PersistentBannerState extends State<PersistentBanner> {
  BannerAd? _bannerAd;
  bool _loaded = false;
  bool _isLoading = false;
  int _retryAttempt = 0;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _loadAd();
    });
  }

  void _loadAd() {
    if (_bannerAd != null || _isLoading) return;
    _isLoading = true;

    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() {
              _loaded = true;
              _isLoading = false;
              _retryAttempt = 0;
            });
            _retryTimer?.cancel();
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _loaded = false;
              _isLoading = false;
            });
            _retryAttempt++;
            final delaySec = (_retryAttempt <= 5
                    ? (2 * (1 << (_retryAttempt - 1)))
                    : 30)
                .clamp(2, 30);
            _retryTimer?.cancel();
            _retryTimer = Timer(Duration(seconds: delaySec), () {
              if (mounted) _loadAd();
            });
          }
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _bannerAd == null) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
