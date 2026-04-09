import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Aim lane: dashed line from center toward top + notch outside outermost ring.
/// [alignment] 0–1: how aligned all ring gaps are simultaneously.
/// When alignment is high, the lane glows green as a "shoot now!" cue.
class TapMarker extends PositionComponent {
  Color color;
  double outerRadius;
  double alignment = 0; // 0 = not aligned, 1 = all gaps at top

  TapMarker({
    required Vector2 center,
    required this.color,
    required this.outerRadius,
  }) : super(position: center, size: Vector2.all(2));

  void updateRadius(double r) => outerRadius = r;

  @override
  void render(Canvas canvas) {
    // Blend color toward green when gaps are aligned
    final blended = Color.lerp(
      color.withValues(alpha: 0.28),
      const Color(0xFF4ADE80).withValues(alpha: 0.85),
      _alignCurve(alignment),
    )!;

    // Dashed aim line from just above center to ring edge
    final dashPaint = Paint()
      ..color = blended
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
    const s = 10.0;
    final notchColor = Color.lerp(
      color,
      const Color(0xFF4ADE80),
      _alignCurve(alignment),
    )!;
    final notchGlow = Paint()
      ..color = notchColor.withValues(alpha: 0.5 + 0.4 * _alignCurve(alignment))
      ..maskFilter = MaskFilter.blur(
          BlurStyle.normal, 4 + 8 * _alignCurve(alignment));
    final path = Path()
      ..moveTo(0, notchY + s * 0.6)
      ..lineTo(-s * 0.5, notchY - s * 0.4)
      ..lineTo(s * 0.5, notchY - s * 0.4)
      ..close();
    canvas.drawPath(path, notchGlow);
    canvas.drawPath(path, Paint()..color = notchColor);
  }

  /// Ease curve: makes the glow snap on sharply near 1 rather than linearly.
  double _alignCurve(double t) {
    final v = ((t - 0.72) / 0.28).clamp(0.0, 1.0);
    return v * v;
  }
}
