import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../services/car_game/car_flame_game.dart';
import 'obstacle_type.dart';
import 'player_car.dart';

class ObstacleCar extends PositionComponent with HasGameRef<CarFlameGame>, CollisionCallbacks {
  final ObstacleType type;
  final int lane;
  bool overtaken = false;

  ObstacleCar({required this.type, required this.lane, required double initialY}) 
    : super(position: Vector2(0, initialY), anchor: Anchor.center) {
    size = type == ObstacleType.truck ? Vector2(50, 200) : Vector2(50, 80);
  }

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    double laneWidth = gameRef.size.x / 4;
    position.x = laneWidth * lane + (laneWidth / 2);
  }

  @override
  void update(double dt) {
    super.update(dt);
    double speedMultiplier = type == ObstacleType.f1 ? 2.0 : 1.2;
    position.y += gameRef.gameSpeed * speedMultiplier;

    if (position.y > gameRef.size.y + 100) {
      if (!overtaken) {
        gameRef.score += (type == ObstacleType.f1 ? 2 : 1);
        overtaken = true;
      }
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.rotate(pi); // Inversion pour faire face au joueur
    
    if (type == ObstacleType.truck) _renderTruck(canvas);
    else if (type == ObstacleType.f1) _renderF1(canvas);
    else _renderSedan(canvas);
    
    canvas.restore();
  }

  void _renderSedan(Canvas canvas) {
    final paint = Paint()..color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(size.toRect(), const Radius.circular(12)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(8, 10, 34, 12), const Radius.circular(4)), Paint()..color = Colors.black87);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(6, 5, 8, 4), const Radius.circular(2)), Paint()..color = Colors.redAccent);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(36, 5, 8, 4), const Radius.circular(2)), Paint()..color = Colors.redAccent);
  }

  void _renderF1(Canvas canvas) {
    final paint = Paint()..color = Colors.greenAccent[700]!;
    canvas.drawRRect(RRect.fromRectAndRadius(size.toRect(), const Radius.circular(10)), paint);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 50, 10), Paint()..color = Colors.black);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(17, 25, 15, 30), const Radius.circular(10)), Paint()..color = Colors.black87);
  }

  void _renderTruck(Canvas canvas) {
    // Cabine
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 50, 50), const Radius.circular(8)), Paint()..color = Colors.blueGrey[800]!);
    // Liaison
    canvas.drawRect(const Rect.fromLTWH(19, 50, 12, 10), Paint()..color = Colors.black);
    // Remorque
    final trailerPaint = Paint()..color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(1, 60, 48, 140), const Radius.circular(4)), trailerPaint);
    final textPainter = TextPainter(text: const TextSpan(text: "DANGER", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 10)), textDirection: TextDirection.ltr)..layout();
    canvas.save();
    canvas.translate(25, 130);
    canvas.rotate(pi / 2);
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerCar) {
      if (other.isJumping && type != ObstacleType.truck) return;
      gameRef.gameOver();
    }
  }
}
