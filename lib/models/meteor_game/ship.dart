import 'dart:async' as async;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../services/meteor_game/meteor_game.dart';

class Ship extends PositionComponent with HasGameRef<MeteorGame>, CollisionCallbacks {
  double currentVelocityX = 0;
  double rawTiltX = 0;
  async.StreamSubscription? _subscription;

  Ship() : super(size: Vector2(50, 50), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    _subscription = accelerometerEvents.listen((event) {
      rawTiltX = -event.x; 
    });
    position = Vector2(gameRef.size.x / 2, gameRef.size.y - 100);
  }

  @override
  void update(double dt) {
    super.update(dt);

    double targetSpeed = 0;
    if (rawTiltX.abs() > 1.2) {
      targetSpeed = rawTiltX * 180;
    }

    double lerpFactor = targetSpeed == 0 ? 0.1 : 0.05;
    currentVelocityX = currentVelocityX + (targetSpeed - currentVelocityX) * lerpFactor;

    position.x += currentVelocityX * dt;
    position.x = position.x.clamp(size.x / 2, gameRef.size.x - size.x / 2);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFD4AF37);
    final path = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(0, size.y)
      ..lineTo(size.x, size.y)
      ..close();
    
    canvas.drawShadow(path, Colors.orangeAccent, 5, true);
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(size.x / 2, size.y * 0.6), 8, Paint()..color = Colors.black45);
  }

  @override
  void onRemove() {
    _subscription?.cancel();
    super.onRemove();
  }
}
