import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../stores/solo_game_store.dart';
import '../services/settings_manager.dart';

class SoloGameOverlay extends StatelessWidget {
  final SoloGameStore store;
  final VoidCallback onContinue;

  const SoloGameOverlay({
    super.key,
    required this.store,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final result = store.results.last;
    final bool isVictory = result.isVictory;
    final String nextGame = store.gamesRemaining > 0 ? store.selectedGames[store.currentGameIndex.value + 1] : '';

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
                color: (isVictory ? const Color(0xFFD4AF37) : Colors.redAccent)
                    .withOpacity(0.3),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône de résultat
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

              // Nom du jeu terminé
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
                ),
                child: Text(
                  result.gameName,
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Score
              Text(
                '${result.score} pts',
                style: TextStyle(
                  color: isVictory ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                result.percentage,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 24),

              // Progression
              Text(
                'Partie ${store.currentGameIndex.value + 1}/${SoloGameStore.totalGamesInSession}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 8),

              // Barre de progression
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (store.currentGameIndex.value + 1) / SoloGameStore.totalGamesInSession,
                  minHeight: 6,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                ),
              ),

              const SizedBox(height: 24),

              // Message pour le prochain jeu
              if (store.gamesRemaining > 0) ...[
                Text(
                  'Prochain jeu :',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nextGame,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Bouton continuer
              GestureDetector(
                onTap: () {
                  settingsManager.playClick();
                  onContinue();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFD4AF37),
                        const Color(0xFFD4AF37).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        store.gamesRemaining > 0 ? 'CONTINUER' : 'VOIR LE RÉCAPITULATIF',
                        style: const TextStyle(
                          color: Color(0xFF001A33),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF001A33),
                      ),
                    ],
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
                  .shimmer(delay: 1000.ms, duration: 1500.ms),
            ],
          ),
        ),
      ),
    );
  }
}