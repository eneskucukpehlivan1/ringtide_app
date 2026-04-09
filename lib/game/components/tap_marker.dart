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
    // Shift origin to center of bounding box (Flame anchor doesn't do this in render)
    canvas.translate(size.x / 2, size.y / 2);

    final glow = 0.3 + proximity * 0.7;
    final scale = 1.0 + proximity * 0.3;
    final markerSize = GameConstants.markerSize * scale;

    // Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.4 * glow)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    _drawTriangle(canvas, markerSize * 1.5, glowPaint);

    // Triangle body (pointing down toward ring)
    final paint = Paint()..color = color.withValues(alpha: 0.9 * glow);
    _drawTriangle(canvas, markerSize, paint);
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
