import 'package:flutter/material.dart';
import '../game/ringtide_game.dart';
import '../services/progression_service.dart';
import '../utils/app_strings.dart';

class TutorialHintOverlay extends StatelessWidget {
  final RingtideGame game;
  const TutorialHintOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = ProgressionService.instance.activeTheme;
    return GestureDetector(
      onTap: game.startGame,
      child: Container(
        color: Colors.transparent,
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              // Tutorial text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Text(
                      S.tutorialLine1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.accentColor.withValues(alpha: 0.75),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      S.tutorialLine2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.accentColor,
                        letterSpacing: 1,
                        shadows: [Shadow(color: theme.glowColor.withValues(alpha: 0.8), blurRadius: 10)],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              Text(
                S.tapToPlay,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.accentColor.withValues(alpha: 0.5),
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
