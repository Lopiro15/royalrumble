import 'dart:async' as async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../models/hanoi_game/disk_component.dart';
import '../settings_manager.dart';

class HanoiFlameGame extends FlameGame with DragCallbacks {
  late int numDisks;
  final List<List<DiskComponent>> pegs = [[], [], []];
  final List<Vector2> pegPositions = [];
  final ValueNotifier<int> moves = ValueNotifier(0);
  final ValueNotifier<int> seconds = ValueNotifier(0);
  async.Timer? timer;
  bool isWon = false;

  @override
  Future<void> onLoad() async {
    numDisks = Random().nextInt(3) + 4;
    
    add(RectangleComponent(
      size: size,
      paint: Paint()..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF002147), Color(0xFF001A33)],
      ).createShader(size.toRect()),
    ));

    double spacing = size.x / 4;
    for (int i = 1; i <= 3; i++) {
      pegPositions.add(Vector2(spacing * i, size.y * 0.7));
    }

    resetGame();
  }

  void resetGame() {
    for (var p in pegs) {
      for (var d in p) {
        d.removeFromParent();
      }
      p.clear();
    }
    
    moves.value = 0;
    seconds.value = 0;
    isWon = false;
    overlays.remove('Victory');
    timer?.cancel();
    timer = null;

    final colors = [Colors.redAccent, Colors.blueAccent, Colors.greenAccent, Colors.orangeAccent, Colors.purpleAccent, Colors.tealAccent];
    List<Color> shuffled = List.from(colors)..shuffle();

    for (int i = numDisks; i >= 1; i--) {
      final disk = DiskComponent(
        sizeIndex: i,
        color: shuffled[i % shuffled.length],
        peg: 0,
      );
      pegs[0].add(disk);
      add(disk);
    }
    _repositionDisks(0);
  }

  void startTimer() {
    if (timer != null) return;
    timer = async.Timer.periodic(const Duration(seconds: 1), (t) {
      if (!isWon) seconds.value++;
    });
  }

  void _repositionDisks(int pegIndex) {
    for (int i = 0; i < pegs[pegIndex].length; i++) {
      pegs[pegIndex][i].position = Vector2(
        pegPositions[pegIndex].x,
        pegPositions[pegIndex].y - (i * 28) - 15,
      );
    }
  }

  bool canMoveTo(int toPeg, int diskSize) {
    if (pegs[toPeg].isEmpty) return true;
    return pegs[toPeg].last.sizeIndex > diskSize;
  }

  void moveDisk(DiskComponent disk, int toPeg) {
    int fromPeg = disk.currentPeg;
    if (fromPeg != toPeg && canMoveTo(toPeg, disk.sizeIndex)) {
      startTimer();
      settingsManager.playClick();
      pegs[fromPeg].remove(disk);
      pegs[toPeg].add(disk);
      disk.currentPeg = toPeg;
      moves.value++;
      _checkWin();
    }
    _repositionDisks(fromPeg);
    _repositionDisks(toPeg);
  }

  void _checkWin() {
    if (pegs[2].length == numDisks) {
      isWon = true;
      timer?.cancel();
      settingsManager.playWin();
      overlays.add('Victory');
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = const Color(0xFFD4AF37).withOpacity(0.3);
    for (var pos in pegPositions) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: pos.toOffset() - const Offset(0, 110), width: 10, height: 220), const Radius.circular(5)), paint);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: pos.toOffset(), width: 90, height: 8), const Radius.circular(4)), paint);
    }
  }
}
