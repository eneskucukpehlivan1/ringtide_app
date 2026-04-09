import 'dart:math';

class GameConstants {
  // Ring
  static const double ringStrokeWidth = 8.0;
  static const double ringRadiusRatio = 0.33; // fraction of min(w,h)
  static const double glowBlur = 12.0;

  // Gap
  static const double initialGapSize = 1.22; // ~70 degrees in radians
  static const double minGapSize = 0.58; // ~33 degrees
  static const double gapDecrement = 0.12; // every 10 levels
  static const double perfectThreshold = 0.17; // ~10 degrees

  // Speed
  static const double initialSpeed = 1.3; // rad/s
  static const double speedIncrement = 0.13;
  static const double maxSpeed = 4.8;
  static const int levelsPerSpeedIncrease = 5;

  // Direction flip
  static const int levelsPerDirectionFlip = 15;

  // Scoring
  static const int baseScore = 5;
  static const int perfectBase = 10;
  static const int comboMultiplier = 3;

  // Marker
  static const double markerAngle = -pi / 2; // 12 o'clock
  static const double markerSize = 12.0;
  static const double markerOffset = 22.0; // outside ring

  // Ads
  static const int interstitialEvery = 3;
}
