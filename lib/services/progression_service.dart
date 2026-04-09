import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_theme.dart';
import '../models/badge_definition.dart';
import '../models/daily_challenge.dart';

typedef GameResult = ({
  List<GameTheme> newThemes,
  List<BadgeDefinition> newBadges,
  bool dailyCompleted,
  int streakBonus,
  int currentStreak,
  bool weeklyRecord,
});

class ProgressionService {
  ProgressionService._();
  static final ProgressionService instance = ProgressionService._();

  static const _keyTotalScore = 'rt_total_score_v1';
  static const _keyActiveTheme = 'rt_active_theme';
  static const _keyUnlockedThemes = 'rt_unlocked_themes';
  static const _keyEarnedBadges = 'rt_earned_badges';
  static const _keyDailyChallengeDate = 'rt_daily_date';
  static const _keyDailyChallengeCompleted = 'rt_daily_done';
  static const _keyStreakCount = 'rt_streak_count';
  static const _keyStreakLastDate = 'rt_streak_last_date';
  static const _keyStreakLongest = 'rt_streak_longest';
  static const _keyWeeklyBest = 'rt_weekly_best';
  static const _keyWeeklyKey = 'rt_weekly_key';
  static const _keyTotalGames = 'rt_total_games';
  static const _keyTotalTaps = 'rt_total_taps';
  static const _keyBestCombo = 'rt_best_combo';
  static const _keySoundEnabled = 'rt_sound_enabled';
  static const _keyHapticsEnabled = 'rt_haptics_enabled';

  int totalScore = 0;
  String activeThemeId = 'purple';
  Set<String> unlockedThemes = {'purple'};
  Set<String> earnedBadges = {};
  bool dailyChallengeCompleted = false;
  String _todayStr = '';

  int currentStreak = 0;
  int longestStreak = 0;
  int weeklyBest = 0;
  String _weeklyKey = '';

  int totalGames = 0;
  int totalTaps = 0;
  int bestComboEver = 0;

  bool soundEnabled = true;
  bool hapticsEnabled = true;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    totalScore = prefs.getInt(_keyTotalScore) ?? 0;
    activeThemeId = prefs.getString(_keyActiveTheme) ?? 'purple';
    unlockedThemes = (prefs.getStringList(_keyUnlockedThemes) ?? ['purple']).toSet();
    earnedBadges = (prefs.getStringList(_keyEarnedBadges) ?? []).toSet();

    _todayStr = _todayKey();
    final savedDate = prefs.getString(_keyDailyChallengeDate) ?? '';
    dailyChallengeCompleted = savedDate == _todayStr &&
        (prefs.getBool(_keyDailyChallengeCompleted) ?? false);

    currentStreak = prefs.getInt(_keyStreakCount) ?? 0;
    longestStreak = prefs.getInt(_keyStreakLongest) ?? 0;
    final lastPlayDate = prefs.getString(_keyStreakLastDate) ?? '';
    _validateStreak(lastPlayDate, prefs);

    _weeklyKey = _currentWeekKey();
    final savedWeekKey = prefs.getString(_keyWeeklyKey) ?? '';
    if (savedWeekKey == _weeklyKey) {
      weeklyBest = prefs.getInt(_keyWeeklyBest) ?? 0;
    } else {
      weeklyBest = 0;
      await prefs.setString(_keyWeeklyKey, _weeklyKey);
      await prefs.setInt(_keyWeeklyBest, 0);
    }

    totalGames = prefs.getInt(_keyTotalGames) ?? 0;
    totalTaps = prefs.getInt(_keyTotalTaps) ?? 0;
    bestComboEver = prefs.getInt(_keyBestCombo) ?? 0;
    soundEnabled = prefs.getBool(_keySoundEnabled) ?? true;
    hapticsEnabled = prefs.getBool(_keyHapticsEnabled) ?? true;

