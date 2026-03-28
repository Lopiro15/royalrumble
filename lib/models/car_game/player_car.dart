import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../services/car_game/car_flame_game.dart';
import '../../services/settings_manager.dart';

class PlayerCar extends PositionComponent with HasGameRef<CarFlameGame>, CollisionCallbacks {
  int lane = 1;
  bool isJumping = false;
  double jumpTime = 0;
  late RectangleHitbox hitbox;

  PlayerCar() : super(size: Vector2(50, 80), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    hitbox = RectangleHitbox();
    add(hitbox);
    _updatePosition();
  }

  void changeLane(int direction) {
    lane = (lane + direction).clamp(0, 3);
    settingsManager.playClick();
  }

  void jump() {
    if (isJumping) return;
    isJumping = true;
    jumpTime = 0;
    settingsManager.playClick();
  }

  void reset() {
    lane = 1;
    isJumping = false;
    scale = Vector2.all(1.0);
    _updatePosition();
  }

  void _updatePosition() {
    double laneWidth = gameRef.size.x / 4;
    position = Vector2(laneWidth * lane + (laneWidth / 2), gameRef.size.y - 150);
  }

  @override
  void update(double dt) {
    super.update(dt);
    double targetX = (gameRef.size.x / 4) * lane + (gameRef.size.x / 8);
    position.x += (targetX - position.x) * 15 * dt;

    if (isJumping) {
      jumpTime += dt;
      double scaleFactor = 1.0 + sin(jumpTime * pi / 0.6) * 0.4;
      scale = Vector2.all(scaleFactor);
      if (jumpTime >= 0.6) {
        isJumping = false;
        scale = Vector2.all(1.0);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFD4AF37);
    final rrect = RRect.fromRectAndRadius(size.toRect(), const Radius.circular(12));
    canvas.drawRRect(rrect.shift(Offset(0, isJumping ? 15 : 4)), Paint()..color = Colors.black.withOpacity(isJumping ? 0.4 : 0.6));
    canvas.drawRRect(rrect, paint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(8, 10, 34, 12), const Radius.circular(4)), Paint()..color = Colors.black87);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(10, 45, 30, 20), const Radius.circular(4)), Paint()..color = Colors.black54);
    final lightPaint = Paint()..color = Colors.yellowAccent;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(6, 5, 8, 4), const Radius.circular(2)), lightPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(36, 5, 8, 4), const Radius.circular(2)), lightPaint);
  }
}
