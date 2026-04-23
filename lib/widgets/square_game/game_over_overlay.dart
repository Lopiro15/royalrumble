import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/square_game/square_flame_game.dart';
import '../../services/settings_manager.dart';

class GameOverOverlay extends StatelessWidget {
  final SquareFlameGame game;
  final Function(int score, int maxScore)? onSoloGameFinished;

  const GameOverOverlay({
    super.key,
    required this.game,
    this.onSoloGameFinished,
  });

  @override
  Widget build(BuildContext context) {
    final int playerScore = game.p1Score.value;
    final int botScore = game.p2Score.value;
    final bool isVictory = playerScore > botScore;
    final bool isSoloMode = onSoloGameFinished != null;

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF001A33),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isVictory ? const Color(0xFFD4AF37) : Colors.redAccent,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: (isVictory ? const Color(0xFFD4AF37) : Colors.redAccent).withOpacity(0.3),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isVictory ? '🏆' : '😓',
                style: const TextStyle(fontSize: 64),
              ).animate().scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.elasticOut,
              ),

              const SizedBox(height: 16),

              Text(
                isVictory ? 'VICTOIRE !' : 'DÉFAITE...',
                style: TextStyle(
                  color: isVictory ? const Color(0xFFD4AF37) : Colors.redAccent,
                  fontSize: 32,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const Text(
                        'VOUS',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$playerScore',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '-',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 36,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      const Text(
                        'BOT',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$botScore',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              if (isSoloMode) ...[
                GestureDetector(
                  onTap: () {
                    settingsManager.playClick();
                    game.overlays.remove('GameOver');
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
                    game.overlays.remove('GameOver');
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
                      'MENU',
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