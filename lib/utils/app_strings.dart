import 'package:flutter/widgets.dart';
import '../models/daily_challenge.dart';

class S {
  static bool get _tr {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    return locale.languageCode == 'tr';
  }

  static String loc(String tr, String en) => _tr ? tr : en;

  // Core
  static String get play => _tr ? 'OYNA' : 'PLAY';
  static String get best => _tr ? 'EN İYİ' : 'BEST';
  static String get level => _tr ? 'SEVİYE' : 'LEVEL';
  static String get gameOver => _tr ? 'OYUN BİTTİ' : 'GAME OVER';
  static String get newBest => _tr ? 'YENİ REKOR' : 'NEW BEST';
  static String get playAgain => _tr ? 'TEKRAR OYNA' : 'PLAY AGAIN';
  static String get menu => _tr ? 'MENÜ' : 'MENU';
  static String get share => _tr ? '↗ PAYLAŞ' : '↗ SHARE';
  static String get continueBtn => _tr ? 'DEVAM ET  ▶' : 'CONTINUE  ▶';
  static String get watchAdToContinue =>
      _tr ? 'Reklam izle ve devam et' : 'Watch an ad to keep going';
  static String get tapHint => _tr ? 'DOKUN' : 'TAP';
  static String get tapToPlay => _tr ? 'OYNAMAK İÇİN DOKUN' : 'TAP TO PLAY';

  // Tutorial
  static String get tutorialLine1 =>
      _tr ? 'Halka sürekli dönüyor — halkada bir boşluk var' : 'The ring keeps spinning — it has a gap';
  static String get tutorialLine2 =>
      _tr ? 'Boşluk yukarıdaki ▼ işaretine geldiğinde dokun' : 'Tap when the gap reaches the ▼ marker at the top';
  static String get tutorialLine3 =>
      _tr ? 'Tam zamanında: MÜKEMMEL bonus\nErken/geç: kaçırdın, oyun bitti' : 'Right on time: PERFECT bonus\nToo early/late: miss, game over';

  // Combo / perfect
  static String get perfect => _tr ? 'MÜKEMMEL!' : 'PERFECT!';
  static String perfectCombo(int n) =>
      _tr ? '🔥 MÜKEMMEL x$n' : '🔥 PERFECT x$n';

  static String longestCombo(int n) =>
      _tr ? 'En uzun kombo: $n' : 'Longest combo: $n';

  // Themes
  static String get themes => _tr ? 'TEMALAR' : 'THEMES';
  static String get points => _tr ? 'puan' : 'pts';
  static String get unlocked => _tr ? 'AÇILDI ✓' : 'UNLOCKED ✓';
  static String get allThemesUnlocked =>
      _tr ? 'Tüm temalar açık! 🎉' : 'All themes unlocked! 🎉';
  static String totalScore(int n) =>
      _tr ? 'Toplam puan: $n' : 'Total points: $n';

  // Daily
  static String get daily => _tr ? 'GÜNLÜK GÖREV' : 'DAILY CHALLENGE';
  static String get dailyDone => _tr ? 'Tamamlandı! +200 puan 🎯' : 'Done! +200 pts 🎯';
  static String dailyChallengeDesc(DailyChallenge c) {
    switch (c.type) {
      case DailyChallengeType.score:
        return _tr
            ? 'Tek oyunda ${c.target} puan kazan'
            : 'Score ${c.target} points in one game';
      case DailyChallengeType.level:
        return _tr ? 'Level ${c.target}\'e ulaş' : 'Reach level ${c.target}';
      case DailyChallengeType.combo:
        return _tr ? 'Combo x${c.target} yap' : 'Get a x${c.target} combo';
    }
  }

  // Streak
  static String streakDays(int n) =>
      _tr ? '🔥 $n günlük seri' : '🔥 $n day streak';
  static String streakBonusEarned(int pts) =>
      _tr ? '+$pts seri bonusu!' : '+$pts streak bonus!';
  static String get streakLabel => _tr ? 'SERİ' : 'STREAK';

  // Weekly
  static String get weeklyBest => _tr ? 'BU HAFTA' : 'THIS WEEK';
  static String get weeklyRecord => _tr ? '📈 Haftalık rekor!' : '📈 Weekly record!';

  // Stats
  static String get stats => _tr ? 'İSTATİSTİK' : 'STATS';
  static String get statsTotalGames => _tr ? 'Toplam Oyun' : 'Total Games';
  static String get statsTotalTaps => _tr ? 'Toplam Dokunuş' : 'Total Taps';
  static String get statsBestCombo => _tr ? 'En İyi Kombo' : 'Best Combo';
  static String get statsTotalScore => _tr ? 'Toplam Puan' : 'Total Score';
  static String get statsLongestStreak => _tr ? 'En Uzun Seri' : 'Longest Streak';

  // Settings
  static String get sound => _tr ? 'SES' : 'SOUND';
  static String get haptics => _tr ? 'TİTREŞİM' : 'HAPTICS';

  // Badges
  static String get newBadge => _tr ? 'YENİ ROZET' : 'NEW BADGE';

  // Share
  static String shareText(int score, int level, int combo) => _tr
      ? '🌀 Ringtide\'da $score puan yaptım!\nSeviye: $level | En uzun kombo: $combo\nSen de dene! 👆'
      : '🌀 I scored $score in Ringtide!\nLevel: $level | Longest combo: $combo\nGive it a try! 👆';
}
