import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/settings_manager.dart';

class VersusRoundResultOverlay extends StatelessWidget {
  final bool won;
  final int myScore;
  final int opponentScore;
  final int myWins;
  final int opponentWins;
  final int winsNeeded;
  final String gameName;
  final VoidCallback onContinue;

  const VersusRoundResultOverlay({
    super.key,
    required this.won,
    required this.myScore,
    required this.opponentScore,
    required this.myWins,
    required this.opponentWins,
    required this.winsNeeded,
    required this.gameName,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMatchOver = myWins >= winsNeeded || opponentWins >= winsNeeded;

    // Jouer le son approprié
    if (won) {
      settingsManager.playVictory();
    } else {
      settingsManager.playDefeat();
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF001A33),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: won ? const Color(0xFFD4AF37) : Colors.redAccent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: (won ? const Color(0xFFD4AF37) : Colors.redAccent).withOpacity(0.3),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji résultat
            Text(
              won ? '🏆' : '😓',
              style: const TextStyle(fontSize: 64),
            ).animate().scale(
              begin: const Offset(0.3, 0.3),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.elasticOut,
            ),

            const SizedBox(height: 12),

            Text(
              won ? 'MANCHE GAGNÉE !' : 'MANCHE PERDUE...',
              style: TextStyle(
                color: won ? const Color(0xFFD4AF37) : Colors.redAccent,
                fontSize: 24,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
              ),
              child: Text(
                gameName,
                style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13, letterSpacing: 1),
              ),
            ),

            const SizedBox(height: 24),

            // Scores
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$myScore',
                  style: TextStyle(
                    color: won ? Colors.greenAccent : Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('-', style: TextStyle(color: Colors.white24, fontSize: 36)),
                ),
                Text(
                  '$opponentScore',
                  style: TextStyle(
                    color: won ? Colors.white : Colors.redAccent,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Score des manches
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildWinIndicator('VOUS', myWins, const Color(0xFFD4AF37)),
                const SizedBox(width: 40),
                _buildWinIndicator('ADVERSAIRE', opponentWins, Colors.blueAccent),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              'Premier à $winsNeeded victoires',
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
            ),

            const SizedBox(height: 24),

            // Bouton continuer
            GestureDetector(
              onTap: onContinue,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isMatchOver ? const Color(0xFFD4AF37) : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  isMatchOver ? 'VOIR LE RÉSULTAT' : 'MANCHE SUIVANTE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isMatchOver ? const Color(0xFF001A33) : Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinIndicator(String label, int wins, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 11, letterSpacing: 1)),
        const SizedBox(height: 4),
        Row(
          children: List.generate(winsNeeded, (i) {
            return Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: i < wins ? color : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: i < wins ? color : Colors.white24),
              ),
              child: i < wins ? const Icon(Icons.check, color: Color(0xFF001A33), size: 14) : null,
            );
          }),
        ),
      ],
    );
  }
}