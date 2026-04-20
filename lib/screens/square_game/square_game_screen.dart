import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../services/square_game/square_flame_game.dart';
import '../../widgets/square_game/game_over_overlay.dart';
import '../../widgets/square_game/game_ui.dart';
import '../../widgets/countdown_overlay.dart';

class SquareGameScreen extends StatefulWidget {
  final bool vsBot;
  const SquareGameScreen({super.key, this.vsBot = true});

  @override
  State<SquareGameScreen> createState() => _SquareGameScreenState();
}

class _SquareGameScreenState extends State<SquareGameScreen> {
  late SquareFlameGame game;
  bool _showCountdown = true;

  @override
  void initState() {
    super.initState();
    game = SquareFlameGame();
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
              'GameOver': (context, SquareFlameGame g) => GameOverOverlay(game: g),
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
