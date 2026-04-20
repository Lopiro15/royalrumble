import 'package:flutter/material.dart';
import '../../services/square_game/square_flame_game.dart';

class GameUI extends StatelessWidget {
  final SquareFlameGame game;
  const GameUI({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    const Color p1Color = Color(0xFFD4AF37);
    const Color p2Color = Colors.blueAccent;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                ValueListenableBuilder<Player>(
                  valueListenable: game.turnNotifier,
                  builder: (context, turn, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: turn == Player.p1 ? p1Color : p2Color,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        turn == Player.p1 ? "TOUR : OR" : "TOUR : BLEU",
                        style: TextStyle(
                          color: turn == Player.p1 ? p1Color : p2Color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 48), // Spacer pour l'équilibre de l'appbar
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScoreCard("JOUEUR OR", game.p1Score, p1Color),
                _buildScoreCard(game.isVsBot ? "ORDINATEUR" : "JOUEUR BLEU", game.p2Score, p2Color),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(String label, ValueNotifier<int> score, Color color) {
    return ValueListenableBuilder<int>(
      valueListenable: score,
      builder: (context, val, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
              Text(val.toString(), style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
}
