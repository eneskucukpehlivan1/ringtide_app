import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

enum BallState { flying, passed, exploded }

typedef BallHitCallback = void Function(bool miss, double hitRadius);

class BallComponent extends Component {
  final Vector2 origin;
  final List<double> ringRadii; // ascending — innermost to outermost
  final List<bool Function()> gapChecks; // true = gap aligned at launch angle
  final BallHitCallback onResult;
  final Color color;

  double _dist = 0;
  int _nextRing = 0;
  BallState _state = BallState.flying;

  // Trail
  final List<_TrailDot> _trail = [];
  static const _trailLen = 10;

  // Explosion particles
  final List<_Spark> _sparks = [];
  double _explodeTimer = 0;
  bool _removePending = false;

  static final _rng = Random();

  BallComponent({
    required this.origin,
    required this.ringRadii,
    required this.gapChecks,
    required this.onResult,
    required this.color,
  });

  @override
  void update(double dt) {
    if (_state == BallState.exploded) {
      _explodeTimer -= dt;
      for (final s in _sparks) {
        s.life -= dt * 3.5;
        s.x += cos(s.angle) * s.speed * dt;
        s.y += sin(s.angle) * s.speed * dt;
      }
      if (_explodeTimer <= 0 && !_removePending) {
        _removePending = true;
        removeFromParent();
      }
      return;
    }

    _dist += GameConstants.ballSpeed * dt;
    final ballPos = _ballPos();

    // Record trail
    _trail.add(_TrailDot(x: ballPos.x, y: ballPos.y, life: 1.0));
    if (_trail.length > _trailLen) _trail.removeAt(0);
    for (final t in _trail) { t.life -= dt * 8; }

    // Check each ring in order
    while (_nextRing < ringRadii.length && _dist >= ringRadii[_nextRing]) {
      final hitRing = ringRadii[_nextRing];
      final aligned = gapChecks[_nextRing]();
      _nextRing++;
      // (braces required by linter — loop body continues below)

      if (!aligned) {
        _triggerExplosion(hitRing);
        return;
      }
    }

    // All rings cleared
    if (_nextRing >= ringRadii.length && _state == BallState.flying) {
      _state = BallState.passed;
      onResult(false, ringRadii.last);
      removeFromParent();
    }
  }

  void _triggerExplosion(double radius) {
    _state = BallState.exploded;
    _explodeTimer = 0.55;
    final pos = _ballPos();
    for (int i = 0; i < 14; i++) {
      _sparks.add(_Spark(
        x: pos.x,
        y: pos.y,
        angle: _rng.nextDouble() * 2 * pi,
        speed: 80 + _rng.nextDouble() * 120,
        life: 1.0,
      ));
    }
    onResult(true, radius);
  }

  Vector2 _ballPos() {
    return origin +
        Vector2(
          cos(GameConstants.aimLaunchAngle),
          sin(GameConstants.aimLaunchAngle),
        ) *
            _dist;
  }

  @override
  void render(Canvas canvas) {
    if (_state == BallState.exploded) {
      for (final s in _sparks) {
        if (s.life <= 0) continue;
        final paint = Paint()
          ..color = color.withValues(alpha: s.life.clamp(0, 1) * 0.9)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(
            Offset(s.x, s.y), GameConstants.ballRadius * s.life * 0.7, paint);
      }
      return;
    }

    // Trail
    for (int i = 0; i < _trail.length; i++) {
      final t = _trail[i];
      if (t.life <= 0) continue;
      final frac = (i + 1) / _trail.length;
      final paint = Paint()
        ..color = color.withValues(alpha: t.life.clamp(0, 1) * frac * 0.5);
      canvas.drawCircle(
          Offset(t.x, t.y), GameConstants.ballRadius * frac * 0.7, paint);
    }

    // Ball
    final pos = _ballPos();
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(pos.x, pos.y), GameConstants.ballRadius * 1.8, glowPaint);

    final ballPaint = Paint()..color = color.withValues(alpha: 0.95);
    canvas.drawCircle(Offset(pos.x, pos.y), GameConstants.ballRadius, ballPaint);

    final highlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.6);
    canvas.drawCircle(
        Offset(pos.x - 2, pos.y - 2), GameConstants.ballRadius * 0.35, highlight);
  }
}

class _TrailDot {
  double x, y, life;
  _TrailDot({required this.x, required this.y, required this.life});
}

class _Spark {
  double x, y, angle, speed, life;
  _Spark(
      {required this.x,
      required this.y,
      required this.angle,
      required this.speed,
      required this.life});
}
