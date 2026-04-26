import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../stores/versus_store.dart';
import '../../services/settings_manager.dart';
import '../car_game/car_game_screen.dart';
import '../meteor_game/meteor_game_screen.dart';
import '../puzzle_game/puzzle_game_screen.dart';
import '../hanoi_game/hanoi_game_screen.dart';
import '../square_game/square_game_screen.dart';
import '../air_hockey/air_hockey_screen.dart';
import '../quiz/quiz_tutorial_screen.dart';

class VersusGameScreen extends StatefulWidget {
  final String gameName;
  const VersusGameScreen({super.key, required this.gameName});

  @override
  State<VersusGameScreen> createState() => _VersusGameScreenState();
}

class _VersusGameScreenState extends State<VersusGameScreen> {
  final VersusStore store = Get.find<VersusStore>();

  int? _myScore;
  int? _opponentScore;
  bool _iFinished = false;
  bool _opponentFinished = false;
  String _myName = '';
  String _opponentName = '';

  String get _gameType {
    switch (widget.gameName) {
      case 'CAR ROYAL': return 'carScore';
      case 'METEOR SHOWER': return 'meteorScore';
      case 'PUZZLE ROYAL': return 'puzzleScore';
      case 'TOUR D\'HANOI': return 'hanoiScore';
      case 'SQUARE CONQUEST': return 'squareScore';
      case 'AIR HOCKEY': return 'airHockeyScore';
      case 'QUIZ': return 'quizScore';
      default: return 'carScore';
    }
  }

  @override
  void initState() {
    super.initState();
    _myName = settingsManager.playerName;
    _opponentName = store.bluetoothService.connectedPlayer?.value?.name ?? 'Adversaire';
    _setupListener();
  }

  void _setupListener() {
    store.bluetoothService.onMessageReceived = (message) {
      final type = message['type'] as String?;
      final data = message['data'] as Map<String, dynamic>?;

      if (type == _gameType) {
        debugPrint('📩 Score adverse reçu: ${data?['score']}');
        _opponentScore = data?['score'] as int?;
        _opponentFinished = true;

        if (_iFinished && _opponentFinished) {
          _finishRound();
        }
      }
    };
  }

  void _onMyGameFinished(int score, [bool? isDead, int? goalsFor, int? goalsAgainst]) {
    if (_iFinished) return;
    _myScore = score;
    _iFinished = true;

    debugPrint('🏁 J\'ai fini - Score: $score');

    // Envoyer mon score
    final msg = <String, dynamic>{
      'type': _gameType,
      'data': {'score': score, 'finished': true},
    };
    store.bluetoothService.sendMessage(msg);

    if (_opponentFinished) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _finishRound();
      });
    }
  }

  void _finishRound() {
    final myScore = _myScore ?? 0;
    final oppScore = _opponentScore ?? 0;
    final isHost = store.gameManager?.value?.isHost ?? true;

    debugPrint('📊 Comparaison - Moi: $myScore, Adv: $oppScore');

    // Déterminer le gagnant
    bool hostWon;

    switch (widget.gameName) {
      case 'CAR ROYAL':
      case 'METEOR SHOWER':
      case 'AIR HOCKEY':
        hostWon = myScore > oppScore;
        break;
      case 'TOUR D\'HANOI':
      case 'PUZZLE ROYAL':
      case 'QUIZ':
        hostWon = myScore >= oppScore; // Course/quiz : premier ou meilleur score
        break;
      case 'SQUARE CONQUEST':
        hostWon = myScore > oppScore;
        break;
      default:
        hostWon = myScore > oppScore;
    }

    debugPrint('📊 hostWon: $hostWon (isHost: $isHost)');

    store.onRoundFinished(
      hostWon: hostWon,
      hostScore: isHost ? myScore : oppScore,
      guestScore: isHost ? oppScore : myScore,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Routeur de jeu
    switch (widget.gameName) {
      case 'CAR ROYAL':
        return CarGameScreen(onVersusGameFinished: (score, isDead) => _onMyGameFinished(score, isDead));
      case 'METEOR SHOWER':
        return MeteorGameScreen(onVersusGameFinished: (score, isDead) => _onMyGameFinished(score, isDead));
      case 'PUZZLE ROYAL':
        return PuzzleGameScreen(onVersusGameFinished: (score, isDead) => _onMyGameFinished(score, isDead));
      case 'TOUR D\'HANOI':
        return HanoiGameScreen(onVersusGameFinished: (score, isDead) => _onMyGameFinished(score, isDead));
      case 'SQUARE CONQUEST':
        return SquareGameScreen(
          vsBot: false,
          isVersusMode: true,
          startsFirst: _myName.compareTo(_opponentName) <= 0,
          myName: _myName,
          opponentName: _opponentName,
          isMyTurn: _myName.compareTo(_opponentName) <= 0,
          onVersusGameFinished: (score, isDead) => _onMyGameFinished(score, isDead),
          onMoveMade: (row, col) {
            store.bluetoothService.sendMessage({'type': 'squareMove', 'data': {'row': row, 'col': col}});
          },
        );
      case 'AIR HOCKEY':
        return AirHockeyScreen(vsBot: true, onVersusGameFinished: (score, isDead, goalsFor, goalsAgainst) => _onMyGameFinished(score, isDead));
      case 'QUIZ':
        return QuizTutorialScreen(gameMode: 'duo', onSoloGameFinished: (score, maxScore) => _onMyGameFinished(score));
      default:
        return const Center(child: Text('Jeu inconnu', style: TextStyle(color: Colors.white)));
    }
  }
}