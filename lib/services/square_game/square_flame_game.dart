import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../settings_manager.dart';

enum Player { none, p1, p2 }

class SquareFlameGame extends FlameGame with TapCallbacks {
  static const int gridSize = 7;
  late double cellSpacing;
  late double startX;
  late double startY;

  final List<List<Player>> dotOwners = List.generate(gridSize, (_) => List.filled(gridSize, Player.none));
  final List<List<Player>> squareOwners = List.generate(gridSize - 1, (_) => List.filled(gridSize - 1, Player.none));

  Player currentPlayer = Player.p1;
  final ValueNotifier<int> p1Score = ValueNotifier(0);
  final ValueNotifier<int> p2Score = ValueNotifier(0);
  final ValueNotifier<Player> turnNotifier = ValueNotifier(Player.p1);

  bool isVsBot = true;
  bool isVersusMode = false;
  bool isMyTurn = true;
  bool isGameOver = false;

  final Function(int score, int maxScore)? onSoloGameFinished;
  bool _hasNotifiedSolo = false;

  void Function(int score, bool isDead)? onVersusFinished;
  void Function(int row, int col)? onMoveMade;

  static const int maxPossibleScore = 36;

  SquareFlameGame({this.onSoloGameFinished});

  @override
  Future<void> onLoad() async {
    cellSpacing = (size.x - 60) / (gridSize - 1);
    startX = 30;
    startY = (size.y - (cellSpacing * (gridSize - 1))) / 2;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFF000814));

    final paintP1 = Paint()..color = const Color(0xFFD4AF37);
    final paintP2 = Paint()..color = Colors.blueAccent;
    final paintNone = Paint()..color = Colors.white10;

    for (int r = 0; r < gridSize - 1; r++) {
      for (int c = 0; c < gridSize - 1; c++) {
        if (squareOwners[r][c] != Player.none) {
          final rect = Rect.fromLTWH(startX + c * cellSpacing, startY + r * cellSpacing, cellSpacing, cellSpacing);
          canvas.drawRect(rect.deflate(2), Paint()..color = (squareOwners[r][c] == Player.p1 ? paintP1.color : paintP2.color).withOpacity(0.3));
        }
      }
    }

    final linePaint = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 1;
    for (int i = 0; i < gridSize; i++) {
      canvas.drawLine(Offset(startX, startY + i * cellSpacing), Offset(startX + (gridSize-1) * cellSpacing, startY + i * cellSpacing), linePaint);
      canvas.drawLine(Offset(startX + i * cellSpacing, startY), Offset(startX + i * cellSpacing, startY + (gridSize-1) * cellSpacing), linePaint);
    }

    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        final pos = Offset(startX + c * cellSpacing, startY + r * cellSpacing);
        Paint dotPaint = paintNone;
        if (dotOwners[r][c] == Player.p1) dotPaint = paintP1;
        if (dotOwners[r][c] == Player.p2) dotPaint = paintP2;
        canvas.drawCircle(pos, dotOwners[r][c] == Player.none ? 4 : 8, dotPaint);
        if (dotOwners[r][c] != Player.none) {
          canvas.drawCircle(pos, 10, Paint()..color = dotPaint.color.withOpacity(0.2)..style = PaintingStyle.stroke..strokeWidth = 2);
        }
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) return;
    if (isVersusMode && !isMyTurn) return;
    if (isVsBot && currentPlayer == Player.p2) return;

    final tapPos = event.localPosition;
    _handleTap(tapPos);
  }

  void _handleTap(Vector2 tapPos) {
    int? bestR, bestC;
    double minDist = 30;

    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        final dotPos = Vector2(startX + c * cellSpacing, startY + r * cellSpacing);
        double d = tapPos.distanceTo(dotPos);
        if (d < minDist) {
          minDist = d;
          bestR = r;
          bestC = c;
        }
      }
    }

    if (bestR != null && bestC != null && dotOwners[bestR][bestC] == Player.none) {
      // Je joue mon coup (toujours en p1 = Or)
      dotOwners[bestR][bestC] = Player.p1;
      settingsManager.playClick();
      _checkNewSquares(bestR, bestC);

      if (_isGridFull()) {
        _endGame();
      } else {
        // En mode Versus, notifier l'adversaire et attendre
        if (isVersusMode) {
          isMyTurn = false;
          currentPlayer = Player.p2;
          turnNotifier.value = Player.p2;
          onMoveMade?.call(bestR, bestC);
        } else {
          currentPlayer = (currentPlayer == Player.p1) ? Player.p2 : Player.p1;
          turnNotifier.value = currentPlayer;
          if (isVsBot && currentPlayer == Player.p2) {
            Future.delayed(const Duration(milliseconds: 600), _botMove);
          }
        }
      }
    }
  }

  /// Reçoit le coup de l'adversaire (il joue en p2 = Bleu)
  void receiveOpponentMove(int row, int col) {
    if (isGameOver) return;

    // L'adversaire place un point Bleu (p2)
    dotOwners[row][col] = Player.p2;
    settingsManager.playClick();
    _checkNewSquares(row, col);

    if (_isGridFull()) {
      _endGame();
    } else {
      // C'est mon tour maintenant, je joue en Or (p1)
      isMyTurn = true;
      currentPlayer = Player.p1;
      turnNotifier.value = Player.p1;
    }
  }

  void _checkNewSquares(int r, int c) {
    if (r > 0 && c > 0) _evaluateSquare(r - 1, c - 1);
    if (r > 0 && c < gridSize - 1) _evaluateSquare(r - 1, c);
    if (r < gridSize - 1 && c > 0) _evaluateSquare(r, c - 1);
    if (r < gridSize - 1 && c < gridSize - 1) _evaluateSquare(r, c);
  }

  void _evaluateSquare(int r, int c) {
    if (squareOwners[r][c] != Player.none) return;
    Player a = dotOwners[r][c];
    Player b = dotOwners[r][c+1];
    Player c2 = dotOwners[r+1][c];
    Player d = dotOwners[r+1][c+1];
    if (a != Player.none && a == b && a == c2 && a == d) {
      squareOwners[r][c] = a;
      if (a == Player.p1) p1Score.value++; else p2Score.value++;
    }
  }

  void _botMove() {
    if (isGameOver) return;
    List<Point<int>> available = [];
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (dotOwners[r][c] == Player.none) available.add(Point(r, c));
      }
    }
    if (available.isNotEmpty) {
      final move = available[Random().nextInt(available.length)];
      dotOwners[move.x][move.y] = Player.p2;
      _checkNewSquares(move.x, move.y);
      if (!_isGridFull()) {
        currentPlayer = Player.p1;
        turnNotifier.value = Player.p1;
      } else {
        _endGame();
      }
    }
  }

  bool _isGridFull() {
    for (var row in dotOwners) {
      if (row.contains(Player.none)) return false;
    }
    return true;
  }

  void _endGame() {
    if (isGameOver) return;
    isGameOver = true;

    if (p1Score.value > p2Score.value) {
      settingsManager.playVictory();
    } else {
      settingsManager.playDefeat();
    }

    if (onSoloGameFinished != null && !_hasNotifiedSolo) {
      _hasNotifiedSolo = true;
      onSoloGameFinished!(p1Score.value, maxPossibleScore);
    }

    onVersusFinished?.call(p1Score.value, true);
    overlays.add('GameOver');
  }

  void restart() {
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        dotOwners[r][c] = Player.none;
        if (r < gridSize - 1 && c < gridSize - 1) squareOwners[r][c] = Player.none;
      }
    }
    p1Score.value = 0;
    p2Score.value = 0;
    currentPlayer = Player.p1;
    turnNotifier.value = Player.p1;
    isGameOver = false;
    _hasNotifiedSolo = false;
    isMyTurn = isVersusMode ? true : true; // L'invité attend, l'hôte commence
    overlays.remove('GameOver');
    resumeEngine();
  }
}