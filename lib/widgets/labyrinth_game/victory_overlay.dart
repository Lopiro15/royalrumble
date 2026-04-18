import 'package:flutter/material.dart';
import '../../services/labyrinth_game/labyrinth_game.dart';

class VictoryOverlay extends StatelessWidget {
  final LabyrinthGame game;
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
            const Text('SORTIE TROUVÉE !', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ValueListenableBuilder<int>(
              valueListenable: game.seconds,
              builder: (context, val, _) => Text('TEMPS : $val s', style: const TextStyle(color: Colors.white, fontSize: 24)),
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
