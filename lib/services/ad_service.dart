import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  // Test IDs
  static const _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const _testInterstitialIOS     = 'ca-app-pub-3940256099942544/4411468910';
  static const _testRewardedAndroid     = 'ca-app-pub-3940256099942544/5224354917';
  static const _testRewardedIOS         = 'ca-app-pub-3940256099942544/1712485313';
  static const _testBannerAndroid       = 'ca-app-pub-3940256099942544/6300978111';
  static const _testBannerIOS           = 'ca-app-pub-3940256099942544/2934735716';

  // Production IDs
  static const _prodInterstitialIOS = 'ca-app-pub-4848727887390601/7425715010';
  static const _prodRewardedIOS     = 'ca-app-pub-4848727887390601/5320192789';
  static const _prodBannerIOS       = 'ca-app-pub-4848727887390601/3800150992';

  String get _interstitialId {
    if (kDebugMode) return Platform.isIOS ? _testInterstitialIOS : _testInterstitialAndroid;
    return Platform.isIOS ? _prodInterstitialIOS : _testInterstitialAndroid;
  }

  String get _rewardedId {
    if (kDebugMode) return Platform.isIOS ? _testRewardedIOS : _testRewardedAndroid;
    return Platform.isIOS ? _prodRewardedIOS : _testRewardedAndroid;
  }

  String get _bannerId {
    if (kDebugMode) return Platform.isIOS ? _testBannerIOS : _testBannerAndroid;
    return Platform.isIOS ? _prodBannerIOS : _testBannerAndroid;
  }

  String get bannerId => _bannerId;

  InterstitialAd? _interstitialAd;
  RewardedAd?     _rewardedAd;
  int _interstitialRetry = 0;
  int _rewardedRetry = 0;

  final ValueNotifier<bool> rewardedReady = ValueNotifier(false);
  final ValueNotifier<bool> sdkReady = ValueNotifier(false);

  bool get isInterstitialReady => _interstitialAd != null;
  bool get isRewardedReady => _rewardedAd != null;

  void load() {
    debugPrint('[AdInit] load() çağrıldı – interstitial + rewarded yükleniyor');
    _loadInterstitial();
    _loadRewarded();
  }

  void _loadInterstitial() {
    final id = _interstitialId;
    debugPrint('[AdInit] Interstitial yükleniyor: $id');
    InterstitialAd.load(
      adUnitId: id,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdInit] Interstitial yüklendi ✓');
          _interstitialAd = ad;
          _interstitialRetry = 0;
        },
        onAdFailedToLoad: (err) {
          debugPrint('[AdInit] Interstitial yüklenemedi – code:${err.code} msg:${err.message} domain:${err.domain}');
          _interstitialAd = null;
          _interstitialRetry++;
          final delay = Duration(seconds: (_interstitialRetry * 15).clamp(15, 120));
          Future.delayed(delay, _loadInterstitial);
        },
      ),
    );
  }

  void _loadRewarded() {
    final id = _rewardedId;
    debugPrint('[AdInit] Rewarded yükleniyor: $id');
    RewardedAd.load(
      adUnitId: id,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdInit] Rewarded yüklendi ✓');
          _rewardedAd = ad;
          _rewardedRetry = 0;
          rewardedReady.value = true;
        },
        onAdFailedToLoad: (err) {
          debugPrint('[AdInit] Rewarded yüklenemedi – code:${err.code} msg:${err.message} domain:${err.domain}');
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
    if (_interstitialAd == null) return;

    final completer = Completer<void>();
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        completer.complete();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        debugPrint('[AdInit] Interstitial gösterilemedi: ${err.message}');
        ad.dispose();
        _interstitialAd = null;
        completer.complete();
        _loadInterstitial();
      },
    );

    await _interstitialAd!.show();
    return completer.future;
  }

  Future<void> showRewarded({required VoidCallback onRewarded}) async {
    if (_rewardedAd == null) return;

    final completer = Completer<void>();
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        rewardedReady.value = false;
        completer.complete();
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        debugPrint('[AdInit] Rewarded gösterilemedi: ${err.message}');
        ad.dispose();
        _rewardedAd = null;
        rewardedReady.value = false;
        completer.complete();
        _loadRewarded();
      },
    );

    await _rewardedAd!.show(onUserEarnedReward: (_, __) => onRewarded());
    return completer.future;
  }
}
