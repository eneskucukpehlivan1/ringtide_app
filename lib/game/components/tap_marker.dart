import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Small pulsing ring at the launch origin (screen center) to hint "tap to shoot".
class TapMarker extends PositionComponent {
  Color color;
  double outerRadius; // kept for API compat, unused in render
  double alignment = 0;
  double _pulse = 0;

  TapMarker({
    required Vector2 center,
    required this.color,
    required this.outerRadius,
  }) : super(position: center, size: Vector2.all(2));

  void updateRadius(double r) => outerRadius = r;

  @override
  void update(double dt) {
    _pulse += dt * 2.2;
  }

  @override
  void render(Canvas canvas) {
    // Subtle pulsing ring around center — "tap anywhere to shoot"
    final pulse = 0.5 + 0.5 * sin(_pulse);
    final r = 16.0 + 4.0 * pulse;
    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..color = color.withValues(alpha: 0.18 + 0.12 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }
}
