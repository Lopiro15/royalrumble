import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:royalrumble/screens/play_menu_screen.dart';
import '../../stores/versus_store.dart';
import '../../services/settings_manager.dart';
import '../puzzle_game/puzzle_game_screen.dart';

class VersusGameScreen extends StatefulWidget {
  const VersusGameScreen({super.key});

  @override
  State<VersusGameScreen> createState() => _VersusGameScreenState();
}

class _VersusGameScreenState extends State<VersusGameScreen> {
  final VersusStore store = Get.find<VersusStore>();

  bool _roundEnded = false;
  bool _iFinished = false;
  int? _myScore;
  bool _opponentFinished = false;
  int? _opponentScore;
  bool _resultShown = false;

  // Disposition des tuiles synchronisée
  late final List<int> _syncedTiles;
  late final int _syncedSeed;

  String get _gameType => 'puzzleScore';

  @override
  void initState() {
    super.initState();

    // Générer une seed aléatoire commune
    _syncedSeed = DateTime.now().millisecond;
    _syncedTiles = _generateTilesFromSeed(_syncedSeed);

    _setupListener();

    // Envoyer la seed à l'adversaire pour qu'il ait la même disposition
    store.bluetoothService.sendMessage({
      'type': 'puzzleSetup',
      'data': {'seed': _syncedSeed},
    });
  }

  List<int> _generateTilesFromSeed(int seed) {
    final random = Random(seed);
    List<int> tiles = List.generate(9, (i) => i);
    int emptyIndex = 8;
    for (int i = 0; i < 200; i++) {
      List<int> validMoves = [];
      int row = emptyIndex ~/ 3;
      int col = emptyIndex % 3;
      if (row > 0) validMoves.add(emptyIndex - 3);
      if (row < 2) validMoves.add(emptyIndex + 3);
      if (col > 0) validMoves.add(emptyIndex - 1);
      if (col < 2) validMoves.add(emptyIndex + 1);
      int nextIndex = validMoves[random.nextInt(validMoves.length)];
      int temp = tiles[emptyIndex];
      tiles[emptyIndex] = tiles[nextIndex];
      tiles[nextIndex] = temp;
      emptyIndex = nextIndex;
    }
    return tiles;
  }

  void _setupListener() {
    store.bluetoothService.onMessageReceived = (message) {
      if (_roundEnded) return;

      final type = message['type'] as String?;
      final data = message['data'] as Map<String, dynamic>?;

      if (type == 'puzzleSetup') {
        // Recevoir la seed de l'adversaire
        final seed = data?['seed'] as int?;
        if (seed != null) {
          _syncedTiles = _generateTilesFromSeed(seed ?? 42);
          debugPrint('🧩 Puzzle synced with seed: $seed');
        }
      }

      if (type == _gameType) {
        setState(() {
          _opponentScore = data?['score'] as int?;
          _opponentFinished = data?['finished'] as bool? ?? false;
        });

        if (_opponentFinished && !_iFinished) {
          _roundEnded = true;
          _myScore ??= 0;
          _showResult();
        }

        if (_iFinished && _opponentFinished && !_resultShown) {
          _showResult();
        }
      }

      if (type == 'roundEnd' && !_roundEnded) {
        _roundEnded = true;
        _opponentScore = data?['score'] as int?;
        _opponentFinished = true;
        _myScore ??= 0;
        if (!_resultShown) _showResult();
      }
    };
  }

  void _onMyGameFinished(int score, bool isDead) {
    if (_roundEnded) return;

    _myScore = score;
    _iFinished = true;
    _roundEnded = true;

    store.bluetoothService.sendMessage({
      'type': 'roundEnd',
      'data': {'score': score},
    });

    store.bluetoothService.sendMessage({
      'type': _gameType,
      'data': {'score': score, 'finished': true},
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!_resultShown && mounted) _showResult();
    });
  }

  void _showResult() {
    if (_resultShown) return;
    _resultShown = true;

    final myScore = _myScore ?? 0;
    final oppScore = _opponentScore ?? 0;
    final iWon = _iFinished;

    if (iWon) {
      settingsManager.playVictory();
    } else {
      settingsManager.playDefeat();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF001A33),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: iWon ? const Color(0xFFD4AF37) : Colors.redAccent, width: 2),
        ),
        title: Text(
          iWon ? '🏆 VICTOIRE !' : '😓 DÉFAITE...',
          textAlign: TextAlign.center,
          style: TextStyle(color: iWon ? const Color(0xFFD4AF37) : Colors.redAccent, fontSize: 24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iWon ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                color: iWon ? const Color(0xFFD4AF37) : Colors.redAccent, size: 60),
            const SizedBox(height: 20),
            Text('VOUS: ${iWon ? "$myScore pts ✅" : "Pas fini ❌"}',
                style: TextStyle(color: iWon ? const Color(0xFFD4AF37) : Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold)),
            Text('ADVERSAIRE: ${_opponentFinished ? "${oppScore} pts" : "Pas fini"}',
                style: TextStyle(color: _opponentFinished ? Colors.blueAccent : Colors.white70, fontSize: 18)),
          ],
        ),
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
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    store.bluetoothService.sendMessage({'type': 'disconnect', 'data': {}});
                    store.disconnectAndReset();
                    Get.offAll(() => const PlayMenuScreen());
                  },
                  child: const Text('QUITTER', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            PuzzleGameScreen(
              forcedTiles: _syncedTiles,
              onVersusGameFinished: _onMyGameFinished,
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    _opponentFinished ? 'Adv: ${_opponentScore ?? "?"} pts ✅' : 'Adv: en cours 🧩',
                    style: TextStyle(color: _opponentFinished ? Colors.greenAccent : Colors.orangeAccent, fontSize: 11),
                  ),
                ),
              ),
            ),
            if (_roundEnded && !_iFinished)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Text('⏰ L\'adversaire a terminé !', style: TextStyle(color: Colors.orangeAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}