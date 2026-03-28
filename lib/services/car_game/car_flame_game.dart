import 'dart:async' as async;
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../models/car_game/obstacle_car.dart';
import '../../models/car_game/obstacle_type.dart';
import '../../models/car_game/player_car.dart';
import '../settings_manager.dart';

class CarFlameGame extends FlameGame with PanDetector, TapCallbacks, HasCollisionDetection {
  late PlayerCar player;
  double roadOffset = 0;
  double gameSpeed = 8.0;
  int score = 0;
  int secondsElapsed = 0;
  async.Timer? chronoTimer;
  bool isGameOver = false;
  final Random random = Random();
  double lastSpawnY = 0;

  @override
  Future<void> onLoad() async {
    player = PlayerCar();
    add(player);

    chronoTimer = async.Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isGameOver) {
        secondsElapsed++;
        if (gameSpeed < 25) gameSpeed += 0.3;
      }
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    roadOffset += gameSpeed;
    if (roadOffset > 100) roadOffset = 0;

    if (children.whereType<ObstacleCar>().isEmpty || (lastSpawnY > 500 && random.nextDouble() < 0.06)) {
      _spawnWave();
    }
    
    final obstacles = children.whereType<ObstacleCar>();
    if (obstacles.isNotEmpty) {
      lastSpawnY = obstacles.map((e) => e.position.y).reduce(max);
    }
  }

  void _spawnWave() {
    double spawnChance = random.nextDouble();
    int count = spawnChance < 0.4 ? 1 : (spawnChance < 0.8 ? 2 : 3);
    List<int> availableLanes = [0, 1, 2, 3]..shuffle();
    double formationRand = random.nextDouble();
    double baseY = -350.0;

    for (int i = 0; i < count; i++) {
      int lane = availableLanes[i];
      double randType = random.nextDouble();
      ObstacleType type = randType > 0.92 ? ObstacleType.f1 : (randType > 0.7 ? ObstacleType.truck : ObstacleType.sedan);

      double yOffset;
      if (formationRand < 0.35) yOffset = random.nextDouble() * 30.0;
      else if (formationRand < 0.75) yOffset = i * (120.0 + random.nextDouble() * 50.0);
      else yOffset = i * (250.0 + random.nextDouble() * 150.0);

      add(ObstacleCar(type: type, lane: lane, initialY: baseY - yOffset));
    }
    lastSpawnY = baseY;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF222222);
    canvas.drawRect(size.toRect(), paint);

    final linePaint = Paint()..color = Colors.white24..strokeWidth = 2;
    double laneWidth = size.x / 4;

    for (int i = 1; i < 4; i++) {
      double x = laneWidth * i;
      double dashHeight = 40;
      double dashSpace = 20;
      double startY = roadOffset % (dashHeight + dashSpace);
      while (startY < size.y) {
        canvas.drawLine(Offset(x, startY), Offset(x, startY + dashHeight), linePaint);
        startY += dashHeight + dashSpace;
      }
      double backY = roadOffset % (dashHeight + dashSpace) - (dashHeight + dashSpace);
      while (backY > -dashHeight) {
        canvas.drawLine(Offset(x, backY), Offset(x, backY + dashHeight), linePaint);
        backY -= (dashHeight + dashSpace);
      }
    }
    super.render(canvas);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    if (isGameOver) return;
    if (info.velocity.x < -300) player.changeLane(-1);
    else if (info.velocity.x > 300) player.changeLane(1);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) return;
    player.jump();
  }

  void gameOver() {
    isGameOver = true;
    pauseEngine();
    overlays.add('GameOver');
    settingsManager.stopMusic();
  }

  void restart() {
    isGameOver = false;
    score = 0;
    secondsElapsed = 0;
    gameSpeed = 8.0;
    children.whereType<ObstacleCar>().forEach((o) => o.removeFromParent());
    player.reset();
    overlays.remove('GameOver');
    resumeEngine();
    settingsManager.startMusic();
  }
}
