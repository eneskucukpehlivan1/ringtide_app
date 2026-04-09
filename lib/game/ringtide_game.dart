import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../models/game_theme.dart';
import '../services/audio_service.dart';
import '../services/ad_service.dart';
import '../services/progression_service.dart';
import '../utils/constants.dart';
import 'components/background_component.dart';
import 'components/ring_component.dart';
import 'components/center_orb.dart';
import 'components/tap_marker.dart';
import 'components/ball_component.dart';
import 'components/particle_burst.dart';
import 'components/perfect_label.dart';

enum GamePhase { menu, tutorial, playing, dead }

class RingtideGame extends FlameGame with TapCallbacks {
  GamePhase phase = GamePhase.menu;

  int score = 0;
  int level = 1;
  int combo = 0;
  int maxCombo = 0;
  int tapsCount = 0;

  int _gamesSinceAd = 0;
  bool _canContinue = true;
  bool _usedContinue = false;
  int _ballsInFlight = 0;

  late CenterOrb _orb;
  late TapMarker _aimLane;
  final List<RingComponent> _rings = [];

  GameTheme get activeTheme => ProgressionService.instance.activeTheme;

  @override
  Color backgroundColor() => activeTheme.bgDark;

  @override
  Future<void> onLoad() async {
    await add(BackgroundComponent());

    _orb = CenterOrb(center: size / 2, color: activeTheme.accentColor);
    await add(_orb);

    _aimLane = TapMarker(
      center: size / 2,
      color: activeTheme.accentColor,
      outerRadius: _outerRadius(1),
    );
    await add(_aimLane);

    _buildRings();
    overlays.add('MainMenu');
  }

  // ── Ring management ────────────────────────────────────────────────────────

  int _ringCount() {
    if (level >= 25) return 3;
    if (level >= 12) return 2;
    return 1;
  }

  double _baseRadius() => size.x * GameConstants.ringRadiusRatio;

  double _outerRadius(int numRings) =>
      _baseRadius() + (numRings - 1) * 28.0;

  void _buildRings() {
    for (final r in _rings) { r.removeFromParent(); }
    _rings.clear();

    final center = size / 2;
    final numRings = _ringCount();
    final gap = (GameConstants.initialGapSize -
            (level ~/ GameConstants.levelsPerGapDecrement) *
                GameConstants.gapDecrement)
        .clamp(GameConstants.minGapSize, GameConstants.initialGapSize);
    final baseSpeed = (GameConstants.initialSpeed +
            (level ~/ GameConstants.levelsPerSpeedIncrease) *
                GameConstants.speedIncrement)
        .clamp(GameConstants.initialSpeed, GameConstants.maxSpeed);
    final dirFlip =
        (level ~/ GameConstants.levelsPerDirectionFlip) % 2 == 0 ? 1.0 : -1.0;

    for (int i = 0; i < numRings; i++) {
      final radius = _baseRadius() + i * 28.0;
      // Alternate ring directions for multi-ring challenge
      final ringSpeed = baseSpeed *
          (i == 0 ? 1.0 : (i.isEven ? 0.85 : -0.9)) *
          dirFlip;
      final ring = RingComponent(
        center: center,
        radius: radius,
        gapSize: gap,
        speed: ringSpeed,
        color: activeTheme.ringColor,
      );
      _rings.add(ring);
      add(ring);
    }

    _aimLane.updateRadius(_outerRadius(numRings));
  }

