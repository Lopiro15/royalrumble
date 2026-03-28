import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../models/puzzle_game/tile_component.dart';
import '../settings_manager.dart';

class PuzzleFlameGame extends FlameGame {
  static const int gridSize = 3;
  late List<int> tiles;
  late double tileSize;
  final ValueNotifier<int> moves = ValueNotifier(0);
  bool isWon = false;

  @override
  Future<void> onLoad() async {
    tileSize = size.x < size.y ? (size.x - 40) / gridSize : (size.y - 150) / gridSize;
    resetGame();
  }

  void resetGame() {
    tiles = List.generate(gridSize * gridSize, (index) => index);
    _shuffle();
    _refreshComponents();
    moves.value = 0;
    isWon = false;
    overlays.remove('Victory');
  }

  void _shuffle() {
    int emptyIndex = gridSize * gridSize - 1;
    for (int i = 0; i < 200; i++) {
      List<int> neighbors = _getNeighbors(emptyIndex);
      int next = (neighbors..shuffle()).first;
      int temp = tiles[emptyIndex];
      tiles[emptyIndex] = tiles[next];
      tiles[next] = temp;
      emptyIndex = next;
    }
  }

  List<int> _getNeighbors(int index) {
    List<int> n = [];
    int row = index ~/ gridSize;
    int col = index % gridSize;
    if (row > 0) n.add(index - gridSize);
    if (row < gridSize - 1) n.add(index + gridSize);
    if (col > 0) n.add(index - 1);
    if (col < gridSize - 1) n.add(index + 1);
    return n;
  }

  void _refreshComponents() {
    children.whereType<TileComponent>().forEach((t) => t.removeFromParent());
    double startX = (size.x - tileSize * gridSize) / 2;
    double startY = (size.y - tileSize * gridSize) / 2;

    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i] != 8) {
        add(TileComponent(
          value: tiles[i],
          currentIndex: i,
          position: Vector2(startX + (i % gridSize) * tileSize, startY + (i ~/ gridSize) * tileSize),
          size: Vector2(tileSize - 2, tileSize - 2),
        ));
      }
    }
  }

  void tryMove(int index) {
    if (isWon) return;
    int emptyIndex = tiles.indexOf(8);
    if (_getNeighbors(emptyIndex).contains(index)) {
      settingsManager.playClick();
      int temp = tiles[emptyIndex];
      tiles[emptyIndex] = tiles[index];
      tiles[index] = temp;
      moves.value++;
      _refreshComponents();
      _checkWin();
    }
  }

  void _checkWin() {
    bool win = true;
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i] != i) win = false;
    }
    if (win) {
      isWon = true;
      settingsManager.playWin();
      overlays.add('Victory');
    }
  }
}
