import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class RingComponent extends PositionComponent {
  double _gapAngle; // rotation angle of the first gap center
  double gapSize;
  int gapCount;    // number of evenly-spaced gaps
  double speed;    // rad/s, sign = direction
  Color color;

  double _flashTimer = 0;
  double _pulseTimer = 0;

  RingComponent({
    required Vector2 center,
    required double radius,
    required this.gapSize,
    required this.gapCount,
    required this.speed,
    required this.color,
  })  : _gapAngle = -pi / 2 + pi / 4,
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

  /// Proximity of closest gap to the aim angle (0–1).
  double get proximityToAim {
    double best = 0;
    final spacing = 2 * pi / gapCount;
    for (int i = 0; i < gapCount; i++) {
      final gapCenter = _gapAngle + i * spacing;
      final diff = _angleDiff(gapCenter, GameConstants.aimLaunchAngle).abs();
      final p = (1 - (diff / pi)).clamp(0.0, 1.0);
      if (p > best) best = p;
    }
    return best;
  }

  /// True if ball travelling at [ballAngle] passes through any gap.
  bool isBallAligned(double ballAngle) {
    final spacing = 2 * pi / gapCount;
    for (int i = 0; i < gapCount; i++) {
      final gapCenter = _gapAngle + i * spacing;
      if (_angleDiff(gapCenter, ballAngle).abs() < gapSize / 2) return true;
    }
    return false;
  }

  /// True if ball is perfectly centred in any gap.
  bool isBallPerfect(double ballAngle) {
    final spacing = 2 * pi / gapCount;
    for (int i = 0; i < gapCount; i++) {
      final gapCenter = _gapAngle + i * spacing;
      if (_angleDiff(gapCenter, ballAngle).abs() < GameConstants.perfectThreshold) return true;
    }
    return false;
  }

  /// Update difficulty parameters without recreating the component.
  void configure({required double newGapSize, required int newGapCount, required double newSpeed}) {
    gapSize  = newGapSize;
    gapCount = newGapCount;
    speed    = newSpeed;
    size     = Vector2.all(_radius * 2 + 40); // stays same but explicit
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
    canvas.translate(size.x / 2, size.y / 2);

    final flashIntensity = (_flashTimer / 0.18).clamp(0.0, 1.0);
    final pulse = 0.85 + 0.15 * sin(_pulseTimer * 1.8);
    final effectiveColor = Color.lerp(color, Colors.white, flashIntensity * 0.6)!;

    final rect = Rect.fromCircle(center: Offset.zero, radius: _radius);
    final spacing = 2 * pi / gapCount;
    // Each arc fills the space between two adjacent gap edges
    final arcSweep = (spacing - gapSize).clamp(0.01, spacing);

    final glowPaint = Paint()
      ..color = effectiveColor.withValues(alpha: 0.25 * pulse)
      ..style = PaintingStyle.stroke
      ..strokeWidth = GameConstants.ringStrokeWidth + 10
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, GameConstants.glowBlur);

    final ringPaint = Paint()
      ..color = effectiveColor.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = GameConstants.ringStrokeWidth
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < gapCount; i++) {
      final gapCenter = _gapAngle + i * spacing;
      final arcStart = gapCenter + gapSize / 2;

      canvas.drawArc(rect, arcStart, arcSweep, false, glowPaint);
      canvas.drawArc(rect, arcStart, arcSweep, false, ringPaint);

      // Gap edge highlights
      _drawGapEdge(canvas, gapCenter - gapSize / 2, effectiveColor);
      _drawGapEdge(canvas, gapCenter + gapSize / 2, effectiveColor);
    }
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
