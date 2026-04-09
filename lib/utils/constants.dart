import 'dart:math';

class GameConstants {
  // Ring
  static const double ringStrokeWidth = 8.0;
  static const double ringRadiusRatio = 0.33;
  static const double glowBlur = 12.0;

  // Gap count thresholds — single ring, gaps reduce as level climbs
  //   Level  1–5  → 4 gaps
  //   Level  6–13 → 3 gaps
  //   Level 14–24 → 2 gaps
  //   Level 25+   → 1 gap
  static const int gapCount3Threshold = 6;
  static const int gapCount2Threshold = 14;
  static const int gapCount1Threshold = 25;

  static int gapCountForLevel(int level) {
    if (level >= gapCount1Threshold) return 1;
    if (level >= gapCount2Threshold) return 2;
    if (level >= gapCount3Threshold) return 3;
    return 4;
  }

  // Per-tier gap base size (resets wider when gap count drops, then shrinks again)
  static const double gap4Base = 0.55;   // 4-gap tier — ~31° each
  static const double gap3Base = 0.70;   // 3-gap tier — ~40° each
  static const double gap2Base = 0.85;   // 2-gap tier — ~49° each
  static const double gap1Base = 0.90;   // 1-gap tier — ~52° → narrows to min
  static const double minGapSize = 0.32; // absolute floor ~18°
  static const double gapDecrement = 0.08;
  static const int levelsPerGapDecrement = 5;

  static double gapSizeForLevel(int level) {
    final gc = gapCountForLevel(level);
    final double base;
    final int entry;
    if (gc == 1) {
      base = gap1Base;
      entry = gapCount1Threshold;
    } else if (gc == 2) {
      base = gap2Base;
      entry = gapCount2Threshold;
    } else if (gc == 3) {
      base = gap3Base;
      entry = gapCount3Threshold;
    } else {
      base = gap4Base;
      entry = 1;
    }
    final tierLevel = level - entry;
    return (base -
            (tierLevel ~/ levelsPerGapDecrement) * gapDecrement)
        .clamp(minGapSize, base);
  }

  // Perfect threshold
  static const double perfectThreshold = 0.14; // ~8°

  // Speed — continuous ramp, no reset
  static const double initialSpeed = 2.2;
  static const double speedIncrement = 0.22;
  static const double maxSpeed = 8.5;
  static const int levelsPerSpeedIncrease = 3;

  static double speedForLevel(int level) =>
      (initialSpeed + (level ~/ levelsPerSpeedIncrease) * speedIncrement)
          .clamp(initialSpeed, maxSpeed);

  // Direction flip every N levels
  static const int levelsPerDirectionFlip = 12;

  // Ball
  static const double ballSpeed = 950.0;
  static const double ballRadius = 7.0;
  static const int maxBallsInFlight = 1;

  // Scoring
  static const int baseScore = 5;
  static const int perfectBase = 12;

  // Aim lane reference angle (kept for proximity calculation)
  static const double aimLaunchAngle = -pi / 2;

  // Ads
  static const int interstitialEvery = 3;
}
