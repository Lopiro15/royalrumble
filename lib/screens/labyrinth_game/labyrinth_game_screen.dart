import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../services/labyrinth_game/labyrinth_game.dart';
import '../../widgets/labyrinth_game/victory_overlay.dart';
import '../../widgets/countdown_overlay.dart';

class LabyrinthGameScreen extends StatefulWidget {
  const LabyrinthGameScreen({super.key});

  @override
  State<LabyrinthGameScreen> createState() => _LabyrinthGameScreenState();
}

class _LabyrinthGameScreenState extends State<LabyrinthGameScreen> {
  late LabyrinthGame game;
  bool _showCountdown = true;

  @override
  void initState() {
    super.initState();
    game = LabyrinthGame();
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
              'Victory': (context, LabyrinthGame g) => VictoryOverlay(game: g),
            },
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
