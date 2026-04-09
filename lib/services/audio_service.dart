import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'progression_service.dart';

class AudioService {
  static bool _loaded = false;
  static bool get _sound => ProgressionService.instance.soundEnabled;
  static bool get _haptics => ProgressionService.instance.hapticsEnabled;

  static Future<void> init() async {
    if (_loaded) return;
    await FlameAudio.audioCache.loadAll([
      'tap.wav',
      'perfect.wav',
      'combo.wav',
      'gameover.wav',
      'bgm.wav',
    ]);
    _loaded = true;
  }

  static void startBgm() {
    if (!_sound) return;
    FlameAudio.bgm.play('bgm.wav', volume: 0.3);
  }

  static void stopBgm() => FlameAudio.bgm.stop();

  static void playTap() {
    if (_sound) FlameAudio.play('tap.wav', volume: 0.7);
    if (_haptics) HapticFeedback.lightImpact();
  }

  static void playPerfect() {
    if (_sound) FlameAudio.play('perfect.wav', volume: 0.85);
    if (_haptics) HapticFeedback.mediumImpact();
  }

  static void playCombo() {
    if (_sound) FlameAudio.play('combo.wav', volume: 0.85);
    if (_haptics) HapticFeedback.mediumImpact();
  }

  static void playGameOver() {
    if (_sound) FlameAudio.play('gameover.wav', volume: 0.75);
    if (_haptics) HapticFeedback.heavyImpact();
  }
}
