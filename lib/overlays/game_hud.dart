import 'package:flutter/material.dart';
import '../game/ringtide_game.dart';
import '../services/progression_service.dart';
import '../utils/app_strings.dart';

class GameHUD extends StatelessWidget {
  final RingtideGame game;
  const GameHUD({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = ProgressionService.instance.activeTheme;
    return IgnorePointer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Score block
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
                      shadows: [Shadow(color: theme.glowColor.withValues(alpha: 0.8), blurRadius: 12)],
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
              // Combo block
              if (game.combo >= 2)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.ringColor.withValues(alpha: 0.5), width: 1),
                    color: theme.ringColor.withValues(alpha: 0.12),
                  ),
                  child: Text(
                    'x${game.combo}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: theme.accentColor,
                      shadows: [Shadow(color: theme.glowColor.withValues(alpha: 0.9), blurRadius: 10)],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
