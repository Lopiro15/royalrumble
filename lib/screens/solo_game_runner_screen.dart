import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../stores/solo_game_store.dart';
import '../widgets/solo_game_overlay.dart';
import '../widgets/solo_final_recap_overlay.dart';
import 'car_game/car_game_screen.dart';
import 'meteor_game/meteor_game_screen.dart';
import 'puzzle_game/puzzle_game_screen.dart';
import 'hanoi_game/hanoi_game_screen.dart';
import 'labyrinth_game/labyrinth_game_screen.dart';
import 'square_game/square_game_screen.dart';
import 'air_hockey/air_hockey_screen.dart';
import 'quiz/quiz_tutorial_screen.dart';

class SoloGameRunnerScreen extends StatefulWidget {
  const SoloGameRunnerScreen({super.key});

  @override
  State<SoloGameRunnerScreen> createState() => _SoloGameRunnerScreenState();
}

class _SoloGameRunnerScreenState extends State<SoloGameRunnerScreen> {
  final SoloGameStore store = Get.put(SoloGameStore());
  Widget? _currentGameWidget;

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  void _loadGame() {
    final gameName = store.currentGame;
    setState(() {
      _currentGameWidget = _getGameScreen(gameName);
    });
  }

  Widget _getGameScreen(String gameName) {
    switch (gameName) {
      case 'QUIZ':
        return QuizTutorialScreen(
          gameMode: 'solo',
          onSoloGameFinished: (score, maxScore) {
            store.recordGameResult(score: score, maxScore: maxScore);
          },
        );
      case 'CAR ROYAL':
        return CarGameScreen(
          onSoloGameFinished: (score, maxScore) {
            store.recordGameResult(score: score, maxScore: maxScore);
          },
        );
      case 'METEOR SHOWER':
        return MeteorGameScreen(
          onSoloGameFinished: (score, maxScore) {
            store.recordGameResult(score: score, maxScore: maxScore);
          },
        );
      case 'PUZZLE ROYAL':
        return PuzzleGameScreen(
          onSoloGameFinished: (score, maxScore) {
            store.recordGameResult(score: score, maxScore: maxScore);
          },
        );
      case 'TOUR D\'HANOI':
        return HanoiGameScreen(
          onSoloGameFinished: (score, maxScore) {
            store.recordGameResult(score: score, maxScore: maxScore);
          },
        );
      case 'LABYRINTH ROYAL':
        return LabyrinthGameScreen(
          onSoloGameFinished: (score, maxScore) {
            store.recordGameResult(score: score, maxScore: maxScore);
          },
        );
      case 'SQUARE CONQUEST':
        return SquareGameScreen(
          vsBot: true,
          onSoloGameFinished: (score, maxScore) {
            store.recordGameResult(score: score, maxScore: maxScore);
          },
        );
      case 'AIR HOCKEY':
        return AirHockeyScreen(
          vsBot: true,
          onSoloGameFinished: (score, maxScore) {
            store.recordGameResult(score: score, maxScore: maxScore);
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // Phase finale - Récapitulatif
        if (store.phase.value == SoloGamePhase.finished) {
          return SoloFinalRecapOverlay(
            store: store,
            onQuit: () => store.quitSoloMode(),
          );
        }

        // Jeu en cours
        return Stack(
          children: [
            // Le jeu actuel
            _currentGameWidget ?? const SizedBox.shrink(),

            // Overlay de transition entre les jeux
            if (store.phase.value == SoloGamePhase.playing && store.isGameFinished.value)
              SoloGameOverlay(
                store: store,
                onContinue: () {
                  store.nextGame();
                  if (store.phase.value == SoloGamePhase.playing) {
                    _loadGame();
                  }
                },
              ),
          ],
        );
      }),
    );
  }
}