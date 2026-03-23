import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/settings_manager.dart';
import '../widgets/menu_button.dart';
import 'game_menu_screen.dart'; // GameMenuScreen est dans screens/, pas dans screens/quiz/
import 'scores_screen.dart';   // Page des meilleurs scores

// ---------------------------------------------------------------------------
// PlayMenuScreen — Sélection du mode de jeu
//
// SOLO / VERSUS / ENTRAÎNEMENT → naviguent vers GameMenuScreen(gameMode)
// SCORES → à implémenter ultérieurement
// ---------------------------------------------------------------------------
class PlayMenuScreen extends StatelessWidget {
  const PlayMenuScreen({super.key});

  // Construit la page complète : fond dégradé, logo animé,
  // les 4 boutons de mode, et le bouton retour menu principal.
  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF001A33);
    const Color royalGold = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: primaryBlue,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF002147), primaryBlue],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Logo animé (identique aux autres écrans)
                        Center(
                          child: Image.asset('assets/logo.png', height: 150)
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .moveY(begin: -5, end: 5, duration: 2000.ms, curve: Curves.easeInOut),
                        ),

                        const SizedBox(height: 30),

                        _buildMenuSection(context, royalGold, primaryBlue),

                        const Spacer(),

                        // Bouton retour
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                          child: MenuButton(
                            label: 'MENU PRINCIPAL',
                            icon: Icons.arrow_back_rounded,
                            color: Colors.redAccent.withOpacity(0.8),
                            fontSize: 18,
                            onTap: () {
                              settingsManager.playClick();
                              Navigator.pop(context);
                            },
                          ).animate().fadeIn(delay: 1000.ms),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Construit la colonne des 4 boutons de mode de jeu.
  // Chaque bouton est animé avec un slide et un fadeIn décalé.
  Widget _buildMenuSection(BuildContext context, Color gold, Color blue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          MenuButton(
            label: 'SOLO',
            icon: Icons.person_rounded,
            color: gold,
            onTap: () => _goToGameMenu(context, 'solo'),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),

          const SizedBox(height: 15),

          MenuButton(
            label: 'VERSUS',
            icon: Icons.people_rounded,
            color: gold,
            onTap: () => _goToGameMenu(context, 'duo'),
          ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2),

          const SizedBox(height: 15),

          MenuButton(
            label: 'ENTRAINEMENT',
            icon: Icons.fitness_center_rounded,
            color: gold,
            onTap: () => _goToGameMenu(context, 'entrainement'),
          ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2),

          const SizedBox(height: 15),

          MenuButton(
            label: 'SCORES',
            icon: Icons.emoji_events_rounded,
            color: Colors.white.withOpacity(0.9),
            textColor: blue,
            onTap: () {
              settingsManager.playClick();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScoresScreen()),
              );
            },
          ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.2),
        ],
      ),
    );
  }

  // Joue le son de clic puis navigue vers GameMenuScreen
  // en lui transmettant le mode de jeu choisi (solo / duo / entrainement).
  void _goToGameMenu(BuildContext context, String mode) {
    settingsManager.playClick();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameMenuScreen(gameMode: mode)),
    );
  }
}