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
  AdSize? _adSize;
  bool _loaded = false;
  int _retryCount = 0;
  Timer? _retryTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_adSize == null) {
      _initAdSize();
    }
  }

  Future<void> _initAdSize() async {
    final width = MediaQuery.of(context).size.width.truncate();
    final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (!mounted) return;
    _adSize = size ?? AdSize.banner;
    _loadAd();
  }

  void _loadAd() {
    final size = _adSize;
    if (size == null) return;

    _bannerAd?.dispose();
    _bannerAd = null;

    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() {
              _loaded = true;
              _retryCount = 0;
            });
            _retryTimer?.cancel();
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          if (mounted) {
            setState(() => _loaded = false);
            _scheduleRetry();
          }
        },
      ),
    )..load();
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryCount++;
    final delay = (_retryCount * 15).clamp(15, 120);
    _retryTimer = Timer(Duration(seconds: delay), () {
      if (mounted && !_loaded) _loadAd();
    });
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
        height: _bannerAd!.size.height.toDouble(),
        width: double.infinity,
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
