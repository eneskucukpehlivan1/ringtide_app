import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CenterOrb extends PositionComponent {
  Color color;
  double _pulse = 0;
  int _combo = 0;

  CenterOrb({required Vector2 center, required this.color})
      : super(position: center, anchor: Anchor.center, size: Vector2.all(40));

  void updateCombo(int combo) => _combo = combo;

  @override
  void update(double dt) {
    super.update(dt);
    _pulse += dt * (2.0 + _combo * 0.3);
  }

  @override
  void render(Canvas canvas) {
    final pulseFactor = 0.85 + 0.15 * sin(_pulse);
    final radius = (6.0 + _combo * 0.5).clamp(6.0, 12.0) * pulseFactor;

    // Outer glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.35 * pulseFactor)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset.zero, radius + 8, glowPaint);

    // Core
    final corePaint = Paint()..color = color.withValues(alpha: 0.9);
    canvas.drawCircle(Offset.zero, radius, corePaint);

    // Inner highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5 * pulseFactor);
    canvas.drawCircle(const Offset(-1.5, -1.5), radius * 0.35, highlightPaint);
  }
}
