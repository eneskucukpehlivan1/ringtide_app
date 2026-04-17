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
  static const _bannerAndroid       = 'ca-app-pub-4848727887390601/3800150992';
  static const _bannerIOS           = 'ca-app-pub-4848727887390601/3800150992';

  InterstitialAd? _interstitialAd;
  RewardedAd?     _rewardedAd;
  int _interstitialRetry = 0;
  int _rewardedRetry = 0;

  final ValueNotifier<bool> rewardedReady = ValueNotifier(false);

  String get _interstitialId => Platform.isIOS ? _interstitialIOS : _interstitialAndroid;
  String get _rewardedId     => Platform.isIOS ? _rewardedIOS     : _rewardedAndroid;
  String get _bannerId       => Platform.isIOS ? _bannerIOS       : _bannerAndroid;
  String get bannerId        => _bannerId;

  bool get isInterstitialReady => _interstitialAd != null;
  bool get isRewardedReady     => _rewardedAd != null;

  void load() {
    _loadInterstitial();
    _loadRewarded();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialRetry = 0;
        },
        onAdFailedToLoad: (err) {
          _interstitialAd = null;
          _interstitialRetry++;
          final delay = Duration(seconds: (_interstitialRetry * 15).clamp(15, 120));
          Future.delayed(delay, _loadInterstitial);
        },
      ),
    );
  }

  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: _rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedRetry = 0;
          rewardedReady.value = true;
        },
        onAdFailedToLoad: (err) {
          _rewardedAd = null;
          rewardedReady.value = false;
          _rewardedRetry++;
          final delay = Duration(seconds: (_rewardedRetry * 15).clamp(15, 120));
          Future.delayed(delay, _loadRewarded);
        },
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
    if (ad == null) return;

    _rewardedAd = null;
    rewardedReady.value = false;
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
        if (!c.isCompleted) c.complete();
      },
    );
    await ad.show(onUserEarnedReward: (_, __) => onRewarded());
    await c.future;
  }
}
