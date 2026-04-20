import 'dart:math';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../settings_manager.dart';

enum Player { none, p1, p2 }

class SquareFlameGame extends FlameGame with TapCallbacks {
  static const int gridSize = 7; // 7x7 points -> 6x6 carrés
  late double cellSpacing;
  late double startX;
  late double startY;

  // État du jeu
  final List<List<Player>> dotOwners = List.generate(gridSize, (_) => List.filled(gridSize, Player.none));
  final List<List<Player>> squareOwners = List.generate(gridSize - 1, (_) => List.filled(gridSize - 1, Player.none));
  
  Player currentPlayer = Player.p1;
  final ValueNotifier<int> p1Score = ValueNotifier(0);
  final ValueNotifier<int> p2Score = ValueNotifier(0);
  final ValueNotifier<Player> turnNotifier = ValueNotifier(Player.p1);
  
  bool isVsBot = true;
  bool isGameOver = false;

  @override
  Future<void> onLoad() async {
    cellSpacing = (size.x - 60) / (gridSize - 1);
    startX = 30;
    startY = (size.y - (cellSpacing * (gridSize - 1))) / 2;
  }

  @override
  void render(Canvas canvas) {
    // Fond
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFF000814));

    final paintP1 = Paint()..color = const Color(0xFFD4AF37); // Or
    final paintP2 = Paint()..color = Colors.blueAccent;
    final paintNone = Paint()..color = Colors.white10;

    // 1. Dessiner les zones capturées
    for (int r = 0; r < gridSize - 1; r++) {
      for (int c = 0; c < gridSize - 1; c++) {
        if (squareOwners[r][c] != Player.none) {
          final rect = Rect.fromLTWH(
            startX + c * cellSpacing,
            startY + r * cellSpacing,
            cellSpacing,
            cellSpacing,
          );
          canvas.drawRect(
            rect.deflate(2),
            Paint()..color = (squareOwners[r][c] == Player.p1 ? paintP1.color : paintP2.color).withOpacity(0.3),
          );
        }
      }
    }

    // 2. Dessiner la grille (lignes discrètes)
    final linePaint = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 1;
    for (int i = 0; i < gridSize; i++) {
      canvas.drawLine(Offset(startX, startY + i * cellSpacing), Offset(startX + (gridSize-1) * cellSpacing, startY + i * cellSpacing), linePaint);
      canvas.drawLine(Offset(startX + i * cellSpacing, startY), Offset(startX + i * cellSpacing, startY + (gridSize-1) * cellSpacing), linePaint);
    }

    // 3. Dessiner les points
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
    if (isGameOver || (isVsBot && currentPlayer == Player.p2)) return;

    final tapPos = event.localPosition;
    _handleTap(tapPos);
  }

  void _handleTap(Vector2 tapPos) {
    // Trouver le point le plus proche
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
      _makeMove(bestR, bestC);
    }
  }

  void _makeMove(int r, int c) {
    dotOwners[r][c] = currentPlayer;
    settingsManager.playClick();
    _checkNewSquares(r, c);
    
    if (_isGridFull()) {
      _endGame();
    } else {
      currentPlayer = (currentPlayer == Player.p1) ? Player.p2 : Player.p1;
      turnNotifier.value = currentPlayer;
      
      if (isVsBot && currentPlayer == Player.p2) {
        Future.delayed(const Duration(milliseconds: 600), _botMove);
      }
    }
  }

  void _checkNewSquares(int r, int c) {
    // Un point peut compléter jusqu'à 4 carrés
    // Carré en haut à gauche du point
    if (r > 0 && c > 0) _evaluateSquare(r - 1, c - 1);
    // Carré en haut à droite
    if (r > 0 && c < gridSize - 1) _evaluateSquare(r - 1, c);
    // Carré en bas à gauche
    if (r < gridSize - 1 && c > 0) _evaluateSquare(r, c - 1);
    // Carré en bas à droite
    if (r < gridSize - 1 && c < gridSize - 1) _evaluateSquare(r, c);
  }

  void _evaluateSquare(int r, int c) {
    if (squareOwners[r][c] != Player.none) return;

    Player p1 = dotOwners[r][c];
    Player p2 = dotOwners[r][c+1];
    Player p3 = dotOwners[r+1][c];
    Player p4 = dotOwners[r+1][c+1];

    if (p1 != Player.none && p1 == p2 && p1 == p3 && p1 == p4) {
      squareOwners[r][c] = p1;
      if (p1 == Player.p1) p1Score.value++; else p2Score.value++;
    }
  }

  void _botMove() {
    if (isGameOver) return;
    
    // IA Simple : 1. Chercher un coup qui complète un carré, 2. Bloquer l'adversaire, 3. Aléatoire
    List<Point<int>> available = [];
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (dotOwners[r][c] == Player.none) available.add(Point(r, c));
      }
    }

    if (available.isNotEmpty) {
      final move = available[Random().nextInt(available.length)];
      _makeMove(move.x, move.y);
    }
  }

  bool _isGridFull() {
    for (var row in dotOwners) {
      if (row.contains(Player.none)) return false;
    }
    return true;
  }

  void _endGame() {
    isGameOver = true;
    if (p1Score.value > p2Score.value) {
      settingsManager.playVictory();
    } else {
      settingsManager.playDefeat();
    }
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
    overlays.remove('GameOver');
    resumeEngine();
  }
}
