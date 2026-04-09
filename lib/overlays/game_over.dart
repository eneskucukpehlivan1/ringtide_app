import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../game/ringtide_game.dart';
import '../services/progression_service.dart';
import '../services/ad_service.dart';
import '../models/game_theme.dart';
import '../utils/app_strings.dart';

class GameOverOverlay extends StatefulWidget {
  final RingtideGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  Future<void> _loadResult() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final ps = ProgressionService.instance;
    final theme = ps.activeTheme;
    final game = widget.game;

    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: theme.accentColor),
      );
    }

    return Scaffold(
      backgroundColor: theme.bgDark.withValues(alpha: 0.92),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                // Game Over title
                Text(
                  S.gameOver,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: theme.accentColor,
                    letterSpacing: 6,
                    shadows: [Shadow(color: theme.glowColor.withValues(alpha: 0.8), blurRadius: 20)],
                  ),
                ),
                const SizedBox(height: 32),
                // Score
                Center(
                  child: Column(
                    children: [
                      Text(
                        '${game.score}',
                        style: TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w900,
                          color: theme.accentColor,
                          shadows: [Shadow(color: theme.glowColor.withValues(alpha: 0.9), blurRadius: 24)],
                        ),
                      ),
                      Text(
                        S.longestCombo(game.maxCombo),
                        style: TextStyle(
                            fontSize: 14,
                            color: theme.accentColor.withValues(alpha: 0.65),
                            letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatChip(label: S.level, value: '${game.level}', theme: theme),
                    const SizedBox(width: 12),
                    _StatChip(
                        label: S.streakLabel, value: '${ps.currentStreak}🔥', theme: theme),
                    const SizedBox(width: 12),
                    _StatChip(label: S.weeklyBest, value: '${ps.weeklyBest}', theme: theme),
                  ],
                ),
                const SizedBox(height: 16),
                // Next unlock progress
                _NextUnlockCard(ps: ps, theme: theme),
                const SizedBox(height: 16),
                // Badges
                if (ps.earnedBadges.isNotEmpty) ...[
                  Center(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: ps.earnedBadges
                          .map((id) => _badgeChip(id, theme))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Continue with ad
                if (game.canContinue) ...[
                  _ActionButton(
                    label: S.watchAdToContinue,
                    color: theme.glowColor,
                    borderColor: theme.glowColor,
                    onTap: () async {
                      await AdService.instance.showRewarded(
                        onRewarded: () => game.useContinue(),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                ],
                // Play Again
                _ActionButton(
                  label: S.playAgain,
                  color: theme.accentColor,
                  borderColor: theme.ringColor,
                  onTap: game.restartGame,
                  large: true,
                ),
                const SizedBox(height: 10),
                // Share & Menu row
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: S.share,
                        color: theme.accentColor.withValues(alpha: 0.8),
                        borderColor: theme.ringColor.withValues(alpha: 0.5),
                        onTap: () {
                          SharePlus.instance.share(
                            ShareParams(text: S.shareText(game.score, game.level, game.maxCombo)),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        label: S.menu,
                        color: theme.accentColor.withValues(alpha: 0.8),
                        borderColor: theme.ringColor.withValues(alpha: 0.5),
                        onTap: game.goToMenu,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badgeChip(String id, theme) {
    final emoji = _badgeEmoji(id);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (theme.accentColor as Color).withValues(alpha: 0.4)),
        color: (theme.accentColor as Color).withValues(alpha: 0.08),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 18)),
    );
  }

  String _badgeEmoji(String id) {
    switch (id) {
      case 'first_tap': return '👆';
      case 'century': return '💯';
      case 'sharp_eye': return '🎯';
      case 'speed_demon': return '⚡';
      case 'legend': return '🏆';
      default: return '🏅';
    }
  }
}

class _NextUnlockCard extends StatelessWidget {
  final ProgressionService ps;
  final dynamic theme;
  const _NextUnlockCard({required this.ps, required this.theme});

  @override
  Widget build(BuildContext context) {
    final next = ps.nextLockedTheme;
    final isTr = S.isTr == 'tr';

    if (next == null) {
      return Center(
        child: Text(
          S.allThemesUnlocked,
          style: TextStyle(
              fontSize: 13,
              color: (theme.accentColor as Color).withValues(alpha: 0.7),
              letterSpacing: 1),
        ),
      );
    }

    final current = ps.totalScore;
    final target = next.unlockScore;
    // Find previous tier's score (for meaningful progress bar start)
    final prevScore = _prevThresholdScore(next);
    final range = (target - prevScore).toDouble();
    final progress = range > 0 ? ((current - prevScore) / range).clamp(0.0, 1.0) : 1.0;
    final remaining = (target - current).clamp(0, target);
    final themeName = isTr ? next.nameTr : next.nameEn;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: (theme.ringColor as Color).withValues(alpha: 0.3)),
        color: (theme.ringColor as Color).withValues(alpha: 0.07),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.nextUnlockLabel,
                style: TextStyle(
                    fontSize: 10,
                    color: (theme.accentColor as Color).withValues(alpha: 0.55),
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700),
              ),
              Text(
                '${next.emoji} $themeName',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: theme.accentColor as Color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor:
                  (theme.ringColor as Color).withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                  theme.accentColor as Color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            S.nextUnlockProgress(themeName, remaining),
            style: TextStyle(
                fontSize: 12,
                color: (theme.accentColor as Color).withValues(alpha: 0.65)),
          ),
        ],
      ),
    );
  }

  int _prevThresholdScore(GameTheme next) {
    final idx = kThemes.indexWhere((t) => t.id == next.id);
    if (idx <= 0) return 0;
    return kThemes[idx - 1].unlockScore;
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final dynamic theme;
  const _StatChip({required this.label, required this.value, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (theme.ringColor as Color).withValues(alpha: 0.3)),
        color: (theme.ringColor as Color).withValues(alpha: 0.08),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: theme.accentColor as Color)),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: (theme.accentColor as Color).withValues(alpha: 0.6),
                  letterSpacing: 1.5)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color borderColor;
  final VoidCallback onTap;
  final bool large;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.borderColor,
    required this.onTap,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: large ? 56 : 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(large ? 28 : 24),
          border: Border.all(color: borderColor.withValues(alpha: 0.8), width: 1.5),
          color: color.withValues(alpha: 0.12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: large ? 17 : 14,
              fontWeight: FontWeight.w800,
              letterSpacing: large ? 3 : 2,
            ),
          ),
        ),
      ),
    );
  }
}
