import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../services/meteor_game/meteor_game.dart';
import '../../widgets/countdown_overlay.dart';
import '../../widgets/meteor_game/game_over_overlay.dart';
import '../../widgets/meteor_game/game_ui.dart';

class MeteorGameScreen extends StatefulWidget {
  const MeteorGameScreen({super.key});


  @override
  State<MeteorGameScreen> createState() => _MeteorGameScreenState();

}

class _MeteorGameScreenState extends State<MeteorGameScreen> {
  late MeteorGame game;
  bool _showCountdown = true;

  @override
  void initState() {
    super.initState();
    game = MeteorGame();
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
              'GameOver': (context, MeteorGame g) => GameOverOverlay(game: g),
              'UI': (context, MeteorGame g) => GameUI(game: g),
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



//
// @override
// Widget build(BuildContext context) {
//   final game = MeteorGame();
//   return Scaffold(
//     body: GameWidget(
//       game: game,
//       overlayBuilderMap: {
//         'GameOver': (context, MeteorGame g) => GameOverOverlay(game: g),
//         'UI': (context, MeteorGame g) => GameUI(game: g),
//       },
//       initialActiveOverlays: const ['UI'],
//     ),
//   );
// }