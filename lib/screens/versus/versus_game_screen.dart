import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/settings_manager.dart';
import '../../stores/versus_store.dart';
import '../../services/versus/versus_game_manager.dart';
import '../car_game/car_game_screen.dart';
import '../meteor_game/meteor_game_screen.dart';
import '../puzzle_game/puzzle_game_screen.dart';
import '../hanoi_game/hanoi_game_screen.dart';
import '../square_game/square_game_screen.dart';
import '../air_hockey/air_hockey_screen.dart';
import '../quiz/quiz_tutorial_screen.dart';
import '../../widgets/versus/versus_round_result_overlay.dart';
import '../../widgets/versus/versus_final_result_screen.dart';

class VersusGameScreen extends StatefulWidget {
  const VersusGameScreen({super.key});

  @override
  State<VersusGameScreen> createState() => _VersusGameScreenState();
}

class _VersusGameScreenState extends State<VersusGameScreen> {
  final VersusStore store = Get.find<VersusStore>();
  Widget? _currentGameWidget;
  int? _myScore;
  int? _opponentScore;
  bool _hasFinished = false;

  @override
  void initState() {
    super.initState();
    _loadGame();

    // Écouter les résultats de l'adversaire
    _listenForOpponentResults();
  }

  void _listenForOpponentResults() {
    // Override temporaire du callback pour la partie en cours
    store.bluetoothService.onMessageReceived = (message) {
      final typeStr = message['type'] as String;
      if (typeStr == 'gameResult') {
        final data = message['data'] as Map<String, dynamic>;
        setState(() {
          _opponentScore = data['score'] as int;
        });
        _checkBothFinished();
      } else if (typeStr == 'playerWaiting') {
        // L'autre joueur attend
        _showWaitingOverlay();
      } else if (typeStr == 'playerFinished') {
        // L'autre joueur a terminé
        if (_myScore != null) {
          store.bluetoothService.sendMessage({
            'type': 'gameResult',
            'data': {'score': _myScore},
          });
        }
      } else if (typeStr == 'roundCompleted') {
        // Les deux joueurs ont envoyé leurs scores
        _resolveRound(message['data'] as Map<String, dynamic>);
      }
    };
  }

  void _showWaitingOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF001A33),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD4AF37)),
        ),
        title: const Text(
          'EN ATTENTE...',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFFD4AF37)),
            SizedBox(height: 16),
            Text(
              'Votre adversaire est encore en course...',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  void _loadGame() {
    final gameName = store.gameManager.value?.currentGameName ?? 'AIR HOCKEY';

    setState(() {
      _currentGameWidget = _getGameScreen(gameName);
      _myScore = null;
      _opponentScore = null;
      _hasFinished = false;
    });
  }

  Widget _getGameScreen(String gameName) {
    switch (gameName) {
      case 'QUIZ':
        return QuizTutorialScreen(
          gameMode: 'duo',
          onSoloGameFinished: (score, maxScore) {
            _onGameFinished(score);
          },
        );
      case 'CAR ROYAL':
        return CarGameScreen(
          onSoloGameFinished: (score, maxScore) {
            _onGameFinished(score);
          },
        );
      case 'METEOR SHOWER':
        return MeteorGameScreen(
          onSoloGameFinished: (score, maxScore) {
            _onGameFinished(score);
          },
        );
      case 'PUZZLE ROYAL':
        return PuzzleGameScreen(
          onSoloGameFinished: (score, maxScore) {
            _onGameFinished(score);
          },
        );
      case 'TOUR D\'HANOI':
        return HanoiGameScreen(
          onSoloGameFinished: (score, maxScore) {
            _onGameFinished(score);
          },
        );
      case 'SQUARE CONQUEST':
        return SquareGameScreen(
          vsBot: false,
          onSoloGameFinished: (score, maxScore) {
            _onGameFinished(score);
          },
        );
      case 'AIR HOCKEY':
        return AirHockeyScreen(
          vsBot: false,
          onSoloGameFinished: (score, maxScore) {
            _onGameFinished(score);
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _onGameFinished(int myScore) {
    if (_hasFinished) return;
    _hasFinished = true;

    setState(() {
      _myScore = myScore;
    });

    // Envoyer son score à l'adversaire
    store.bluetoothService.sendMessage({
      'type': 'gameResult',
      'data': {'score': myScore},
    });

    _checkBothFinished();
  }

  void _checkBothFinished() {
    if (_myScore != null && _opponentScore != null) {
      _resolveRound({
        'myScore': _myScore!,
        'opponentScore': _opponentScore!,
      });
    } else if (_myScore != null && _opponentScore == null) {
      // On a fini mais pas l'adversaire
      _showWaitingOverlay();
      store.bluetoothService.sendMessage({
        'type': 'playerWaiting',
        'data': {},
      });
    }
  }

  void _resolveRound(Map<String, dynamic> data) {
    // Fermer la popup d'attente si elle est ouverte
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    final myScore = data['myScore'] as int;
    final opponentScore = data['opponentScore'] as int;
    final won = myScore > opponentScore;

    final gameManager = store.gameManager.value!;
    gameManager.recordRoundWin(won);

    // Jouer le son approprié
    if (won) {
      settingsManager.playVictory();
    } else {
      settingsManager.playDefeat();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VersusRoundResultOverlay(
        won: won,
        myScore: myScore,
        opponentScore: opponentScore,
        myWins: gameManager.myWins,
        opponentWins: gameManager.opponentWins,
        winsNeeded: gameManager.config.winsNeeded,
        gameName: gameManager.currentGameName,
        onContinue: () {
          Navigator.pop(context);

          if (gameManager.isMatchOver.value) {
            Get.off(() => VersusFinalResultScreen(
              won: gameManager.amIWinner,
              myWins: gameManager.myWins,
              opponentWins: gameManager.opponentWins,
            ));
          } else {
            gameManager.currentRound.value++;
            _loadGame();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _currentGameWidget ?? const SizedBox.shrink(),

          // Score en haut
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() {
                if (store.gameManager.value == null) return const SizedBox.shrink();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildScoreChip('VOUS', store.gameManager.value!.myWins, const Color(0xFFD4AF37)),
                    Text(
                      'BO${store.gameManager.value!.config.totalRounds}',
                      style: const TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                    _buildScoreChip('ADV', store.gameManager.value!.opponentWins, Colors.blueAccent),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreChip(String label, int score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Text(
            '$label ',
            style: TextStyle(color: color.withOpacity(0.7), fontSize: 11),
          ),
          Text(
            '$score',
            style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}