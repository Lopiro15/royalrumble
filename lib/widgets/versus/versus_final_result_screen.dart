import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/settings_manager.dart';
import '../../services/score_manager.dart';

class VersusFinalResultScreen extends StatelessWidget {
  final bool won;
  final int myWins;
  final int opponentWins;

  const VersusFinalResultScreen({
    super.key,
    required this.won,
    required this.myWins,
    required this.opponentWins,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF001A33);
    const Color royalGold = Color(0xFFD4AF37);

    // Sauvegarder le score
    _saveScore();

    // Jouer le son final
    if (won) {
      settingsManager.playVictory();
    } else {
      settingsManager.playDefeat();
    }

    return Scaffold(
      backgroundColor: primaryBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF002147), primaryBlue],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    won ? '🏆' : '💪',
                    style: const TextStyle(fontSize: 80),
                  ).animate().scale(
                    begin: const Offset(0.3, 0.3),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    won ? 'VICTOIRE !' : 'DÉFAITE...',
                    style: TextStyle(
                      color: won ? royalGold : Colors.redAccent,
                      fontSize: 36,
                      letterSpacing: 3,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Text(
                    '$myWins - $opponentWins',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Score final',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                  ),

                  const SizedBox(height: 60),

                  GestureDetector(
                    onTap: () {
                      settingsManager.playClick();
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: royalGold,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'MENU PRINCIPAL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF001A33),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveScore() {
    scoreManager.saveScore(
      score: myWins * 100,
      maxScore: (myWins + opponentWins) * 100,
      gameMode: 'duo',
      playerName: settingsManager.playerName,
      gameName: 'VERSUS',
    );
  }
}