import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../services/settings_manager.dart';
import '../../stores/versus_store.dart';
import '../../services/bluetooth/bluetooth_game_handler.dart';
import '../../widgets/menu_button.dart';

class VersusSetupScreen extends StatefulWidget {
  final bool isHost;

  const VersusSetupScreen({super.key, required this.isHost});

  @override
  State<VersusSetupScreen> createState() => _VersusSetupScreenState();
}

class _VersusSetupScreenState extends State<VersusSetupScreen> {
  @override
  Widget build(BuildContext context) {
    final VersusStore store = Get.find<VersusStore>();
    const Color primaryBlue = Color(0xFF001A33);
    const Color royalGold = Color(0xFFD4AF37);

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
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isHost) ...[
                    // L'hôte choisit la configuration
                    const Icon(Icons.sports_kabaddi_rounded, color: royalGold, size: 80)
                        .animate()
                        .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 500.ms),

                    const SizedBox(height: 24),

                    Text(
                      'DÉFI ACCEPTÉ !',
                      style: TextStyle(color: royalGold, fontSize: 28, letterSpacing: 3),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 8),

                    const Text(
                      'Choisissez le format',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),

                    const SizedBox(height: 40),

                    // Options de manches
                    _buildConfigOption(
                      'BO3',
                      'Premier à 2 victoires',
                      'Le meilleur des 3 manches',
                      Icons.looks_3_rounded,
                      royalGold,
                          () {
                        settingsManager.playClick();
                        store.hostConfirmSetup(VersusGameConfig.bestOf3);
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildConfigOption(
                      'BO5',
                      'Premier à 3 victoires',
                      'Le meilleur des 5 manches',
                      Icons.looks_5_rounded,
                      royalGold,
                          () {
                        settingsManager.playClick();
                        store.hostConfirmSetup(VersusGameConfig.bestOf5);
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildConfigOption(
                      'BO7',
                      'Premier à 4 victoires',
                      'Le meilleur des 7 manches',
                      Icons.looks_6_rounded,
                      royalGold,
                          () {
                        settingsManager.playClick();
                        store.hostConfirmSetup(VersusGameConfig.bestOf7);
                      },
                    ),

                    const SizedBox(height: 30),

                    MenuButton(
                      label: 'ANNULER',
                      icon: Icons.close_rounded,
                      color: Colors.redAccent.withOpacity(0.8),
                      fontSize: 18,
                      onTap: () {
                        settingsManager.playClick();
                        store.rejectChallenge();
                        Get.back();
                      },
                    ),
                  ] else ...[
                    // L'invité attend que l'hôte configure
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        color: royalGold,
                        strokeWidth: 3,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Configuration en cours...',
                      style: TextStyle(color: royalGold, fontSize: 20, letterSpacing: 2),
                    ).animate().fadeIn(),

                    const SizedBox(height: 8),

                    const Text(
                      'L\'hôte choisit le format de la partie',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfigOption(
      String title,
      String subtitle,
      String description,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF002147),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 20),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2);
  }
}