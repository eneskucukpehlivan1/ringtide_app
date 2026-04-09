import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class _Particle {
  double angle;
  double speed;
  double radius;
  double life; // 0-1, decreasing
  Color color;

  _Particle({
    required this.angle,
    required this.speed,
    required this.radius,
    required this.color,
  }) : life = 1.0;
}

class ParticleBurst extends Component {
  final Vector2 center;
  final Color color;
  final bool isPerfect;
  final List<_Particle> _particles = [];
  bool _done = false;

  static final _rng = Random();

  ParticleBurst({required this.center, required this.color, this.isPerfect = false}) {
    final count = isPerfect ? 18 : 10;
    for (int i = 0; i < count; i++) {
      _particles.add(_Particle(
        angle: _rng.nextDouble() * 2 * pi,
        speed: 80 + _rng.nextDouble() * (isPerfect ? 120 : 70),
        radius: 2.5 + _rng.nextDouble() * 3,
        color: Color.lerp(color, Colors.white, _rng.nextDouble() * 0.5)!,
      ));
    }
  }

  @override
  void update(double dt) {
    bool allDead = true;
    for (final p in _particles) {
      p.life -= dt * (isPerfect ? 1.8 : 2.4);
      if (p.life > 0) allDead = false;
    }
    if (allDead && !_done) {
      _done = true;
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    for (final p in _particles) {
      if (p.life <= 0) continue;
      final dist = (1 - p.life) * p.speed * (isPerfect ? 1.2 : 1.0);
      final x = center.x + cos(p.angle) * dist;
      final y = center.y + sin(p.angle) * dist;
      final alpha = p.life.clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha * 0.9)
        ..maskFilter = isPerfect ? const MaskFilter.blur(BlurStyle.normal, 3) : null;
      canvas.drawCircle(Offset(x, y), p.radius * p.life, paint);
    }
  }
}
