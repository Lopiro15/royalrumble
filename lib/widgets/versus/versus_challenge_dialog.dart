import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/settings_manager.dart';

class VersusChallengeDialog extends StatelessWidget {
  final String challengerName;
  final int rounds;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const VersusChallengeDialog({
    super.key,
    required this.challengerName,
    required this.rounds,
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
              'vous défie en BO$rounds',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    settingsManager.playClick();
                    onReject();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                    ),
                    child: const Text(
                      'REFUSER',
                      style: TextStyle(color: Colors.redAccent, fontSize: 16),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    settingsManager.playClick();
                    onAccept();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    decoration: BoxDecoration(
                      color: royalGold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ACCEPTER',
                      style: TextStyle(color: Color(0xFF001A33), fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }
}