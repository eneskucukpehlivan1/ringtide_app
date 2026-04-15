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

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _loaded = true),
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _bannerAd == null) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      ),
    );
  }
}
