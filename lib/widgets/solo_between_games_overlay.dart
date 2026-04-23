import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/settings_manager.dart';

class SoloBetweenGamesOverlay extends StatelessWidget {
  final int currentGameIndex;
  final int totalGames;
  final String nextGame;
  final VoidCallback onContinue;

  const SoloBetweenGamesOverlay({
    super.key,
    required this.currentGameIndex,
    required this.totalGames,
    required this.nextGame,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
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
              color: const Color(0xFFD4AF37),
              width: 3,
            ),
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
              Text(
                '🏆',
                style: const TextStyle(fontSize: 64),
              ).animate().scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.elasticOut,
              ),

              const SizedBox(height: 24),

              Text(
                'Partie ${currentGameIndex + 1}/$totalGames terminée !',
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 20,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Prochain jeu :',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
                ),
                child: Text(
                  nextGame,
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 32),

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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'CONTINUER',
                        style: TextStyle(
                          color: Color(0xFF001A33),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
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