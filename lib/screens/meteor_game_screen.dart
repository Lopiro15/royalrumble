import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../services/meteor_game/meteor_game.dart';
import '../widgets/meteor_game/game_over_overlay.dart';
import '../widgets/meteor_game/game_ui.dart';

class MeteorGameScreen extends StatelessWidget {
  const MeteorGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = MeteorGame();
    return Scaffold(
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'GameOver': (context, MeteorGame g) => GameOverOverlay(game: g),
          'UI': (context, MeteorGame g) => GameUI(game: g),
        },
        initialActiveOverlays: const ['UI'],
      ),
    );
  }
}
