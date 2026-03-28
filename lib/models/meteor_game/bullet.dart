import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../services/meteor_game/meteor_game.dart';
import 'meteor.dart';

class Bullet extends PositionComponent with HasGameRef<MeteorGame>, CollisionCallbacks {
  Bullet(Vector2 pos) : super(position: pos, size: Vector2(8, 20), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= 700 * dt;
    if (position.y < -20) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(RRect.fromRectAndRadius(size.toRect(), const Radius.circular(4)), Paint()..color = Colors.cyanAccent);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Meteor) {
      other.hit();
      removeFromParent();
    }
  }
}
