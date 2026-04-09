import 'package:flutter/material.dart';
import '../game/ringtide_game.dart';
import '../services/progression_service.dart';
import '../utils/app_strings.dart';

class MainMenuOverlay extends StatelessWidget {
  final RingtideGame game;
  const MainMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final ps = ProgressionService.instance;
    final theme = ps.activeTheme;
    final daily = ps.dailyChallenge;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Logo / Title
            Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.ringColor.withValues(alpha: 0.8), width: 3),
                    boxShadow: [BoxShadow(color: theme.glowColor.withValues(alpha: 0.4), blurRadius: 24, spreadRadius: 4)],
                    color: theme.bgDark,
                  ),
                  child: Center(
                    child: Icon(Icons.radio_button_unchecked, color: theme.ringColor, size: 48),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'RINGTIDE',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: theme.accentColor,
                    letterSpacing: 8,
                    shadows: [Shadow(color: theme.glowColor.withValues(alpha: 0.8), blurRadius: 16)],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  S.totalScore(ps.totalScore),
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.accentColor.withValues(alpha: 0.7),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const Spacer(flex: 1),
            // Daily challenge card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.ringColor.withValues(alpha: 0.3), width: 1),
                  borderRadius: BorderRadius.circular(16),
                  color: theme.bgLight.withValues(alpha: 0.6),
                ),
                child: Row(
                  children: [
                    Text('🎯', style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(S.daily,
                              style: TextStyle(
                                  fontSize: 11, color: theme.accentColor, fontWeight: FontWeight.w700, letterSpacing: 2)),
                          const SizedBox(height: 2),
                          Text(
                            ps.dailyChallengeCompleted ? S.dailyDone : S.dailyChallengeDesc(daily),
                            style: TextStyle(
                                fontSize: 13,
                                color: ps.dailyChallengeCompleted
                                    ? theme.accentColor
                                    : theme.accentColor.withValues(alpha: 0.75)),
                          ),
                        ],
                      ),
                    ),
                    if (ps.currentStreak > 0)
                      Text(S.streakDays(ps.currentStreak),
                          style: TextStyle(fontSize: 12, color: theme.accentColor.withValues(alpha: 0.8))),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 1),
            // Play button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: _GlowButton(
                label: S.play,
                color: theme.ringColor,
                glowColor: theme.glowColor,
                onTap: game.startTutorial,
                large: true,
              ),
            ),
            const SizedBox(height: 16),
            // Secondary buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Row(
                children: [
                  Expanded(
                    child: _GlowButton(
                      label: '${theme.emoji} ${S.themes}',
                      color: theme.accentColor,
                      glowColor: theme.glowColor,
                      onTap: () {
                        game.overlays.remove('MainMenu');
                        game.overlays.add('ThemeSelect');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GlowButton(
                      label: '📊 ${S.stats}',
                      color: theme.accentColor,
                      glowColor: theme.glowColor,
                      onTap: () {
                        game.overlays.remove('MainMenu');
                        game.overlays.add('StatsOverlay');
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

class _GlowButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color glowColor;
  final VoidCallback onTap;
  final bool large;

  const _GlowButton({
    required this.label,
    required this.color,
    required this.glowColor,
    required this.onTap,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: large ? 58 : 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(large ? 30 : 24),
          border: Border.all(color: color.withValues(alpha: 0.85), width: 1.5),
          color: color.withValues(alpha: 0.12),
          boxShadow: [BoxShadow(color: glowColor.withValues(alpha: 0.3), blurRadius: 16)],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: large ? 18 : 14,
              fontWeight: FontWeight.w800,
              letterSpacing: large ? 4 : 2,
            ),
          ),
        ),
      ),
    );
  }
}
