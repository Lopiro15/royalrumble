import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/settings_manager.dart';

class VersusChallengeDialog extends StatelessWidget {
  final String challengerName;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const VersusChallengeDialog({
    super.key,
    required this.challengerName,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    const Color royalGold = Color(0xFFD4AF37);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF001A33),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: royalGold, width: 2),
          boxShadow: [BoxShadow(color: royalGold.withOpacity(0.2), blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sports_kabaddi_rounded, color: royalGold, size: 64)
                .animate()
                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 400.ms)
                .then()
                .shake(),

            const SizedBox(height: 20),

            Text(
              'DÉFI REÇU !',
              style: TextStyle(color: royalGold, fontSize: 24, letterSpacing: 2),
            ),

            const SizedBox(height: 12),

            Text(
              challengerName,
              style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 1),
            ),

            const SizedBox(height: 8),

            Text(
              'vous défie en duel !',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
            ),

            const SizedBox(height: 30),

            // Remplacer le Row par :
            const SizedBox(height: 24),

// Boutons empilés au lieu d'une Row
            GestureDetector(
              onTap: () {
                settingsManager.playClick();
                onAccept();
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: royalGold,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'ACCEPTER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF001A33),
                    fontSize: 18,
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
                onReject();
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                ),
                child: const Text(
                  'REFUSER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }
}