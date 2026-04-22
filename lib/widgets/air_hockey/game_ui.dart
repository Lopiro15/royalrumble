import 'package:flutter/material.dart';
import '../../services/air_hockey/air_hockey_game.dart';

class GameUI extends StatelessWidget {
  final AirHockeyGame game;
  const GameUI({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // UI labels removed as requested, score is now in-game
  }
}
