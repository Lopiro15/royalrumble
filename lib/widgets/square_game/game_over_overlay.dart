import 'package:flutter/material.dart';
import '../../services/square_game/square_flame_game.dart';

class GameOverOverlay extends StatelessWidget {
  final SquareFlameGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final bool p1Wins = game.p1Score.value > game.p2Score.value;
    final bool draw = game.p1Score.value == game.p2Score.value;

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
              draw ? Icons.balance_rounded : (p1Wins ? Icons.emoji_events : Icons.sentiment_dissatisfied),
              color: const Color(0xFFD4AF37),
              size: 60,
            ),
            const SizedBox(height: 10),
            Text(
              draw ? "MATCH NUL !" : (p1Wins ? "VICTOIRE OR !" : "DÉFAITE..."),
              style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 28, fontWeight: FontWeight.bold),
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
