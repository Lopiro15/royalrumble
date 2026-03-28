import 'package:flutter/material.dart';
import '../../services/meteor_game/meteor_game.dart';

class GameOverOverlay extends StatelessWidget {
  final MeteorGame game;
  const GameOverOverlay({super.key, required this.game});

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
            const Text('VAISSEAU DÉTRUIT', style: TextStyle(color: Colors.redAccent, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ValueListenableBuilder<int>(
              valueListenable: game.scoreNotifier,
              builder: (context, score, _) => Text('SCORE FINAL : $score', style: const TextStyle(color: Colors.white, fontSize: 24)),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
              onPressed: game.restart,
              child: const Text('RÉESSAYER', style: TextStyle(color: Color(0xFF001A33))),
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
