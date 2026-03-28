import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../services/meteor_game/meteor_game.dart';
import 'ship.dart';

class Meteor extends PositionComponent with HasGameRef<MeteorGame>, CollisionCallbacks {
  late double speed;
  late int maxLife;
  late int currentLife;
  late double radius;

  Meteor() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final rand = Random();
    double typeRand = rand.nextDouble();

    if (typeRand > 0.85) {
      radius = 40;
      maxLife = 6;
      speed = 100 + rand.nextDouble() * 50;
    } else if (typeRand > 0.5) {
      radius = 25;
      maxLife = 3;
      speed = 150 + rand.nextDouble() * 80;
    } else {
      radius = 15;
      maxLife = 1;
      speed = 200 + rand.nextDouble() * 100;
    }

    currentLife = maxLife;
    size = Vector2(radius * 2, radius * 2);
    position = Vector2(rand.nextDouble() * gameRef.size.x, -radius);
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;

    if (position.y > gameRef.size.y + radius) {
      int reward = maxLife == 6 ? 4 : (maxLife == 3 ? 2 : 1);
      gameRef.scoreNotifier.value += reward;
      gameRef.ammoNotifier.value += reward;
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    double healthPercent = currentLife / maxLife;
    final paint = Paint()..color = Color.lerp(Colors.redAccent, Colors.grey[600]!, healthPercent)!;
    canvas.drawCircle(Offset(radius, radius), radius, paint);
    canvas.drawCircle(Offset(radius * 0.5, radius * 0.5), radius * 0.2, Paint()..color = Colors.black26);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Ship) {
      gameRef.gameOver();
    }
  }

  void hit() {
    currentLife--;
    gameRef.createExplosion(position, Colors.orangeAccent, count: 5, radius: 2.0);
    
    if (currentLife <= 0) {
      int reward = maxLife == 6 ? 12 : (maxLife == 3 ? 6 : 2);
      gameRef.scoreNotifier.value += reward;
      gameRef.createExplosion(position, Colors.grey, count: 25, radius: 4.0);
      removeFromParent();
    }
  }
}
