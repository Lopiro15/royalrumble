import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:royalrumble/screens/quiz/quiz_tutorial_screen.dart';
import 'car_game/car_game_screen.dart';
import 'meteor_game/meteor_game_screen.dart';
import 'puzzle_game/puzzle_game_screen.dart';
import 'hanoi_game/hanoi_game_screen.dart';
import 'labyrinth_game/labyrinth_game_screen.dart';
import 'square_game/square_game_screen.dart';
import 'air_hockey/air_hockey_screen.dart';
import '../services/settings_manager.dart';
import '../widgets/menu_button.dart';

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF001A33);
    const Color royalGold = Color(0xFFD4AF37);

    final List<Map<String, dynamic>> games = [
      {
        'label': 'CAR ROYAL',
        'icon': Icons.directions_car_rounded,
        'screen': const CarGameScreen(),
        'color': royalGold,
      },
      {
        'label': 'METEOR SHOWER',
        'icon': Icons.rocket_launch_rounded,
        'screen': const MeteorGameScreen(),
        'color': royalGold,
      },
      {
        'label': 'PUZZLE ROYAL',
        'icon': Icons.grid_on_rounded,
        'screen': const PuzzleGameScreen(),
        'color': royalGold,
      },
      {
        'label': 'TOUR D\'HANOI',
        'icon': Icons.layers_rounded,
        'screen': const HanoiGameScreen(),
        'color': royalGold,
      },
      {
        'label': 'LABYRINTH ROYAL',
        'icon': Icons.explore_rounded,
        'screen': const LabyrinthGameScreen(),
        'color': royalGold,
      },
      {
        'label': 'SQUARE CONQUEST',
        'icon': Icons.grid_view_rounded,
        'screen': const SquareGameScreen(vsBot: true, startsFirst: true,),
        'color': royalGold,
      },
      {
        'label': 'AIR HOCKEY',
        'icon': Icons.sports_hockey_rounded,
        'screen': const AirHockeyScreen(vsBot: true),
        'color': royalGold,
      },
      {
        'label': 'QUIZ ROYAL',
        'icon': Icons.quiz_rounded,
        'screen': const QuizTutorialScreen(gameMode: 'SOLO'),
        'color': Colors.white.withOpacity(0.9),
        'textColor': primaryBlue,
      },
    ];

    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('SÉLECTION DU JEU', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF002147), primaryBlue],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 20),
              itemCount: games.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final game = games[index];
                return MenuButton(
                  label: game['label'],
                  icon: game['icon'],
                  color: game['color'],
                  textColor: game['textColor'],
                  fontSize: 20,
                  onTap: () {
                    settingsManager.playClick();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => game['screen'] as Widget),
                    );
                  },
                ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: index % 2 == 0 ? -0.2 : 0.2);
              },
            ),
          ),
        ),
      ),
    );
  }
}
