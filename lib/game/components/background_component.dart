import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../ringtide_game.dart';

class BackgroundComponent extends Component with HasGameReference<RingtideGame> {
  @override
  void render(Canvas canvas) {
    final size = game.size;
    final theme = game.activeTheme;

    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [theme.bgDark, theme.bgLight],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), bgPaint);

    // Subtle radial glow at center
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.6,
        colors: [
          theme.glowColor.withValues(alpha: 0.07),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), glowPaint);
  }
}
