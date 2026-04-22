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
  static const double jumpDuration = 0.6;

  PlayerCar() : super(size: Vector2(50, 80), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(size: size * 0.8)); // Hitbox un peu plus permissive
    _updateInitialPosition();
  }

  void _updateInitialPosition() {
    double laneWidth = gameRef.size.x / 4;
    position = Vector2(laneWidth * lane + (laneWidth / 2), gameRef.size.y - 180);
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
    _updateInitialPosition();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Déplacement latéral fluide (Lerp) pour correspondre à l'AnimatedPositioned
    double targetX = (gameRef.size.x / 4) * lane + (gameRef.size.x / 8);
    position.x += (targetX - position.x) * 15 * dt;

    // Logique de saut exacte
    if (isJumping) {
      jumpTime += dt;
      // Courbe sinusoïdale pour le scale (1.0 -> 1.4 -> 1.0)
      double progress = jumpTime / jumpDuration;
      if (progress <= 1.0) {
        double scaleFactor = 1.0 + sin(progress * pi) * 0.4;
        scale = Vector2.all(scaleFactor);
      } else {
        isJumping = false;
        scale = Vector2.all(1.0);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFD4AF37);
    final rrect = RRect.fromRectAndRadius(size.toRect(), const Radius.circular(12));
    
    // Ombre dynamique
    canvas.drawRRect(rrect.shift(Offset(0, isJumping ? 15 : 4)), Paint()..color = Colors.black.withOpacity(isJumping ? 0.3 : 0.5));
    
    // Carrosserie
    canvas.drawRRect(rrect, paint);
    
    // Détails (Vitres et Phares de ta version originale)
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(8, 10, 34, 12), const Radius.circular(4)), Paint()..color = Colors.black87);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(10, 45, 30, 20), const Radius.circular(4)), Paint()..color = Colors.black54);

    final lightPaint = Paint()..color = Colors.yellowAccent;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(6, 5, 8, 4), const Radius.circular(2)), lightPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(36, 5, 8, 4), const Radius.circular(2)), lightPaint);
  }
}
