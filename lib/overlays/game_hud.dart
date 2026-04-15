import 'package:flutter/material.dart';
import '../game/ringtide_game.dart';
import '../services/progression_service.dart';
import '../utils/app_strings.dart';

class GameHUD extends StatefulWidget {
  final RingtideGame game;
  const GameHUD({super.key, required this.game});

  @override
  State<GameHUD> createState() => _GameHUDState();
}

class _GameHUDState extends State<GameHUD> {

  @override
  Widget build(BuildContext context) {
    final theme = ProgressionService.instance.activeTheme;
    final gapCount = widget.game.hudNewestGapCount;
    final toNext   = widget.game.hudLevelsToFewerGaps;
    final ringCount = widget.game.hudRingCount;
    final isHardest = gapCount <= 1 && ringCount >= 3;

    return IgnorePointer(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${widget.game.score}',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: theme.accentColor,
                              shadows: [Shadow(color: theme.glowColor.withValues(alpha: 0.8), blurRadius: 12)],
                            ),
                          ),
                          Text(
                            '${S.level} ${widget.game.level}',
                            style: TextStyle(
                                fontSize: 13,
                                color: theme.accentColor.withValues(alpha: 0.65),
                                letterSpacing: 2,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      if (widget.game.combo >= 2)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: theme.ringColor.withValues(alpha: 0.5), width: 1),
                            color: theme.ringColor.withValues(alpha: 0.12),
                          ),
                          child: Text(
                            'x${widget.game.combo}',
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
                  const Spacer(),
                  _GapCountdown(
                    gapCount: gapCount,
                    ringCount: ringCount,
                    levelsLeft: toNext,
                    isHardest: isHardest,
                    color: theme.accentColor,
                    ringColor: theme.ringColor,
                    glowColor: theme.glowColor,
                  ),
              SizedBox(height: 8 + 50 + MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }
}

class _GapCountdown extends StatelessWidget {
  final int gapCount;
  final int ringCount;
  final int levelsLeft;
  final bool isHardest;
  final Color color;
  final Color ringColor;
  final Color glowColor;

  const _GapCountdown({
    required this.gapCount,
    required this.ringCount,
    required this.levelsLeft,
    required this.isHardest,
    required this.color,
    required this.ringColor,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 1; i <= 3; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _RingDot(active: i <= ringCount, color: color, glowColor: glowColor),
          ),
        const SizedBox(width: 8),
        for (int i = 4; i >= 1; i--)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _GapDot(active: i <= gapCount, color: color, glowColor: glowColor),
          ),
        const SizedBox(width: 10),
        if (isHardest)
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
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color.withValues(alpha: 0.9), letterSpacing: 1),
              ),
              Text(
                S.gapCountdownLabel,
                style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.45), letterSpacing: 1.5),
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
  const _RingDot({required this.active, required this.color, required this.glowColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        border: Border.all(
          color: active ? color.withValues(alpha: 0.9) : color.withValues(alpha: 0.20),
          width: active ? 2.5 : 1.5,
        ),
        boxShadow: active ? [BoxShadow(color: glowColor.withValues(alpha: 0.6), blurRadius: 8, spreadRadius: 1)] : [],
      ),
    );
  }
}

class _GapDot extends StatelessWidget {
  final bool active;
  final Color color;
  final Color glowColor;
  const _GapDot({required this.active, required this.color, required this.glowColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? color.withValues(alpha: 0.9) : Colors.transparent,
        border: Border.all(
          color: active ? color : color.withValues(alpha: 0.20),
          width: 1.5,
        ),
        boxShadow: active ? [BoxShadow(color: glowColor.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1)] : [],
      ),
    );
  }
}
