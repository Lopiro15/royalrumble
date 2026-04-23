import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/labyrinth_game/labyrinth_game.dart';
import '../../services/settings_manager.dart';

class VictoryOverlay extends StatelessWidget {
  final LabyrinthGame game;
  final Function(int score, int maxScore)? onSoloGameFinished;

  const VictoryOverlay({
    super.key,
    required this.game,
    this.onSoloGameFinished,
  });

  int _calculateScore(int seconds) {
    int timePenalty = (seconds * 3).clamp(0, 900);
    return (LabyrinthGame.maxPossibleScore - timePenalty).clamp(100, LabyrinthGame.maxPossibleScore);
  }

  @override
  Widget build(BuildContext context) {
    final bool isSoloMode = onSoloGameFinished != null;
    final int score = _calculateScore(game.seconds.value);

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFF001A33),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD4AF37), width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Color(0xFFD4AF37), size: 60)
                  .animate()
                  .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.elasticOut,
              ),

              const SizedBox(height: 16),

              const Text(
                'SORTIE TROUVÉE !',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'SCORE: $score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              ValueListenableBuilder<int>(
                valueListenable: game.seconds,
                builder: (context, val, _) => Text(
                  'TEMPS : $val s',
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ),

              const SizedBox(height: 30),

              if (isSoloMode) ...[
                // Mode Solo : bouton TERMINÉ
                GestureDetector(
                  onTap: () {
                    settingsManager.playClick();
                    game.overlays.remove('Victory');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'TERMINÉ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF001A33),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Mode Entraînement : REJOUER + QUITTER
                GestureDetector(
                  onTap: () {
                    settingsManager.playClick();
                    game.restart();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'REJOUER',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF001A33),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                GestureDetector(
                  onTap: () {
                    settingsManager.playClick();
                    game.overlays.remove('Victory');
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Text(
                      'QUITTER',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                    ),
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