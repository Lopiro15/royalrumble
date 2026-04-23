import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:royalrumble/screens/solo_game_runner_screen.dart';
import 'game_selection_screen.dart';
import '../services/settings_manager.dart';
import '../widgets/menu_button.dart';

class PlayMenuScreen extends StatelessWidget {
  const PlayMenuScreen({super.key});

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
                        Center(
                          child: Image.asset(
                            'assets/logo.png',
                            height: 150,
                          )
                              .animate(onPlay: (controller) => controller.repeat(reverse: true))
                              .moveY(begin: -5, end: 5, duration: 2000.ms, curve: Curves.easeInOut),
                        ),
                        const SizedBox(height: 30),
                        
                        _buildMenuSection(context, royalGold, primaryBlue),
                        
                        const Spacer(),
                        
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

  Widget _buildMenuSection(BuildContext context, Color gold, Color blue) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          MenuButton(
            label: 'SOLO',
            icon: Icons.person_rounded,
            color: gold,
            onTap: () {
              settingsManager.playClick();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SoloGameRunnerScreen()),
              );
            },
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
          const SizedBox(height: 15),
          MenuButton(
            label: 'VERSUS',
            icon: Icons.people_rounded,
            color: gold,
            onTap: () => settingsManager.playClick(),
          ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.2),
          const SizedBox(height: 15),
          MenuButton(
            label: 'ENTRAINEMENT',
            icon: Icons.fitness_center_rounded,
            color: gold,
            onTap: () {
              settingsManager.playClick();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GameSelectionScreen()),
              );
            },
          ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2),
          const SizedBox(height: 15),
          MenuButton(
            label: 'SCORES',
            icon: Icons.emoji_events_rounded,
            color: Colors.white.withOpacity(0.9),
            textColor: blue,
            onTap: () => settingsManager.playClick(),
          ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.2),
        ],
      ),
    );
  }
}
