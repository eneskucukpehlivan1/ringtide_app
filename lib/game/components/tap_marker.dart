import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class TapMarker extends PositionComponent {
  Color color;
  double proximity = 0; // 0-1, 1 = gap at marker

  TapMarker({required Vector2 position, required this.color})
      : super(position: position, anchor: Anchor.center, size: Vector2.all(30));

  @override
  void render(Canvas canvas) {
    final glow = 0.3 + proximity * 0.7;
    final scale = 1.0 + proximity * 0.3;
    final size = GameConstants.markerSize * scale;

    // Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.4 * glow)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    _drawTriangle(canvas, size * 1.5, glowPaint);

    // Triangle body (pointing down toward ring)
    final paint = Paint()..color = color.withValues(alpha: 0.9 * glow);
    _drawTriangle(canvas, size, paint);
  }

  void _drawTriangle(Canvas canvas, double s, Paint paint) {
    final path = Path()
      ..moveTo(0, s * 0.6) // bottom tip (pointing toward ring)
      ..lineTo(-s * 0.5, -s * 0.4)
      ..lineTo(s * 0.5, -s * 0.4)
      ..close();
    canvas.drawPath(path, paint);
  }
}
