import 'dart:math';

class GameConstants {
  // Ring
  static const double ringStrokeWidth = 8.0;
  static const double ringRadiusRatio = 0.33;
  static const double glowBlur = 12.0;

  // Gap — tighter from the start
  static const double initialGapSize = 0.90; // ~52 degrees
  static const double minGapSize = 0.38;     // ~22 degrees
  static const double gapDecrement = 0.09;   // every 8 levels
  static const int levelsPerGapDecrement = 8;
  static const double perfectThreshold = 0.14; // ~8 degrees

  // Speed — fast, keeps getting faster
  static const double initialSpeed = 2.4;    // rad/s
  static const double speedIncrement = 0.22;
  static const double maxSpeed = 8.5;
  static const int levelsPerSpeedIncrease = 3;

  // Direction flip
  static const int levelsPerDirectionFlip = 12;

  // Ball
  static const double ballSpeed = 950.0;   // px per second
  static const double ballRadius = 7.0;
  static const int maxBallsInFlight = 1;

  // Scoring
  static const int baseScore = 5;
  static const int perfectBase = 12;

  // Aim lane
  static const double aimLaunchAngle = -pi / 2; // straight up, 12 o'clock

  // Per-tier difficulty reset (when ring count increases, start easier again)
  // Tier 1: 1 ring  (levels 1–11)
  static const double tier1SpeedBase = 2.4;
  static const double tier1GapBase   = 0.90;
  // Tier 2: 2 rings (levels 12–24)  — wider gap, slower speed at tier entry
  static const double tier2SpeedBase = 1.9;
  static const double tier2GapBase   = 1.10;
  // Tier 3: 3 rings (levels 25+)
  static const double tier3SpeedBase = 1.6;
  static const double tier3GapBase   = 1.20;

  // Ads
  static const int interstitialEvery = 3;
}
