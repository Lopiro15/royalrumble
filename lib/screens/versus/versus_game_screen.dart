import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:royalrumble/screens/play_menu_screen.dart';
import '../../stores/versus_store.dart';
import '../../services/settings_manager.dart';
import '../hanoi_game/hanoi_game_screen.dart';

class VersusGameScreen extends StatefulWidget {
  const VersusGameScreen({super.key});

  @override
  State<VersusGameScreen> createState() => _VersusGameScreenState();
}

class _VersusGameScreenState extends State<VersusGameScreen> {
  final VersusStore store = Get.find<VersusStore>();

  bool _roundEnded = false; // Flag pour arrêter tout
  bool _iFinished = false;
  int? _myScore;
  bool _opponentFinished = false;
  int? _opponentScore;
  bool _resultShown = false;

  final int _numDisks = 5;

  String get _gameType => 'hanoiScore';

  @override
  void initState() {
    super.initState();
    _setupListener();

    store.bluetoothService.sendMessage({
      'type': 'hanoiSetup',
      'data': {'numDisks': _numDisks},
    });
  }

  void _setupListener() {
    store.bluetoothService.onMessageReceived = (message) {
      if (_roundEnded) return; // Ignorer tout si le round est terminé

      final type = message['type'] as String?;
      final data = message['data'] as Map<String, dynamic>?;

      if (type == _gameType) {
        setState(() {
          _opponentScore = data?['score'] as int?;
          _opponentFinished = data?['finished'] as bool? ?? false;
        });

        // L'adversaire a fini → arrêter immédiatement
        if (_opponentFinished && !_iFinished) {
          _roundEnded = true;
          _myScore = data?['myScore'] as int? ?? 0; // Score forcé si on n'a pas fini
          _showResult();
        }

        // Les deux ont fini
        if (_iFinished && _opponentFinished && !_resultShown) {
          _showResult();
        }
      }

      // Message de fin de round forcé
      if (type == 'roundEnd' && !_roundEnded) {
        _roundEnded = true;
        _opponentScore = data?['score'] as int?;
        _opponentFinished = true;
        // Forcer notre score actuel (0 si pas fini)
        _myScore ??= 0;
        if (!_resultShown) _showResult();
      }
    };
  }

  void _onMyGameFinished(int score, bool isDead) {
    if (_roundEnded) return;

    _myScore = score;
    _iFinished = true;
    _roundEnded = true; // J'ai fini, le round est terminé

    // Envoyer mon score ET forcer la fin du round chez l'adversaire
    store.bluetoothService.sendMessage({
      'type': 'roundEnd', // Message prioritaire pour arrêter l'autre
      'data': {'score': score},
    });

    store.bluetoothService.sendMessage({
      'type': _gameType,
      'data': {'score': score, 'finished': true},
    });

    // Attendre un peu puis afficher le résultat
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!_resultShown && mounted) _showResult();
    });
  }

  void _showResult() {
    if (_resultShown) return;
    _resultShown = true;

    final myScore = _myScore ?? 0;
    final oppScore = _opponentScore ?? 0;
    final iWon = _iFinished; // Celui qui a fini en premier gagne

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
            HanoiGameScreen(
              forcedNumDisks: _numDisks,
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
                    _opponentFinished ? 'Adv: ${_opponentScore ?? "?"} pts ✅' : 'Adv: en cours 🧠',
                    style: TextStyle(color: _opponentFinished ? Colors.greenAccent : Colors.orangeAccent, fontSize: 11),
                  ),
                ),
              ),
            ),
            // Overlay "L'adversaire a gagné !" si on n'a pas fini
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