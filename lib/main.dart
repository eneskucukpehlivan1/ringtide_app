import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'services/progression_service.dart';
import 'services/audio_service.dart';
import 'services/ad_service.dart';
import 'game/ringtide_game.dart';
import 'overlays/main_menu.dart';
import 'overlays/game_hud.dart';
import 'overlays/game_over.dart';
import 'overlays/tutorial_hint.dart';
import 'overlays/theme_select.dart';
import 'overlays/stats_overlay.dart';
import 'overlays/persistent_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
  ));

  // Uygulama servislerini yükle
  await ProgressionService.instance.init();
  await AudioService.init();

  runApp(const RingtideApp());

  // UI render olduktan sonra reklam akışını başlat
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initAdsFlow();
  });
}

bool _adsFlowStarted = false;

/// Tüm reklam akışı: UMP consent → ATT (iOS) → MobileAds init → reklam yükle
Future<void> _initAdsFlow() async {
  if (_adsFlowStarted) return;
  _adsFlowStarted = true;

  debugPrint('[AdInit] Reklam akışı başlıyor…');

  // 1) UMP Consent
  await _requestUMPConsent();

  // 2) ATT (sadece iOS)
  if (Platform.isIOS) {
    await _requestATT();
  }

  // 3) MobileAds initialize
  debugPrint('[AdInit] MobileAds initialize ediliyor…');
  final status = await MobileAds.instance.initialize();
  debugPrint('[AdInit] MobileAds initialized ✓ – adapters: ${status.adapterStatuses.keys.join(', ')}');

  // 4) Consent durumunu logla
  final consentStatus = await ConsentInformation.instance.getConsentStatus();
  debugPrint('[AdInit] UMP Consent durumu: $consentStatus');

  // 5) SDK hazır — reklamları yükle
  AdService.instance.sdkReady.value = true;
  AdService.instance.load();
  debugPrint('[AdInit] Reklam akışı tamamlandı ✓');
}

/// UMP (GDPR) consent akışı — en fazla 15 sn bekler
Future<void> _requestUMPConsent() async {
  debugPrint('[AdInit] UMP consent başlatılıyor…');
  final completer = Completer<void>();

  ConsentInformation.instance.requestConsentInfoUpdate(
    ConsentRequestParameters(),
    () async {
      debugPrint('[AdInit] UMP info güncellendi – form kontrol ediliyor');
      try {
        await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
        debugPrint('[AdInit] UMP form tamamlandı ✓');
      } catch (e) {
        debugPrint('[AdInit] UMP form hatası: $e');
      }
      if (!completer.isCompleted) completer.complete();
    },
    (FormError error) {
      debugPrint('[AdInit] UMP Error: ${error.message}');
      if (!completer.isCompleted) completer.complete();
    },
  );

  await completer.future.timeout(
    const Duration(seconds: 15),
    onTimeout: () {
      debugPrint('[AdInit] UMP timeout (15s) – devam ediliyor');
    },
  );
}

/// ATT (iOS App Tracking Transparency)
Future<void> _requestATT() async {
  try {
    final currentStatus = await AppTrackingTransparency.trackingAuthorizationStatus;
    debugPrint('[AdInit] ATT mevcut durum: $currentStatus');

    if (currentStatus != TrackingStatus.notDetermined) {
      debugPrint('[AdInit] ATT zaten belirlenmiş: $currentStatus');
      return;
    }

    await _waitForAppActive();
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    debugPrint('[AdInit] ATT dialog gösterilecek…');
    final newStatus = await AppTrackingTransparency.requestTrackingAuthorization();
    debugPrint('[AdInit] ATT kullanıcı yanıtı: $newStatus');

    if (newStatus == TrackingStatus.notDetermined) {
      debugPrint('[AdInit] ATT suppress edildi – 2s sonra tekrar deneniyor…');
      await Future<void>.delayed(const Duration(seconds: 2));
      final retryStatus = await AppTrackingTransparency.requestTrackingAuthorization();
      debugPrint('[AdInit] ATT retry yanıtı: $retryStatus');
    }
  } catch (e) {
    debugPrint('[AdInit] ATT hatası: $e');
  }
}

/// Uygulama lifecycle'ı "resumed" olana kadar bekle (max 10 sn)
Future<void> _waitForAppActive() async {
  final binding = WidgetsBinding.instance;
  final state = binding.lifecycleState;
  
  if (state == AppLifecycleState.resumed || state == null) return;

  final completer = Completer<void>();
  late final AppLifecycleListener listener;

  listener = AppLifecycleListener(
    onResume: () {
      if (!completer.isCompleted) completer.complete();
      listener.dispose();
    },
  );

  await completer.future.timeout(
    const Duration(seconds: 10),
    onTimeout: () {
      listener.dispose();
    },
  );
}

class RingtideApp extends StatelessWidget {
  const RingtideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ringtide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: const ColorScheme.dark(),
      ),
      home: const _GameScreen(),
    );
  }
}

class _GameScreen extends StatefulWidget {
  const _GameScreen();

  @override
  State<_GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<_GameScreen> with WidgetsBindingObserver {
  late final RingtideGame _game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _game = RingtideGame();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SizedBox.expand(
            child: GameWidget<RingtideGame>(
              game: _game,
              overlayBuilderMap: {
                'MainMenu': (context, game) => MainMenuOverlay(game: game),
                'GameHUD': (context, game) => GameHUD(game: game),
                'GameOver': (context, game) => GameOverOverlay(game: game),
                'TutorialHint': (context, game) => TutorialHintOverlay(game: game),
                'ThemeSelect': (context, game) => ThemeSelectOverlay(game: game),
                'StatsOverlay': (context, game) => StatsOverlay(game: game),
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: PersistentBanner(adUnitId: AdService.instance.bannerId),
          ),
        ],
      ),
    );
  }
}
