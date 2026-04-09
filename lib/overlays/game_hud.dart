import 'package:flutter/material.dart';
import '../game/ringtide_game.dart';
import '../services/progression_service.dart';
import '../utils/app_strings.dart';

class GameHUD extends StatelessWidget {
  final RingtideGame game;
  const GameHUD({super.key, required this.game});

  /// Levels remaining until next ring tier (0 = already at max).
  int _levelsToNextRing(int level) {
    if (level < 12) return 12 - level;
    if (level < 25) return 25 - level;
    return 0;
  }

  /// How many rings are active right now.
  int _ringCount(int level) {
    if (level >= 25) return 3;
    if (level >= 12) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProgressionService.instance.activeTheme;
    final rings = _ringCount(game.level);
    final toNext = _levelsToNextRing(game.level);
    final isMax = rings >= 3;

    return IgnorePointer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Top row: score (left) + combo (right)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Score + level
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${game.score}',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: theme.accentColor,
                          shadows: [
                            Shadow(
                                color: theme.glowColor.withValues(alpha: 0.8),
                                blurRadius: 12)
                          ],
                        ),
                      ),
                      Text(
                        '${S.level} ${game.level}',
                        style: TextStyle(
                            fontSize: 13,
                            color: theme.accentColor.withValues(alpha: 0.65),
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  // Combo
                  if (game.combo >= 2)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: theme.ringColor.withValues(alpha: 0.5),
                            width: 1),
                        color: theme.ringColor.withValues(alpha: 0.12),
                      ),
                      child: Text(
                        'x${game.combo}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: theme.accentColor,
                          shadows: [
                            Shadow(
                                color:
                                    theme.glowColor.withValues(alpha: 0.9),
                                blurRadius: 10)
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              // Bottom: ring-count countdown
              _RingCountdown(
                rings: rings,
                levelsLeft: toNext,
                isMax: isMax,
                color: theme.accentColor,
                ringColor: theme.ringColor,
                glowColor: theme.glowColor,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingCountdown extends StatelessWidget {
  final int rings;
  final int levelsLeft;
  final bool isMax;
  final Color color;
  final Color ringColor;
  final Color glowColor;

  const _RingCountdown({
    required this.rings,
    required this.levelsLeft,
    required this.isMax,
    required this.color,
    required this.ringColor,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ring dots: filled = active, hollow = locked
        for (int i = 1; i <= 3; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _RingDot(
              active: i <= rings,
              color: color,
              glowColor: glowColor,
            ),
          ),
        const SizedBox(width: 10),
        // Countdown text or MAX
        if (isMax)
          Text(
            S.ringMax,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color.withValues(alpha: 0.9),
              letterSpacing: 3,
              shadows: [Shadow(color: glowColor.withValues(alpha: 0.7), blurRadius: 8)],
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.ringCountdown(levelsLeft),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color.withValues(alpha: 0.9),
                  letterSpacing: 1,
                ),
              ),
              Text(
                S.ringCountdownLabel,
                style: TextStyle(
                  fontSize: 9,
                  color: color.withValues(alpha: 0.45),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _RingDot extends StatelessWidget {
  final bool active;
  final Color color;
  final Color glowColor;
  const _RingDot(
      {required this.active, required this.color, required this.glowColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? color.withValues(alpha: 0.9) : Colors.transparent,
        border: Border.all(
          color: active ? color : color.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                    color: glowColor.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1)
              ]
            : [],
      ),
    );
  }
}
