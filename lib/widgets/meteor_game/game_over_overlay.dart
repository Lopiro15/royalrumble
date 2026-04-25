import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/meteor_game/meteor_game.dart';
import '../../services/settings_manager.dart';

class GameOverOverlay extends StatelessWidget {
  final MeteorGame game;
  final Function(int score, int maxScore)? onSoloGameFinished;
  final bool isVersusMode;

  const GameOverOverlay({
    super.key,
    required this.game,
    this.onSoloGameFinished,
    this.isVersusMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final int score = game.scoreNotifier.value;

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF001A33),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.redAccent, width: 3),
            boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.3), blurRadius: 30)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.flash_on_rounded, color: Colors.redAccent, size: 64).animate().shake(),
              const SizedBox(height: 16),
              const Text('GAME OVER', style: TextStyle(color: Colors.redAccent, fontSize: 32, letterSpacing: 3)),
              const SizedBox(height: 24),
              Text('SCORE: $score', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              if (isVersusMode) ...[
                const SizedBox(height: 8),
                const Text('En attente de l\'adversaire...', style: TextStyle(color: Colors.orangeAccent, fontSize: 14)),
                const SizedBox(height: 8),
                const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2)),
              ],
              if (!isVersusMode) ...[
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    settingsManager.playClick();
                    game.restart();
                    game.overlays.remove('GameOver');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(20)),
                    child: const Text('REJOUER', textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF001A33), fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    settingsManager.playClick();
                    game.overlays.remove('GameOver');
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
                    child: const Text('MENU', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 18, letterSpacing: 2)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}