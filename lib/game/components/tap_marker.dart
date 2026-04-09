import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Aim lane: dashed line from just above center to ring edge, plus
/// the ▼ notch sitting outside the outermost ring.
class TapMarker extends PositionComponent {
  Color color;
  double outerRadius;

  TapMarker({
    required Vector2 center,
    required this.color,
    required this.outerRadius,
  }) : super(position: center, size: Vector2.all(2));

  void updateRadius(double r) => outerRadius = r;

  @override
  void render(Canvas canvas) {
    // Dashed aim line from center toward top
    final dashPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashLen = 6.0;
    const gapLen = 5.0;
    double y = -12.0;
    final stop = -outerRadius + 4;
    while (y > stop) {
      final segEnd = max(y - dashLen, stop);
      canvas.drawLine(Offset(0, y), Offset(0, segEnd), dashPaint);
      y -= dashLen + gapLen;
    }

    // Notch triangle outside outermost ring
    final notchY = -(outerRadius + 18);
    final s = 10.0;
    final notchPaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    final path = Path()
      ..moveTo(0, notchY + s * 0.6)    // tip pointing down toward ring
      ..lineTo(-s * 0.5, notchY - s * 0.4)
      ..lineTo(s * 0.5, notchY - s * 0.4)
      ..close();
    canvas.drawPath(path, notchPaint);
    notchPaint.maskFilter = null;
    notchPaint.color = color;
    canvas.drawPath(path, notchPaint);
  }
}
