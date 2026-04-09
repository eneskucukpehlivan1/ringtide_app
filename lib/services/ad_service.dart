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

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  String get _interstitialId => Platform.isIOS ? _interstitialIOS : _interstitialAndroid;
  String get _rewardedId => Platform.isIOS ? _rewardedIOS : _rewardedAndroid;

  void load() {
    _loadInterstitial();
    _loadRewarded();
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
