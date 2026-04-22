import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../services/air_hockey/air_hockey_game.dart';
import '../../widgets/air_hockey/game_ui.dart';
import '../../widgets/air_hockey/victory_overlay.dart';
import '../../widgets/countdown_overlay.dart';

class AirHockeyScreen extends StatefulWidget {
  final bool vsBot;
  const AirHockeyScreen({super.key, this.vsBot = true});

  @override
  State<AirHockeyScreen> createState() => _AirHockeyScreenState();
}

class _AirHockeyScreenState extends State<AirHockeyScreen> {
  late AirHockeyGame game;
  bool _showCountdown = true;

  @override
  void initState() {
    super.initState();
    game = AirHockeyGame();
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
              'GameOver': (context, AirHockeyGame g) => VictoryOverlay(game: g),
              'UI': (context, AirHockeyGame g) => GameUI(game: g),
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
