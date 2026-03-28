import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ---------------------------------------------------------------------------
// GameMenuCard — Carte cliquable représentant un mini-jeu disponible
//
// Utilisée dans GameMenuScreen pour lister les jeux disponibles.
// Affiche : grande icône, titre, description, badge disponible/bientôt.
// Design plus grand que QuizMenuCard car il y a moins d'items.
// ---------------------------------------------------------------------------
class GameMenuCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final bool isAvailable;
  final Duration animationDelay;
  final VoidCallback? onTap;

  const GameMenuCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.isAvailable,
    required this.animationDelay,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: isAvailable ? 1.0 : 0.5,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF002147),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isAvailable ? accentColor.withOpacity(0.6) : Colors.white12,
              width: 2,
            ),
            boxShadow: isAvailable
                ? [BoxShadow(color: accentColor.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))]
                : [],
          ),
          child: Row(
            children: [
              // Icône dans un carré arrondi coloré
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accentColor.withOpacity(0.4), width: 1.5),
                ),
                child: Icon(icon, color: accentColor, size: 32),
              ),

              const SizedBox(width: 18),

              // Textes
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 22,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Flèche ou badge "bientôt"
              isAvailable
                  ? Icon(Icons.arrow_forward_ios_rounded, color: accentColor, size: 20)
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Text(
                        'BIENTÔT',
                        style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1),
                      ),
                    ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: animationDelay, duration: 400.ms)
        .slideX(begin: -0.1, delay: animationDelay);
  }
}