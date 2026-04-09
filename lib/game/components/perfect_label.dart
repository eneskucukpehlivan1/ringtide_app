import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PerfectLabel extends Component {
  final Vector2 position;
  final String text;
  final Color color;
  double _life = 1.0;
  double _y;

  PerfectLabel({required this.position, required this.text, required this.color})
      : _y = position.y;

  @override
  void update(double dt) {
    _life -= dt * 1.6;
    _y -= dt * 55;
    if (_life <= 0) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final alpha = _life.clamp(0.0, 1.0);

    // Glow
    final glowPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          foreground: Paint()
            ..color = color.withValues(alpha: alpha * 0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: color.withValues(alpha: alpha),
          letterSpacing: 2,
          shadows: [
            Shadow(color: color.withValues(alpha: alpha * 0.8), blurRadius: 6),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final x = position.x - textPainter.width / 2;
    glowPainter.paint(canvas, Offset(x, _y));
    textPainter.paint(canvas, Offset(x, _y));
  }
}
