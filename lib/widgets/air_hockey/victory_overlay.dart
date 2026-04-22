import 'package:flutter/material.dart';
import '../../services/air_hockey/air_hockey_game.dart';

class VictoryOverlay extends StatelessWidget {
  final AirHockeyGame game;
  const VictoryOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final String resultText = game.winner == 1 ? "VICTOIRE ROYALE !" : "DÉFAITE...";
    final Color resultColor = game.winner == 1 ? const Color(0xFFD4AF37) : Colors.redAccent;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: const Color(0xFF001A33),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              game.winner == 1 ? Icons.emoji_events : Icons.sentiment_dissatisfied,
              color: const Color(0xFFD4AF37),
              size: 60,
            ),
            const SizedBox(height: 10),
            Text(
              resultText,
              style: TextStyle(color: resultColor, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "SCORE FINAL : ${game.p1Score.value} - ${game.p2Score.value}",
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
              onPressed: () => game.restart(),
              child: const Text('REJOUER', style: TextStyle(color: Color(0xFF001A33))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('QUITTER', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }
}
