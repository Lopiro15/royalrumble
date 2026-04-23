import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../stores/solo_game_store.dart';
import '../services/settings_manager.dart';
import '../services/score_manager.dart';

class SoloFinalRecapOverlay extends StatelessWidget {
  final SoloGameStore store;
  final VoidCallback onQuit;

  const SoloFinalRecapOverlay({
    super.key,
    required this.store,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    final bool isVictory = store.isOverallVictory;

    // Sauvegarde du score global
    _saveGlobalScore();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF002147), Color(0xFF001A33)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // Titre
            Text(
              isVictory ? '🏆 VICTOIRE ! 🏆' : '💪 BIEN JOUÉ !',
              style: TextStyle(
                color: isVictory ? const Color(0xFFD4AF37) : Colors.orange,
                fontSize: 32,
                letterSpacing: 3,
              ),
            ).animate().fadeIn(duration: 400.ms).scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.elasticOut,
            ),

            const SizedBox(height: 8),

            Text(
              'Score total : ${store.totalScore.value} / ${store.totalMaxScore.value}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            Text(
              '${(store.overallRatio * 100).round()}%',
              style: TextStyle(
                color: isVictory ? Colors.greenAccent : Colors.orangeAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Liste des résultats
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: store.results.length,
                itemBuilder: (context, index) {
                  final result = store.results[index];
                  return _buildResultCard(result, index);
                },
              ),
            ),

            // Bouton quitter
            Padding(
              padding: const EdgeInsets.all(30),
              child: GestureDetector(
                onTap: () {
                  settingsManager.playClick();
                  onQuit();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_rounded, color: Color(0xFF001A33)),
                      SizedBox(width: 12),
                      Text(
                        'MENU PRINCIPAL',
                        style: TextStyle(
                          color: Color(0xFF001A33),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(SoloGameResult result, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF002147),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: result.isVictory
              ? const Color(0xFFD4AF37).withOpacity(0.5)
              : Colors.white24,
        ),
      ),
      child: Row(
        children: [
          // Icône de résultat
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: result.isVictory
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              result.isVictory ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied_rounded,
              color: result.isVictory ? const Color(0xFFD4AF37) : Colors.redAccent,
            ),
          ),

          const SizedBox(width: 14),

          // Nom du jeu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.gameName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  result.percentage,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Score
          Text(
            '${result.score} pts',
            style: TextStyle(
              color: result.isVictory ? Colors.greenAccent : Colors.redAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate()
        .fadeIn(delay: (400 + index * 100).ms)
        .slideX(begin: -0.2);
  }

  void _saveGlobalScore() {
    scoreManager.saveScore(
      score: store.totalScore.value,
      maxScore: store.totalMaxScore.value,
      gameMode: 'solo',
      playerName: settingsManager.playerName,
      gameName: 'SOLO (${SoloGameStore.totalGamesInSession} jeux)',
    );
  }
}