import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../models/air_hockey/ball.dart';
import '../../models/air_hockey/paddle.dart';
import '../settings_manager.dart';

class AirHockeyGame extends FlameGame with PanDetector, HasCollisionDetection {
  late AirBall ball;
  late Paddle p1;
  late Paddle p2;

  final ValueNotifier<int> p1Score = ValueNotifier(0);
  final ValueNotifier<int> p2Score = ValueNotifier(0);

  bool isVsBot = true;
  bool isGameOver = false;
  int? winner;

  final Function(int score, int maxScore)? onSoloGameFinished;
  bool _hasNotifiedSolo = false;

  // Score maximum pour Air Hockey (7 points pour gagner)
  static const int maxPossibleScore = 7;

  AirHockeyGame({this.onSoloGameFinished});

  @override
  Future<void> onLoad() async {
    add(ScreenHitbox());

    add(RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF000814),
    ));

    add(CircleComponent(
      position: size / 2,
      radius: 60,
      anchor: Anchor.center,
      paint: Paint()..color = Colors.white10..style = PaintingStyle.stroke..strokeWidth = 2,
    ));

    add(RectangleComponent(
      position: Vector2(0, size.y / 2 - 1),
      size: Vector2(size.x, 2),
      paint: Paint()..color = Colors.white10,
    ));

    _addGoalVisuals();
    _addScoreDisplays();

    ball = AirBall();
    p1 = Paddle(playerNumber: 1);
    p2 = Paddle(playerNumber: 2);

    add(ball);
    add(p1);
    add(p2);

    _resetPositions();
  }

  void _addGoalVisuals() {
    double goalWidth = size.x * 0.45;
    double goalX = (size.x - goalWidth) / 2;

    add(RectangleComponent(
      position: Vector2(goalX, 0),
      size: Vector2(goalWidth, 8),
      paint: Paint()..color = Colors.blueAccent.withOpacity(0.8),
    ));

    add(RectangleComponent(
      position: Vector2(goalX, size.y - 8),
      size: Vector2(goalWidth, 8),
      paint: Paint()..color = const Color(0xFFD4AF37).withOpacity(0.8),
    ));
  }

  void _addScoreDisplays() {
    add(TextComponent(
      text: '0',
      position: Vector2(size.x - 20, (size.y / 2) - 50),
      anchor: Anchor.topRight,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.blueAccent,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          fontFamily: 'Luckiest Guy',
        ),
      ),
    )..add(ScoreListener(p2Score)));

    add(TextComponent(
      text: '0',
      position: Vector2(size.x - 20, (size.y / 2) + 50),
      anchor: Anchor.bottomRight,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontSize: 48,
          fontWeight: FontWeight.bold,
          fontFamily: 'Luckiest Guy',
        ),
      ),
    )..add(ScoreListener(p1Score)));
  }

  void _resetPositions() {
    ball.reset();
    ball.position = size / 2;
    p1.position = Vector2(size.x / 2, size.y * 0.85);
    p2.position = Vector2(size.x / 2, size.y * 0.15);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (isGameOver) return;

    final touchPos = info.eventPosition.global;
    if (touchPos.y > size.y / 2) {
      p1.moveTo(touchPos);
    }
    if (!isVsBot && touchPos.y < size.y / 2) {
      p2.moveTo(touchPos);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;
    if (isVsBot) _updateBot(dt);
  }

  void _updateBot(double dt) {
    double targetX = ball.position.x;
    double targetY;
    if (ball.position.y < size.y / 2) {
      targetY = (ball.position.y - 20).clamp(30, size.y / 2 - 40);
    } else {
      targetX = (ball.position.x * 0.5 + size.x / 2 * 0.5);
      targetY = size.y * 0.15;
    }
    Vector2 direction = Vector2(targetX, targetY) - p2.position;
    if (direction.length > 2) {
      p2.position += direction.normalized() * 550 * dt;
      p2.moveTo(p2.position);
    }
  }

  void onGoal(int scoringPlayer) {
    if (isGameOver) return;
    if (scoringPlayer == 1) p1Score.value++; else p2Score.value++;
    settingsManager.playClick();
    _checkWinCondition();
    if (!isGameOver) _resetPositions();
  }

  void _checkWinCondition() {
    int s1 = p1Score.value;
    int s2 = p2Score.value;
    if ((s1 >= 7 || s2 >= 7) && (s1 - s2).abs() >= 2) {
      _endGame(s1 > s2 ? 1 : 2);
    }
  }

  void _endGame(int winnerNum) {
    if (isGameOver) return;
    isGameOver = true;
    winner = winnerNum;
    pauseEngine();

    // Notifier le mode solo
    if (onSoloGameFinished != null && !_hasNotifiedSolo) {
      _hasNotifiedSolo = true;
      onSoloGameFinished!(p1Score.value, maxPossibleScore);
    }

    overlays.add('GameOver');
    if (winnerNum == 1) settingsManager.playVictory(); else settingsManager.playDefeat();
  }

  void restart() {
    p1Score.value = 0;
    p2Score.value = 0;
    isGameOver = false;
    winner = null;
    _hasNotifiedSolo = false;
    _resetPositions();
    overlays.remove('GameOver');
    resumeEngine();
  }
}

class ScoreListener extends Component with HasGameRef<AirHockeyGame> {
  final ValueNotifier<int> score;
  ScoreListener(this.score);

  @override
  void update(double dt) {
    (parent as TextComponent).text = score.value.toString();
  }
}