    _syncUnlocks(prefs);
  }

  void _validateStreak(String lastPlayDate, SharedPreferences prefs) {
    if (lastPlayDate.isEmpty) return;
    final last = DateTime.tryParse(lastPlayDate);
    if (last == null) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = DateTime(last.year, last.month, last.day);
    if (today.difference(lastDay).inDays > 1) {
      currentStreak = 0;
      prefs.setInt(_keyStreakCount, 0);
    }
  }

  void _syncUnlocks(SharedPreferences prefs) {
    bool changed = false;
    for (final theme in kThemes) {
      if (!unlockedThemes.contains(theme.id) && totalScore >= theme.unlockScore) {
        unlockedThemes.add(theme.id);
        changed = true;
      }
    }
    if (changed) prefs.setStringList(_keyUnlockedThemes, unlockedThemes.toList());
  }

  GameTheme get activeTheme => kThemes.firstWhere(
        (t) => t.id == activeThemeId,
        orElse: () => kThemes.first,
      );

  DailyChallenge get dailyChallenge => DailyChallenge.forDate(DateTime.now());

  GameTheme? get nextLockedTheme {
    for (final theme in kThemes) {
      if (!unlockedThemes.contains(theme.id)) return theme;
    }
    return null;
  }

  Future<GameResult> addGameResult({
    required int score,
    required int level,
    required int maxCombo,
    required int tapsCount,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    totalGames++;
    totalTaps += tapsCount;
    if (maxCombo > bestComboEver) bestComboEver = maxCombo;
    await prefs.setInt(_keyTotalGames, totalGames);
    await prefs.setInt(_keyTotalTaps, totalTaps);
    await prefs.setInt(_keyBestCombo, bestComboEver);

    bool weeklyRecord = false;
    if (score > weeklyBest) {
      weeklyBest = score;
      weeklyRecord = true;
      await prefs.setInt(_keyWeeklyBest, weeklyBest);
    }

    int streakBonus = 0;
    final lastPlayDate = prefs.getString(_keyStreakLastDate) ?? '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastPlayDate != _todayStr) {
      final last = DateTime.tryParse(lastPlayDate);
      final lastDay = last != null ? DateTime(last.year, last.month, last.day) : null;
      final diff = lastDay != null ? today.difference(lastDay).inDays : 999;
      currentStreak = diff == 1 ? currentStreak + 1 : 1;
      await prefs.setString(_keyStreakLastDate, _todayStr);
      await prefs.setInt(_keyStreakCount, currentStreak);
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
        await prefs.setInt(_keyStreakLongest, longestStreak);
      }
      if (currentStreak == 3) {
        streakBonus = 100;
      } else if (currentStreak == 7) {
        streakBonus = 300;
      } else if (currentStreak == 14) {
        streakBonus = 600;
      } else if (currentStreak % 30 == 0 && currentStreak > 0) {
        streakBonus = 1500;
      }
    }

    bool dailyCompleted = false;
    if (!dailyChallengeCompleted) {
      final challenge = dailyChallenge;
      if (challenge.check(score: score, level: level, maxCombo: maxCombo)) {
        dailyChallengeCompleted = true;
        totalScore += DailyChallenge.bonusPoints;
        await prefs.setString(_keyDailyChallengeDate, _todayStr);
        await prefs.setBool(_keyDailyChallengeCompleted, true);
        dailyCompleted = true;
      }
    }

    totalScore += score + streakBonus;
    await prefs.setInt(_keyTotalScore, totalScore);

    final newThemes = <GameTheme>[];
    for (final theme in kThemes) {
      if (!unlockedThemes.contains(theme.id) && totalScore >= theme.unlockScore) {
        unlockedThemes.add(theme.id);
        newThemes.add(theme);
      }
    }
    if (newThemes.isNotEmpty) {
      await prefs.setStringList(_keyUnlockedThemes, unlockedThemes.toList());
    }

    final newBadges = <BadgeDefinition>[];
    final checks = <String, bool>{
      'first_tap': true,
      'century': score >= 100,
      'sharp_eye': maxCombo >= 5,
      'speed_demon': level >= 30,
      'legend': totalScore >= 50000,
    };
    for (final badge in kBadges) {
      if (!earnedBadges.contains(badge.id) && (checks[badge.id] ?? false)) {
        earnedBadges.add(badge.id);
        newBadges.add(badge);
      }
    }
    if (newBadges.isNotEmpty) {
      await prefs.setStringList(_keyEarnedBadges, earnedBadges.toList());
    }

    return (
      newThemes: newThemes,
      newBadges: newBadges,
      dailyCompleted: dailyCompleted,
      streakBonus: streakBonus,
      currentStreak: currentStreak,
      weeklyRecord: weeklyRecord,
    );
  }

  Future<void> setActiveTheme(String id) async {
    if (!unlockedThemes.contains(id)) return;
    activeThemeId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyActiveTheme, id);
  }

  Future<void> setSoundEnabled(bool val) async {
    soundEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySoundEnabled, val);
  }

  Future<void> setHapticsEnabled(bool val) async {
    hapticsEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHapticsEnabled, val);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _currentWeekKey() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }
}
