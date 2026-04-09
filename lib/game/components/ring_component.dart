import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

enum TapResult { miss, success, perfect }

class RingComponent extends PositionComponent {
  double _gapAngle; // center of gap, current angle
  double gapSize;
  double speed; // rad/s, sign = direction
  Color color;

  double _flashTimer = 0;
  double _pulseTimer = 0;

  RingComponent({
    required Vector2 center,
    required double radius,
    required this.gapSize,
    required this.speed,
    required this.color,
  })  : _gapAngle = -pi / 2 + pi / 4, // start gap slightly off marker
        super(
          position: center,
          size: Vector2.all(radius * 2 + 40),
          anchor: Anchor.center,
        ) {
    _radius = radius;
  }

  late double _radius;
  double get radius => _radius;

  @override
  void update(double dt) {
    super.update(dt);
    _gapAngle += speed * dt;

    if (_flashTimer > 0) _flashTimer -= dt;
    _pulseTimer += dt;
  }

  /// 0–1: how close the gap is to the aim angle right now.
  double get proximityToAim {
    final diff = _angleDiff(_gapAngle, GameConstants.aimLaunchAngle).abs();
    return (1 - (diff / pi)).clamp(0.0, 1.0);
  }

  /// Returns true if ball travelling at [ballAngle] passes through the gap.
  bool isBallAligned(double ballAngle) {
    final diff = _angleDiff(_gapAngle, ballAngle);
    return diff.abs() < gapSize / 2;
  }

  bool isBallPerfect(double ballAngle) {
    final diff = _angleDiff(_gapAngle, ballAngle);
    return diff.abs() < GameConstants.perfectThreshold;
  }

  void flash() => _flashTimer = 0.18;

  double _angleDiff(double a, double b) {
    var diff = (a - b) % (2 * pi);
    if (diff > pi) diff -= 2 * pi;
    if (diff < -pi) diff += 2 * pi;
    return diff;
  }

  @override
  void render(Canvas canvas) {
    // Shift origin to center of bounding box (Flame anchor doesn't do this in render)
    canvas.translate(size.x / 2, size.y / 2);

    final flashIntensity = (_flashTimer / 0.18).clamp(0.0, 1.0);
    final pulse = 0.85 + 0.15 * sin(_pulseTimer * 1.8);
    final effectiveColor = Color.lerp(color, Colors.white, flashIntensity * 0.6)!;

    final rect = Rect.fromCircle(center: Offset.zero, radius: _radius);
    final arcStart = _gapAngle + gapSize / 2;
    final arcSweep = 2 * pi - gapSize;

    // Outer glow
    final glowPaint = Paint()
      ..color = effectiveColor.withValues(alpha: 0.25 * pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = GameConstants.ringStrokeWidth + 10
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, GameConstants.glowBlur);
    canvas.drawArc(rect, arcStart, arcSweep, false, glowPaint);

    // Ring body
    final ringPaint = Paint()
      ..color = effectiveColor.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = GameConstants.ringStrokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, arcStart, arcSweep, false, ringPaint);

    // Gap edge highlights (small dots at gap edges)
    _drawGapEdge(canvas, _gapAngle - gapSize / 2, effectiveColor);
    _drawGapEdge(canvas, _gapAngle + gapSize / 2, effectiveColor);
  }

  void _drawGapEdge(Canvas canvas, double angle, Color c) {
    final x = _radius * cos(angle);
    final y = _radius * sin(angle);
    final paint = Paint()
      ..color = c.withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(x, y), 4, paint);
  }
}
