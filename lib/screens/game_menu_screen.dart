import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/settings_manager.dart';
import '../widgets/menu_button.dart';
import '../widgets/game_menu_card.dart'; // hors dossier quiz : sert à tous les jeux
import 'quiz/quiz_tutorial_screen.dart'; // Le tutoriel précède toujours la partie

// ---------------------------------------------------------------------------
// GameMenuScreen — Menu de sélection du jeu à lancer
//
// Écran intermédiaire entre PlayMenuScreen et les mini-jeux.
// Reçoit le mode de jeu (solo / duo / entrainement) et liste les jeux dispo.
// Pour ajouter un jeu : ajouter une entrée dans _games + un case dans _launchGame().
// ---------------------------------------------------------------------------
class GameMenuScreen extends StatelessWidget {
  /// Mode transmis depuis PlayMenuScreen : 'solo', 'duo', 'entrainement'
  final String gameMode;

  const GameMenuScreen({super.key, required this.gameMode});

  // Catalogue des mini-jeux disponibles dans l'application.
  // isAvailable: false = carte grisée avec badge "BIENTÔT"
  static const List<Map<String, dynamic>> _games = [
    {
      'title': 'QUIZ',
      'description': '10 questions, 5 types de défis mélangés',
      'icon': Icons.quiz_rounded,
      'accentColor': Color(0xFFD4AF37), // or royal
      'isAvailable': true,
    },
    // Futurs jeux à débloquer :
    // { 'title': 'MEMORY', 'description': '...', 'icon': Icons.grid_on, 'accentColor': Color(0xFF...), 'isAvailable': false },
    // { 'title': 'RAPIDFIRE', 'description': '...', 'icon': Icons.bolt, 'accentColor': Color(0xFF...), 'isAvailable': false },
  ];

  // Construit l'écran complet : fond dégradé, en-tête, liste des jeux, bouton retour.
  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF001A33);
    const Color royalGold = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: primaryBlue,
      body: Container(
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
              const SizedBox(height: 30),

              // Titre + badge du mode de jeu
              _buildHeader(royalGold),

              const SizedBox(height: 40),

              // Liste des jeux disponibles
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  itemCount: _games.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final game = _games[index];
                    return GameMenuCard(
                      title: game['title'] as String,
                      description: game['description'] as String,
                      icon: game['icon'] as IconData,
                      accentColor: game['accentColor'] as Color,
                      isAvailable: game['isAvailable'] as bool,
                      animationDelay: (index * 150).ms,
                      onTap: (game['isAvailable'] as bool)
                          ? () => _launchGame(context, index)
                          : null,
                    );
                  },
                ),
              ),

              // Bouton retour
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                child: MenuButton(
                  label: 'RETOUR',
                  icon: Icons.arrow_back_rounded,
                  color: Colors.redAccent.withOpacity(0.8),
                  fontSize: 20,
                  onTap: () {
                    settingsManager.playClick();
                    Navigator.pop(context);
                  },
                ).animate().fadeIn(delay: 500.ms),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Construit l'en-tête de l'écran :
  // - un badge doré affichant le mode actif (ex: "MODE SOLO")
  // - le titre principal "CHOISIR UN JEU"
  Widget _buildHeader(Color gold) {
    // Libellé lisible du mode
    final String modeLabel = gameMode.toUpperCase();

    return Column(
      children: [
        // Badge du mode actif
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: gold.withOpacity(0.12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: gold.withOpacity(0.4)),
          ),
          child: Text(
            'MODE $modeLabel',
            style: TextStyle(
              color: gold,
              fontSize: 13,
              letterSpacing: 2,
            ),
          ),
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 14),

        // Titre principal
        const Text(
          'CHOISIR UN JEU',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            letterSpacing: 3,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2),
      ],
    );
  }

  // Navigue vers l'écran du jeu sélectionné en passant le gameMode.
  // Le switch permet d'ajouter facilement de nouveaux jeux (case 1, case 2...).
  void _launchGame(BuildContext context, int index) {
    settingsManager.playClick();
    switch (index) {
      case 0: // Quiz → passe d'abord par le tutoriel
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizTutorialScreen(gameMode: gameMode),
          ),
        );
        break;
      // Futurs jeux : ajouter un case ici
      default:
        break;
    }
  }
}