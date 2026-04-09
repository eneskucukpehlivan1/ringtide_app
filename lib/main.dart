import 'dart:async';
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

  // 1. GDPR / UMP consent
  final consentCompleter = Completer<void>();
  ConsentInformation.instance.requestConsentInfoUpdate(
    ConsentRequestParameters(),
    () async {
      // On success — show form if required
      final formAvailable =
          await ConsentInformation.instance.isConsentFormAvailable();
      if (formAvailable) {
        final formCompleter = Completer<void>();
        await ConsentForm.loadAndShowConsentFormIfRequired((_) {
          if (!formCompleter.isCompleted) formCompleter.complete();
        });
        await formCompleter.future;
      }
      if (!consentCompleter.isCompleted) consentCompleter.complete();
    },
    (FormError error) {
      if (!consentCompleter.isCompleted) consentCompleter.complete();
    },
  );
  await consentCompleter.future;

  // 2. ATT (iOS) — only if GDPR did not deny
  final consentStatus = await ConsentInformation.instance.getConsentStatus();
  if (consentStatus != ConsentStatus.required) {
    final trackingStatus =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    if (trackingStatus == TrackingStatus.notDetermined) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }

  // 3. AdMob
  await MobileAds.instance.initialize();

  // 4. App services
  await ProgressionService.instance.init();
  await AudioService.init();
  AdService.instance.load();

  runApp(const RingtideApp());
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

class _GameScreenState extends State<_GameScreen> {
  late final RingtideGame _game;

  @override
  void initState() {
    super.initState();
    _game = RingtideGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
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
    );
  }
}
