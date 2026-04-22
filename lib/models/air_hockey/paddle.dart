import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../services/air_hockey/air_hockey_game.dart';

class Paddle extends CircleComponent with HasGameRef<AirHockeyGame> {
  final int playerNumber; // 1 for bottom, 2 for top
  static const double radiusVal = 30.0;

  Paddle({required this.playerNumber}) : super(
    radius: radiusVal,
    anchor: Anchor.center,
    paint: Paint()..color = playerNumber == 1 ? const Color(0xFFD4AF37) : Colors.blueAccent,
  );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  void moveTo(Vector2 newPos) {
    if (gameRef.isGameOver) return;

    // Constrain within screen width
    double clampedX = newPos.x.clamp(radiusVal, gameRef.size.x - radiusVal);
    
    // Constrain within camp Y bounds
    double minY, maxY;
    if (playerNumber == 1) {
      // Bottom player camp
      minY = gameRef.size.y / 2 + radiusVal;
      maxY = gameRef.size.y - radiusVal;
    } else {
      // Top player/bot camp
      minY = radiusVal;
      maxY = gameRef.size.y / 2 - radiusVal;
    }

    position.x = clampedX;
    position.y = newPos.y.clamp(minY, maxY);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Visual details
    canvas.drawCircle(Offset(radius, radius), radius * 0.7, Paint()..color = Colors.black26);
    canvas.drawCircle(Offset(radius, radius), radius * 0.4, Paint()..color = Colors.white24);
  }
}
