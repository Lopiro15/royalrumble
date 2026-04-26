import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../stores/versus_store.dart';
import '../../services/settings_manager.dart';
import '../quiz/quiz_game_screen.dart';
import '../play_menu_screen.dart';

class VersusGameScreen extends StatefulWidget {
  const VersusGameScreen({super.key});

  @override
  State<VersusGameScreen> createState() => _VersusGameScreenState();
}

class _VersusGameScreenState extends State<VersusGameScreen> {
  final VersusStore store = Get.find<VersusStore>();

  bool _roundEnded = false;
  int? _myScore;
  DateTime? _myFinishTime;
  int? _opponentScore;
  DateTime? _opponentFinishTime;
  bool _resultShown = false;
  String _myName = '';
  String _opponentName = '';

  // Séquence de questions synchronisée (seed commune)
  late final List<int> _syncedSequence;
  late final int _syncedSeed;

  String get _gameType => 'quizScore';

  @override
  void initState() {
    super.initState();
    _myName = settingsManager.playerName;
    _opponentName = store.bluetoothService.connectedPlayer?.value?.name ?? 'Adversaire';

    // Générer une seed commune pour les mêmes questions
    _syncedSeed = (_myName + _opponentName).hashCode.abs();
    _syncedSequence = _generateSequenceFromSeed(_syncedSeed);

    _setupListener();

    // Envoyer la seed pour synchro
    store.bluetoothService.sendMessage({
      'type': 'quizSetup',
      'data': {'seed': _syncedSeed},
    });
  }

  List<int> _generateSequenceFromSeed(int seed) {
    final rand = Random(seed);
    final List<int> availableTypes = [0, 1, 2, 3, 4];
    final List<int> seq = List.from(availableTypes);
    while (seq.length < 10) {
      seq.add(availableTypes[rand.nextInt(availableTypes.length)]);
    }
    seq.shuffle(rand);
    return seq;
  }

  void _setupListener() {
    store.bluetoothService.onMessageReceived = (message) {
      if (_roundEnded) return;
      final type = message['type'] as String?;
      final data = message['data'] as Map<String, dynamic>?;

      if (type == 'quizSetup') {
        final seed = data?['seed'] as int?;
        if (seed != null && _syncedSequence.isEmpty) {
          _syncedSequence = _generateSequenceFromSeed(seed);
        }
      }

      if (type == _gameType) {
        _opponentScore = data?['score'] as int?;
        final finishMillis = data?['finishTime'] as int?;
        _opponentFinishTime = finishMillis != null ? DateTime.fromMillisecondsSinceEpoch(finishMillis) : null;

        if (_myScore != null && !_resultShown && mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!_resultShown && mounted) _showResult();
          });
        }
      }
    };
  }

  void _onMyGameFinished(int score, bool isDead) {
    if (_myScore != null) return;
    _myScore = score;
    _myFinishTime = DateTime.now();

    store.bluetoothService.sendMessage({
      'type': _gameType,
      'data': {
        'score': score,
        'finishTime': _myFinishTime!.millisecondsSinceEpoch,
      },
    });

    if (_opponentScore != null && !_resultShown && mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_resultShown && mounted) _showResult();
      });
    }
  }

  void _showResult() {
    if (_resultShown) return;
    _resultShown = true;

    final myScore = _myScore ?? 0;
    final oppScore = _opponentScore ?? 0;

    bool won;
    if (myScore > oppScore) {
      won = true;
    } else if (oppScore > myScore) {
      won = false;
    } else {
      // Égalité : le premier qui a fini gagne
      if (_myFinishTime != null && _opponentFinishTime != null) {
        won = _myFinishTime!.isBefore(_opponentFinishTime!);
      } else if (_myFinishTime != null) {
        won = true; // J'ai fini, pas l'autre
      } else {
        won = false;
      }
    }

    if (won) {
      settingsManager.playVictory();
    } else {
      settingsManager.playDefeat();
    }

    String myTime = _myFinishTime != null ? '${_myFinishTime!.minute}:${_myFinishTime!.second.toString().padLeft(2, '0')}' : 'En cours';
    String oppTime = _opponentFinishTime != null ? '${_opponentFinishTime!.minute}:${_opponentFinishTime!.second.toString().padLeft(2, '0')}' : 'En cours';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF001A33),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: won ? const Color(0xFFD4AF37) : Colors.redAccent, width: 2),
        ),
        title: Text(won ? '🏆 VICTOIRE !' : '😓 DÉFAITE...', textAlign: TextAlign.center,
            style: TextStyle(color: won ? const Color(0xFFD4AF37) : Colors.redAccent, fontSize: 24)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(won ? Icons.emoji_events : Icons.sentiment_dissatisfied,
              color: won ? const Color(0xFFD4AF37) : Colors.redAccent, size: 60),
          const SizedBox(height: 20),
          Text('$_myName (🟡): $myScore pts ($myTime)',
              style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold)),
          Text('$_opponentName (🔵): $oppScore pts ($oppTime)',
              style: const TextStyle(color: Colors.blueAccent, fontSize: 16)),
          if (myScore == oppScore) ...[
            const SizedBox(height: 8),
            Text(won ? '⚡ Victoire au temps !' : '⚡ Défaite au temps...',
                style: TextStyle(color: won ? Colors.greenAccent : Colors.redAccent, fontSize: 13)),
          ],
        ]),
        actions: [
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('CONTINUER'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF001A33)),
              onPressed: () {
                Navigator.pop(ctx);
                store.disconnectAndReset();
                Get.offAll(() => const PlayMenuScreen());
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF001A33),
              title: const Text('Quitter ?', style: TextStyle(color: Colors.white)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULER')),
                TextButton(onPressed: () { Navigator.pop(ctx); store.bluetoothService.sendMessage({'type': 'disconnect', 'data': {}}); store.disconnectAndReset(); Get.offAll(() => const PlayMenuScreen()); }, child: const Text('QUITTER', style: TextStyle(color: Colors.redAccent))),
              ],
            ),
          );
        }
      },
      child: QuizGameScreen(
        gameMode: 'duo',
        onVersusGameFinished: _onMyGameFinished,
        forcedSequence: _syncedSequence,
      ),
    );
  }
}