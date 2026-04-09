enum DailyChallengeType { score, level, combo }

class DailyChallenge {
  final DailyChallengeType type;
  final int target;
  static const int bonusPoints = 200;

  const DailyChallenge({required this.type, required this.target});

  static DailyChallenge forDate(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year)).inDays;
    final type = DailyChallengeType.values[dayOfYear % 3];
    int target;
    switch (type) {
      case DailyChallengeType.score:
        target = 50 + (dayOfYear % 10) * 10;
      case DailyChallengeType.level:
        target = 8 + (dayOfYear % 8) * 2;
      case DailyChallengeType.combo:
        target = 3 + (dayOfYear % 3);
    }
    return DailyChallenge(type: type, target: target);
  }

  bool check({int score = 0, int level = 0, int maxCombo = 0}) {
    switch (type) {
      case DailyChallengeType.score:
        return score >= target;
      case DailyChallengeType.level:
        return level >= target;
      case DailyChallengeType.combo:
        return maxCombo >= target;
    }
  }
}
