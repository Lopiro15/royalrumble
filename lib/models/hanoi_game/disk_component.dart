import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../services/hanoi_game/hanoi_flame_game.dart';

class DiskComponent extends PositionComponent with DragCallbacks, HasGameRef<HanoiFlameGame> {
  final int sizeIndex;
  final Color color;
  int currentPeg;
  bool isDragging = false;
  late Vector2 dragStartPos;

  DiskComponent({required this.sizeIndex, required this.color, required int peg})
      : currentPeg = peg,
        super(size: Vector2(50.0 + sizeIndex * 15, 25), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(size.toRect().shift(const Offset(0, 2)), const Radius.circular(12)), Paint()..color = Colors.black38);
    canvas.drawRRect(RRect.fromRectAndRadius(size.toRect(), const Radius.circular(12)), paint);
    
    final tp = TextPainter(
      text: TextSpan(text: '$sizeIndex', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.x / 2 - tp.width / 2, size.y / 2 - tp.height / 2));
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (gameRef.isWon || gameRef.pegs[currentPeg].last != this) return;
    isDragging = true;
    dragStartPos = position.clone();
    priority = 100;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!isDragging) return;
    position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (!isDragging) return;
    isDragging = false;
    priority = 0;

    int closestPeg = -1;
    double minDist = 100;
    for (int i = 0; i < 3; i++) {
      double d = position.distanceTo(gameRef.pegPositions[i]);
      if (d < minDist) {
        minDist = d;
        closestPeg = i;
      }
    }

    if (closestPeg != -1) {
      gameRef.moveDisk(this, closestPeg);
    } else {
      position = dragStartPos;
    }
  }
}
