import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  static const _interstitialAndroid = 'ca-app-pub-4848727887390601/7425715010';
  static const _interstitialIOS     = 'ca-app-pub-4848727887390601/7425715010';
  static const _rewardedAndroid     = 'ca-app-pub-4848727887390601/5320192789';
  static const _rewardedIOS         = 'ca-app-pub-4848727887390601/5320192789';
  static const _bannerAndroid       = 'ca-app-pub-3940256099942544/6300978111'; // TODO: replace with Android ID
  static const _bannerIOS           = 'ca-app-pub-4848727887390601/3800150992';

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  BannerAd? _bannerAd;
  bool _bannerReady = false;

  String get _interstitialId => Platform.isIOS ? _interstitialIOS : _interstitialAndroid;
  String get _rewardedId => Platform.isIOS ? _rewardedIOS : _rewardedAndroid;
  String get _bannerId => Platform.isIOS ? _bannerIOS : _bannerAndroid;
  String get bannerId  => _bannerId;

  BannerAd? get bannerAd => _bannerReady ? _bannerAd : null;

  void load() {
    _loadInterstitial();
    _loadRewarded();
    _loadBanner();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  void _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: _bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => _bannerReady = true,
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed: $error');
          ad.dispose();
          _bannerAd = null;
          _bannerReady = false;
        },
      ),
    )..load();
  }

  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: _rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (_) => _rewardedAd = null,
      ),
    );
  }

  Future<void> showInterstitial() async {
    final ad = _interstitialAd;
    if (ad == null) return;
    _interstitialAd = null;
    final c = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _loadInterstitial();
        if (!c.isCompleted) c.complete();
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        _loadInterstitial();
        if (!c.isCompleted) c.complete();
      },
    );
    await ad.show();
    await c.future;
  }

  Future<void> showRewarded({required VoidCallback onRewarded}) async {
    final ad = _rewardedAd;
    if (ad == null) {
      onRewarded();
      return;
    }
    _rewardedAd = null;
    final c = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        _loadRewarded();
        if (!c.isCompleted) c.complete();
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        _loadRewarded();
        onRewarded();
        if (!c.isCompleted) c.complete();
      },
    );
    await ad.show(onUserEarnedReward: (ad, reward) => onRewarded());
    await c.future;
  }
}