  // ── Update ─────────────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);
    if (phase != GamePhase.playing) return;
    _orb.updateCombo(combo);
  }

  // ── Input ──────────────────────────────────────────────────────────────────

  @override
  void onTapDown(TapDownEvent event) {
    switch (phase) {
      case GamePhase.tutorial:
        startGame();
        return;
      case GamePhase.playing:
        _launchBall();
        return;
      default:
        return;
    }
  }

  void _launchBall() {
    if (_ballsInFlight >= GameConstants.maxBallsInFlight) return;
    if (_rings.isEmpty) return;

    _ballsInFlight++;

    // Capture gap alignment at the moment of launch for each ring
    // (ball travels, so we snapshot angles now and predict where they'll be)
    // For simplicity: check gap alignment when ball *arrives* at each ring radius
    // We pass live closures so the ring is checked at arrival time
    final radii = _rings.map((r) => r.radius).toList();
    final checks = _rings.map((r) => r.isBallAligned).toList();
    final perfChecks = _rings.map((r) => r.isBallPerfect).toList();

    final ball = BallComponent(
      origin: size / 2,
      ringRadii: radii,
      gapChecks: checks,
      onResult: (miss, hitRadius) => _onBallResult(miss, hitRadius, perfChecks),
      color: activeTheme.accentColor,
    );
    add(ball);
  }

  void _onBallResult(bool miss, double hitRadius, List<bool Function()> perfChecks) {
    _ballsInFlight--;

    if (miss) {
      _onMiss();
      return;
    }

    // Ball passed — check how many rings and if all were perfect
    final allPerfect = perfChecks.every((f) => f());
    tapsCount++;
    combo++;
    if (combo > maxCombo) maxCombo = combo;

    // Flash rings
    for (final ring in _rings) { ring.flash(); }

    int gained;
    if (allPerfect) {
      gained = GameConstants.perfectBase + combo * 2;
      AudioService.playPerfect();
    } else {
      gained = GameConstants.baseScore + (combo > 1 ? combo : 0);
      AudioService.playTap();
    }
    score += gained;

    if (combo >= 5 && combo % 5 == 0) AudioService.playCombo();

    _spawnFeedback(perfect: allPerfect);

    // Level up
    final newLevel = (score ~/ 50) + 1;
    if (newLevel > level) {
      level = newLevel;
      _buildRings();
    }

    overlays.remove('GameHUD');
    overlays.add('GameHUD');
  }

  void _onMiss() {
    combo = 0;
    AudioService.playGameOver();
    phase = GamePhase.dead;
    _finishGame();
  }

  void _spawnFeedback({required bool perfect}) {
    final center = size / 2;
    add(ParticleBurst(center: center, color: activeTheme.ringColor, isPerfect: perfect));
    if (perfect || combo >= 2) {
      final label = combo >= 2 ? '🔥 x$combo' : 'PERFECT!';
      add(PerfectLabel(
        position: Vector2(center.x, center.y - _outerRadius(_ringCount()) - 50),
        text: label,
        color: activeTheme.accentColor,
      ));
    }
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  void _resetState() {
    score = 0;
    level = 1;
    combo = 0;
    maxCombo = 0;
    tapsCount = 0;
    _ballsInFlight = 0;
  }

  void startTutorial() {
    overlays.remove('MainMenu');
    _resetState();
    _canContinue = true;
    _usedContinue = false;
    _buildRings();
    AudioService.startBgm();
    phase = GamePhase.tutorial;
    overlays.add('TutorialHint');
  }

  void startGame() {
    overlays.remove('TutorialHint');
    phase = GamePhase.playing;
    overlays.add('GameHUD');
  }

  Future<void> _finishGame() async {
    overlays.remove('GameHUD');
    _gamesSinceAd++;
    if (_gamesSinceAd >= GameConstants.interstitialEvery) {
      _gamesSinceAd = 0;
      await AdService.instance.showInterstitial();
    }
    await ProgressionService.instance.addGameResult(
      score: score,
      level: level,
      maxCombo: maxCombo,
      tapsCount: tapsCount,
    );
    overlays.add('GameOver');
  }

  void restartGame() {
    overlays.remove('GameOver');
    _resetState();
    _canContinue = !_usedContinue;
    _buildRings();
    phase = GamePhase.playing;
    overlays.add('GameHUD');
  }

  void useContinue() {
    if (!_canContinue) return;
    _canContinue = false;
    _usedContinue = true;
    combo = 0;
    _ballsInFlight = 0;
    overlays.remove('GameOver');
    phase = GamePhase.playing;
    overlays.add('GameHUD');
  }

  void goToMenu() {
    for (final o in ['GameOver', 'GameHUD', 'TutorialHint', 'ThemeSelect', 'StatsOverlay']) {
      overlays.remove(o);
    }
    AudioService.stopBgm();
    _resetState();
    phase = GamePhase.menu;
    _buildRings();
    overlays.add('MainMenu');
  }

  bool get canContinue => _canContinue && !_usedContinue;
}
