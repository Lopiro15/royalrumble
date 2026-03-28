import 'package:flutter/material.dart';
import '../../services/hanoi_game/hanoi_flame_game.dart';

class VictoryOverlay extends StatelessWidget {
  final HanoiFlameGame game;
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
            const Icon(Icons.emoji_events, color: Color(0xFFD4AF37), size: 60),
            const Text('TOUR RÉUSSIE !', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text('COUPS : ${game.moves.value}', style: const TextStyle(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
              onPressed: () => game._resetGame(),
              child: const Text('REJOUER', style: TextStyle(color: Color(0xFF001A33))),
            ),
          ],
        ),
      ),
    );
  }
}
