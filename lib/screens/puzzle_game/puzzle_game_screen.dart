import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/settings_manager.dart';
import '../../widgets/countdown_overlay.dart';
import '../../widgets/menu_button.dart';

class PuzzleGameScreen extends StatefulWidget {
  final Function(int score, int maxScore)? onSoloGameFinished;

  const PuzzleGameScreen({super.key, this.onSoloGameFinished});

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  static const int gridSize = 3;
  static const double puzzleSize = 300.0;
  bool _showCountdown = true;
  late List<int> tiles;
  int moves = 0;
  int secondsElapsed = 0;
  Timer? timer;
  bool isGameStarted = false;
  bool isWon = false;
  bool showOriginal = false;
  bool _hasNotifiedSolo = false;

  // Score maximum pour Puzzle (calculé à la victoire)
  int get _calculatedMaxScore => 1000;

  @override
  void initState() {
    super.initState();
    tiles = List.generate(gridSize * gridSize, (index) => index);
  }

  void _resetGame() {
    tiles = List.generate(gridSize * gridSize, (index) => index);
    moves = 0;
    secondsElapsed = 0;
    isWon = false;
    isGameStarted = false;
    showOriginal = false;
    _hasNotifiedSolo = false;
    timer?.cancel();
    _shuffleTiles();
    setState(() {});
  }

  void _startTimer() {
    isGameStarted = true;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        secondsElapsed++;
      });
    });
  }

  void _shuffleTiles() {
    tiles = List.generate(gridSize * gridSize, (index) => index);
    int emptyIndex = gridSize * gridSize - 1;
    for (int i = 0; i < 200; i++) {
      List<int> validMoves = _getValidMoves(emptyIndex);
      int nextIndex = (validMoves..shuffle()).first;
      tiles[emptyIndex] = tiles[nextIndex];
      tiles[nextIndex] = 8;
      emptyIndex = nextIndex;
    }
  }

  List<int> _getValidMoves(int emptyIndex) {
    List<int> validMoves = [];
    int row = emptyIndex ~/ gridSize;
    int col = emptyIndex % gridSize;
    if (row > 0) validMoves.add(emptyIndex - gridSize);
    if (row < gridSize - 1) validMoves.add(emptyIndex + gridSize);
    if (col > 0) validMoves.add(emptyIndex - 1);
    if (col < gridSize - 1) validMoves.add(emptyIndex + 1);
    return validMoves;
  }

  void _moveTile(int index) {
    if (isWon) return;
    if (!isGameStarted) _startTimer();
    int emptyIndex = tiles.indexOf(8);
    if (_getValidMoves(emptyIndex).contains(index)) {
      settingsManager.playClick();
      setState(() {
        tiles[emptyIndex] = tiles[index];
        tiles[index] = 8;
        moves++;
        _checkWin();
      });
    }
  }

  int _calculateScore() {
    // Score basé sur le temps et le nombre de coups
    // Moins de temps et moins de coups = meilleur score
    int timePenalty = (secondsElapsed * 2).clamp(0, 500);
    int movePenalty = (moves * 5).clamp(0, 300);
    return (_calculatedMaxScore - timePenalty - movePenalty).clamp(100, _calculatedMaxScore);
  }

  void _checkWin() {
    bool win = true;
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i] != i) {
        win = false;
        break;
      }
    }
    if (win) {
      settingsManager.playWin();
      setState(() {
        isWon = true;
        timer?.cancel();
      });

      final int finalScore = _calculateScore();

      // Notifier le mode solo
      if (widget.onSoloGameFinished != null && !_hasNotifiedSolo) {
        _hasNotifiedSolo = true;
        widget.onSoloGameFinished!(finalScore, _calculatedMaxScore);
      }

      Future.delayed(const Duration(seconds: 2), () {
        _showWinDialog(finalScore);
      });
    }
  }

  void _showWinDialog(int finalScore) {
    final bool isSoloMode = widget.onSoloGameFinished != null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF002147),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFD4AF37))),
        title: const Text('FELICITATIONS !', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFD4AF37))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Color(0xFFD4AF37), size: 60).animate().scale(duration: 600.ms).then().shake(),
            const SizedBox(height: 20),
            Text('SCORE: $finalScore', style: const TextStyle(color: Colors.white, fontSize: 18)),
            Text('TEMPS : ${_formatTime(secondsElapsed)}', style: const TextStyle(color: Colors.white70, fontSize: 16)),
            Text('COUPS : $moves', style: const TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
        actions: [
          if (isSoloMode) ...[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('TERMINÉ', style: TextStyle(color: Color(0xFFD4AF37))),
            ),
          ] else ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetGame();
              },
              child: const Text('REJOUER', style: TextStyle(color: Color(0xFFD4AF37))),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('MENU', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(int sec) {
    int minutes = sec ~/ 60;
    int remainingSeconds = sec % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF001A33);
    const Color royalGold = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('PUZZLE ROYAL', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(showOriginal ? Icons.grid_on : Icons.image_outlined, color: Colors.white),
            onPressed: () => setState(() => showOriginal = !showOriginal),
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF002147), primaryBlue],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoCard('COUPS', moves.toString()),
                    _buildInfoCard('TEMPS', _formatTime(secondsElapsed)),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: puzzleSize,
                    height: puzzleSize,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: royalGold.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: showOriginal
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset('assets/logo.png', fit: BoxFit.fill),
                    ).animate().fadeIn()
                        : GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridSize,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: tiles.length,
                      itemBuilder: (context, index) {
                        int tileValue = tiles[index];

                        if (isWon && tileValue == 8) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: royalGold, width: 1),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: _getTileImage(8),
                            ),
                          ).animate().fadeIn(duration: 800.ms);
                        }

                        if (tileValue == 8) return Container(color: Colors.black12);

                        return GestureDetector(
                          onPanEnd: (details) {
                            if (details.velocity.pixelsPerSecond.dx.abs() > details.velocity.pixelsPerSecond.dy.abs()) {
                              if (details.velocity.pixelsPerSecond.dx > 0) _handleSwipe(index, "right");
                              else _handleSwipe(index, "left");
                            } else {
                              if (details.velocity.pixelsPerSecond.dy > 0) _handleSwipe(index, "down");
                              else _handleSwipe(index, "up");
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: royalGold, width: 1),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: _getTileImage(tileValue),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showCountdown)
            CountdownOverlay(
              onFinished: () {
                setState(() => _showCountdown = false);
                _resetGame();
                _startTimer();
              },
            ),
        ],
      ),
    );
  }

  void _handleSwipe(int index, String direction) {
    int emptyIndex = tiles.indexOf(8);
    int row = index ~/ gridSize;
    int col = index % gridSize;
    int targetIndex = -1;
    if (direction == "right" && col < gridSize - 1) targetIndex = index + 1;
    if (direction == "left" && col > 0) targetIndex = index - 1;
    if (direction == "up" && row > 0) targetIndex = index - gridSize;
    if (direction == "down" && row < gridSize - 1) targetIndex = index + gridSize;
    if (targetIndex == emptyIndex) _moveTile(index);
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text(value, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _getTileImage(int tileValue) {
    int row = tileValue ~/ gridSize;
    int col = tileValue % gridSize;

    return FractionalTranslation(
      translation: Offset(-col.toDouble(), -row.toDouble()),
      child: OverflowBox(
        maxWidth: puzzleSize,
        maxHeight: puzzleSize,
        minWidth: puzzleSize,
        minHeight: puzzleSize,
        alignment: Alignment.topLeft,
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}