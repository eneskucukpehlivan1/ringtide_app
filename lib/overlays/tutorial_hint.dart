import 'package:flutter/material.dart';
import '../game/ringtide_game.dart';
import '../services/progression_service.dart';
import '../utils/app_strings.dart';

class TutorialHintOverlay extends StatefulWidget {
  final RingtideGame game;
  const TutorialHintOverlay({super.key, required this.game});

  @override
  State<TutorialHintOverlay> createState() => _TutorialHintOverlayState();
}

class _TutorialHintOverlayState extends State<TutorialHintOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ProgressionService.instance.activeTheme;
    return GestureDetector(
      onTap: widget.game.startGame,
      child: Container(
        color: Colors.transparent,
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Instruction card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: theme.bgDark.withValues(alpha: 0.85),
                    border: Border.all(color: theme.ringColor.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    children: [
                      // Step 1
                      _Step(
                        icon: '🌀',
                        text: S.tutorialLine1,
                        color: theme.accentColor,
                      ),
                      const SizedBox(height: 14),
                      // Divider
                      Container(height: 1, color: theme.ringColor.withValues(alpha: 0.2)),
                      const SizedBox(height: 14),
                      // Step 2
                      _Step(
                        icon: '▼',
                        iconColor: theme.accentColor,
                        text: S.tutorialLine2,
                        color: theme.accentColor,
                      ),
                      const SizedBox(height: 14),
                      Container(height: 1, color: theme.ringColor.withValues(alpha: 0.2)),
                      const SizedBox(height: 14),
                      // Step 3 — scoring
                      _Step(
                        icon: '🎯',
                        text: S.tutorialLine3,
                        color: theme.accentColor,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // Animated tap prompt
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) => Opacity(
                  opacity: 0.5 + 0.5 * _pulse.value,
                  child: Column(
                    children: [
                      Text(
                        '👆',
                        style: TextStyle(
                          fontSize: 36 + 6 * _pulse.value,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        S.tapToPlay,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.accentColor.withValues(alpha: 0.7),
                          letterSpacing: 3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 56),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String icon;
  final String text;
  final Color color;
  final Color? iconColor;

  const _Step({
    required this.icon,
    required this.text,
    required this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon,
            style: TextStyle(
                fontSize: 22,
                color: iconColor,
                shadows: iconColor != null
                    ? [Shadow(color: iconColor!.withValues(alpha: 0.8), blurRadius: 10)]
                    : null)),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: color.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
