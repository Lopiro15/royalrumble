import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../services/square_game/square_flame_game.dart';
import '../../widgets/square_game/game_over_overlay.dart';
import '../../widgets/square_game/game_ui.dart';
import '../../widgets/countdown_overlay.dart';

class SquareGameScreen extends StatefulWidget {
  final bool vsBot;
  final Function(int score, int maxScore)? onSoloGameFinished;

  const SquareGameScreen({super.key, this.vsBot = true, this.onSoloGameFinished});

  @override
  State<SquareGameScreen> createState() => _SquareGameScreenState();
}

class _SquareGameScreenState extends State<SquareGameScreen> {
  late SquareFlameGame game;
  bool _showCountdown = true;

  // Score maximum pour Square Conquest
  static const int maxPossibleScore = 36; // 6x6 = 36 carrés maximum

  @override
  void initState() {
    super.initState();
    game = SquareFlameGame(onSoloGameFinished: widget.onSoloGameFinished);
    game.isVsBot = widget.vsBot;
    game.pauseEngine();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'GameOver': (context, SquareFlameGame g) => GameOverOverlay(
                game: g,
                onSoloGameFinished: widget.onSoloGameFinished,
              ),
              'UI': (context, SquareFlameGame g) => GameUI(game: g),
            },
            initialActiveOverlays: const ['UI'],
          ),
          if (_showCountdown)
            CountdownOverlay(
              onFinished: () {
                setState(() => _showCountdown = false);
                game.resumeEngine();
              },
            ),
        ],
      ),
    );
  }
}