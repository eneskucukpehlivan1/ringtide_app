import 'dart:math';
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
      outerRadius: _baseRadius(),
    );
    await add(_aimLane);

    _createRing();
    overlays.add('MainMenu');
  }

  // ── Ring management ────────────────────────────────────────────────────────

  double _baseRadius() => size.x * GameConstants.ringRadiusRatio;

  /// Creates the ring for the first time (call once from onLoad / reset).
  void _createRing() {
    for (final r in _rings) { r.removeFromParent(); }
    _rings.clear();

    final ring = RingComponent(
      center: size / 2,
      radius: _baseRadius(),
      gapSize: GameConstants.gapSizeForLevel(level),
      gapCount: GameConstants.gapCountForLevel(level),
      speed: _ringSpeed(),
      color: activeTheme.ringColor,
    );
    _rings.add(ring);
    add(ring);
    _aimLane.updateRadius(_baseRadius());
  }

  /// Updates ring difficulty in-place — rotation keeps going uninterrupted.
  void _updateRing() {
    if (_rings.isEmpty) return;
    _rings.first.configure(
      newGapSize:  GameConstants.gapSizeForLevel(level),
      newGapCount: GameConstants.gapCountForLevel(level),
      newSpeed:    _ringSpeed(),
    );
  }

  double _ringSpeed() {
    final dirFlip =
        (level ~/ GameConstants.levelsPerDirectionFlip) % 2 == 0 ? 1.0 : -1.0;
    return GameConstants.speedForLevel(level) * dirFlip;
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
        _launchBall(event.canvasPosition);
        return;
      default:
        return;
    }
  }

  void _launchBall(Vector2 tapPos) {
    if (_ballsInFlight >= GameConstants.maxBallsInFlight) return;
    if (_rings.isEmpty) return;

    _ballsInFlight++;

    final center = size / 2;
    final angle = atan2(tapPos.y - center.y, tapPos.x - center.x);
    final radii = _rings.map((r) => r.radius).toList();
    final checks = _rings
        .map((r) => (double a) => r.isBallAligned(a))
        .toList();

    final ball = BallComponent(
      origin: center,
      launchAngle: angle,
      ringRadii: radii,
      gapChecks: checks,
      onResult: (miss, hitRadius) => _onBallResult(miss, hitRadius, angle),
      color: activeTheme.accentColor,
    );
    add(ball);
  }

  void _onBallResult(bool miss, double hitRadius, double ballAngle) {
    _ballsInFlight--;

    if (miss) {
      _onMiss();
      return;
    }

    final allPerfect = _rings.every((r) => r.isBallPerfect(ballAngle));
    tapsCount++;
    combo++;
    if (combo > maxCombo) maxCombo = combo;

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
      _updateRing();
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
        position: Vector2(center.x, center.y - _baseRadius() - 50),
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
    _createRing();
    AudioService.startBgm();

    if (ProgressionService.instance.tutorialSeen) {
      // Skip straight to game
      phase = GamePhase.playing;
      overlays.add('GameHUD');
    } else {
      phase = GamePhase.tutorial;
      overlays.add('TutorialHint');
    }
  }

  void startGame() {
    overlays.remove('TutorialHint');
    ProgressionService.instance.markTutorialSeen();
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
    _createRing();
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
    _createRing();
    overlays.add('MainMenu');
  }

  bool get canContinue => _canContinue && !_usedContinue;
}
