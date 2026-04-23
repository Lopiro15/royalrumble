import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../models/labyrinth_game/ball.dart';
import '../settings_manager.dart';

class LabyrinthGame extends FlameGame with HasCollisionDetection {
  late Ball ball;
  bool isWon = false;
  final ValueNotifier<int> seconds = ValueNotifier(0);
  late Timer _timer;

  final Function(int score, int maxScore)? onSoloGameFinished;
  bool _hasNotifiedSolo = false;

  // Score maximum pour Labyrinth
  static const int maxPossibleScore = 1000;

  LabyrinthGame({this.onSoloGameFinished});

  @override
  Future<void> onLoad() async {
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF000814),
    ));

    _generateComplexLabyrinth();

    // Position de départ (centrée dans la première cellule)
    ball = Ball(position: Vector2(17.5, 17.5));
    add(ball);

    _timer = Timer(1, repeat: true, onTick: () {
      if (!isWon) seconds.value++;
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer.update(dt);
  }

  bool isCollidingWithWall(Rect rect) {
    for (var child in children) {
      if (child is Wall) {
        if (child.toRect().overlaps(rect)) {
          return true;
        }
      }
    }
    return false;
  }

  void _generateComplexLabyrinth() {
    const double cellSize = 35.0;
    final int cols = (size.x / cellSize).floor();
    final int rows = (size.y / cellSize).floor();

    List<List<bool>> visited = List.generate(rows, (_) => List.filled(cols, false));
    List<Map<String, int>> stack = [];

    // Initialisation : tous les murs sont présents
    List<List<bool>> hWalls = List.generate(rows + 1, (_) => List.filled(cols, true));
    List<List<bool>> vWalls = List.generate(rows, (_) => List.filled(cols + 1, true));

    int currR = 0, currC = 0;
    visited[currR][currC] = true;
    stack.add({'r': currR, 'c': currC});

    final rand = Random();

    // Algorithme DFS pour garantir un chemin unique et solvable vers chaque cellule
    while (stack.isNotEmpty) {
      var current = stack.last;
      int r = current['r']!;
      int c = current['c']!;

      List<Map<String, int>> neighbors = [];
      if (r > 0 && !visited[r - 1][c]) neighbors.add({'r': r - 1, 'c': c, 'dir': 0}); // Haut
      if (r < rows - 1 && !visited[r + 1][c]) neighbors.add({'r': r + 1, 'c': c, 'dir': 1}); // Bas
      if (c > 0 && !visited[r][c - 1]) neighbors.add({'r': r, 'c': c - 1, 'dir': 2}); // Gauche
      if (c < cols - 1 && !visited[r][c + 1]) neighbors.add({'r': r, 'c': c + 1, 'dir': 3}); // Droite

      if (neighbors.isNotEmpty) {
        var next = neighbors[rand.nextInt(neighbors.length)];
        int nr = next['r']!;
        int nc = next['c']!;
        int dir = next['dir']!;

        // On abat le mur
        if (dir == 0) hWalls[r][c] = false;
        else if (dir == 1) hWalls[r + 1][c] = false;
        else if (dir == 2) vWalls[r][c] = false;
        else if (dir == 3) vWalls[r][c + 1] = false;

        visited[nr][nc] = true;
        stack.add({'r': nr, 'c': nc});
      } else {
        stack.removeLast();
      }
    }

    double wallThickness = 8.0; // Réduit de 10 à 8 pour laisser passer la bille de 22px plus facilement

    // Construction des murs horizontaux
    for (int r = 0; r <= rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (hWalls[r][c]) {
          add(Wall(
            position: Vector2(c * cellSize, r * cellSize - wallThickness / 2),
            size: Vector2(cellSize, wallThickness),
          ));
        }
      }
    }

    // Construction des murs verticaux
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c <= cols; c++) {
        if (vWalls[r][c]) {
          add(Wall(
            position: Vector2(c * cellSize - wallThickness / 2, r * cellSize),
            size: Vector2(wallThickness, cellSize),
          ));
        }
      }
    }

    // Sortie dans la dernière cellule générée (en bas à droite)
    add(ExitPortal(position: Vector2((cols - 0.5) * cellSize, (rows - 0.5) * cellSize)));
  }

  int _calculateScore() {
    // Score basé sur le temps : moins de temps = meilleur score
    int timePenalty = (seconds.value * 3).clamp(0, 900);
    return (maxPossibleScore - timePenalty).clamp(100, maxPossibleScore);
  }

  void victory() {
    if (isWon) return;
    isWon = true;
    settingsManager.playWin();

    // Notifier le mode solo
    if (onSoloGameFinished != null && !_hasNotifiedSolo) {
      _hasNotifiedSolo = true;
      onSoloGameFinished!(_calculateScore(), maxPossibleScore);
    }

    overlays.add('Victory');
  }

  void restart() {
    isWon = false;
    _hasNotifiedSolo = false;
    seconds.value = 0;
    ball.position = Vector2(17.5, 17.5);
    overlays.remove('Victory');
    resumeEngine();
  }
}