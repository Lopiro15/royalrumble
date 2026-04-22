import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import '../../services/air_hockey/air_hockey_game.dart';
import '../../services/settings_manager.dart';
import 'paddle.dart';

class AirBall extends CircleComponent with HasGameRef<AirHockeyGame>, CollisionCallbacks {
  Vector2 velocity = Vector2.zero();
  static const double radiusVal = 12.0;

  AirBall() : super(
    radius: radiusVal,
    anchor: Anchor.center,
    paint: Paint()..color = Colors.white,
  );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  void reset() {
    position = gameRef.size / 2;
    velocity = Vector2.zero();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.isGameOver) return;

    const int steps = 4;
    final stepDt = dt / steps;

    for (int i = 0; i < steps; i++) {
      position += velocity * stepDt;
      _checkBorders();
    }

    velocity *= 0.998;
  }

  void _checkBorders() {
    final fieldTop = 0.0;
    final fieldBottom = gameRef.size.y;

    if (position.x < radiusVal || position.x > gameRef.size.x - radiusVal) {
      velocity.x *= -1;
      position.x = position.x.clamp(radiusVal, gameRef.size.x - radiusVal);
      settingsManager.playClick();
    }

    double goalWidth = gameRef.size.x * 0.45;
    double goalStart = (gameRef.size.x - goalWidth) / 2;
    double goalEnd = goalStart + goalWidth;

    if (position.y < fieldTop + radiusVal) {
      if (position.x > goalStart && position.x < goalEnd) {
        _triggerGoalEffect(Colors.blueAccent);
        gameRef.onGoal(1);
      } else {
        velocity.y *= -1;
        position.y = fieldTop + radiusVal;
        settingsManager.playClick();
      }
    } else if (position.y > fieldBottom - radiusVal) {
      if (position.x > goalStart && position.x < goalEnd) {
        _triggerGoalEffect(const Color(0xFFD4AF37));
        gameRef.onGoal(2);
      } else {
        velocity.y *= -1;
        position.y = fieldBottom - radiusVal;
        settingsManager.playClick();
      }
    }
  }

  void _triggerGoalEffect(Color color) {
    gameRef.add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 30,
          lifespan: 1.0,
          generator: (i) => AcceleratedParticle(
            speed: Vector2(
              (Random().nextDouble() - 0.5) * 600,
              (Random().nextDouble() - 0.5) * 600,
            ),
            position: position.clone(),
            child: CircleParticle(
              radius: 2 + Random().nextDouble() * 4,
              paint: Paint()
                ..color = color.withOpacity(0.8)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
            ),
          ),
        ),
      )
    );
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Paddle) {
      settingsManager.playClick();
      Vector2 impact = (position - other.position).normalized();
      double speed = (velocity.length + 500).clamp(450, 1100);
      velocity = impact * speed;

      gameRef.add(
        ParticleSystemComponent(
          particle: Particle.generate(
            count: 8,
            lifespan: 0.3,
            generator: (i) => AcceleratedParticle(
              speed: impact * 300 + Vector2(Random().nextDouble() - 0.5, Random().nextDouble() - 0.5) * 100,
              position: position.clone(),
              child: CircleParticle(radius: 1.5, paint: Paint()..color = Colors.white70),
            ),
          ),
        )
      );
    }
  }

  @override
  void render(Canvas canvas) {
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(radius, radius), radius + 2, glowPaint);
    super.render(canvas);
  }
}
