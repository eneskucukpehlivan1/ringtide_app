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

  late CenterOrb _orb;
  late TapMarker _marker;
  final List<RingComponent> _rings = [];

  GameTheme get activeTheme => ProgressionService.instance.activeTheme;

  @override
  Color backgroundColor() => activeTheme.bgDark;

  @override
  Future<void> onLoad() async {
    await add(BackgroundComponent());

    _orb = CenterOrb(center: size / 2, color: activeTheme.accentColor);
    await add(_orb);

    _marker = TapMarker(
      position: _markerPosition(1),
      color: activeTheme.accentColor,
    );
    await add(_marker);

    _buildRings();
    overlays.add('MainMenu');
  }

  // ── Ring management ────────────────────────────────────────────────────────

  int _ringCount() {
    if (level >= 25) return 3;
    if (level >= 12) return 2;
    return 1;
  }

  Vector2 _markerPosition(int numRings) {
    final center = size / 2;
    final baseRadius = size.x * GameConstants.ringRadiusRatio;
    final outerRadius = baseRadius + (numRings - 1) * 28.0;
    return Vector2(
      center.x + cos(GameConstants.markerAngle) * (outerRadius + GameConstants.markerOffset),
      center.y + sin(GameConstants.markerAngle) * (outerRadius + GameConstants.markerOffset),
    );
  }

  void _buildRings() {
    for (final r in _rings) { r.removeFromParent(); }
    _rings.clear();

    final center = size / 2;
    final baseRadius = size.x * GameConstants.ringRadiusRatio;
    final numRings = _ringCount();
    final gap = (GameConstants.initialGapSize -
            (level ~/ 10) * GameConstants.gapDecrement)
        .clamp(GameConstants.minGapSize, GameConstants.initialGapSize);
    final baseSpeed = (GameConstants.initialSpeed +
            (level ~/ GameConstants.levelsPerSpeedIncrease) *
                GameConstants.speedIncrement)
        .clamp(GameConstants.initialSpeed, GameConstants.maxSpeed);
    final dirFlip =
        (level ~/ GameConstants.levelsPerDirectionFlip) % 2 == 0 ? 1.0 : -1.0;

    for (int i = 0; i < numRings; i++) {
      final radius = baseRadius + i * 28.0;
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

    _marker.position = _markerPosition(numRings);
  }

  // ── Update ─────────────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);
    if (phase != GamePhase.playing) return;

    if (_rings.isNotEmpty) {
      final prox = _rings.map((r) => r.proximityToMarker).reduce(max);
      _marker.proximity = prox;
    }
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
        _handleTap();
        return;
      default:
        return;
    }
  }

  void _handleTap() {
    if (_rings.isEmpty) return;

    bool anyMiss = false;
    bool allPerfect = true;

    for (final ring in _rings) {
      final result = ring.tryTap();
      if (result == TapResult.miss) {
        anyMiss = true;
        allPerfect = false;
        break;
      }
      if (result != TapResult.perfect) allPerfect = false;
    }

    if (anyMiss) {
      _onMiss();
      return;
    }

    for (final ring in _rings) { ring.flash(); }

    tapsCount++;
    combo++;
    if (combo > maxCombo) maxCombo = combo;

    int gained;
    if (allPerfect) {
      gained = GameConstants.perfectBase + combo * 2;
      AudioService.playPerfect();
      _spawnFeedback(perfect: true);
    } else {
      gained = GameConstants.baseScore + (combo > 1 ? combo : 0);
      AudioService.playTap();
      _spawnFeedback(perfect: false);
    }
    score += gained;

    if (combo >= 5 && combo % 5 == 0) AudioService.playCombo();

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
      final baseRadius = size.x * GameConstants.ringRadiusRatio;
      add(PerfectLabel(
        position: Vector2(center.x, center.y - baseRadius - 45),
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
