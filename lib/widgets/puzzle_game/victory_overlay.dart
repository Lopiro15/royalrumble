import 'package:flutter/material.dart';
import '../../services/puzzle_game/puzzle_flame_game.dart';

class VictoryOverlay extends StatelessWidget {
  final PuzzleFlameGame game;
  const VictoryOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
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
            const Text('GAGNÉ !', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ValueListenableBuilder<int>(
              valueListenable: game.moves,
              builder: (context, val, _) => Text('COUPS : $val', style: const TextStyle(color: Colors.white, fontSize: 24)),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
              onPressed: () => game.resetGame(),
              child: const Text('REJOUER', style: TextStyle(color: Color(0xFF001A33))),
            ),
          ],
        ),
      ),
    );
  }
}
