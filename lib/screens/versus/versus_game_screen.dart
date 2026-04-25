import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:royalrumble/screens/play_menu_screen.dart';
import 'package:royalrumble/screens/versus/versus_lobby_screen.dart';
import '../../stores/versus_store.dart';
import '../../services/settings_manager.dart';
import '../meteor_game/meteor_game_screen.dart';

class VersusGameScreen extends StatefulWidget {
  const VersusGameScreen({super.key});

  @override
  State<VersusGameScreen> createState() => _VersusGameScreenState();
}

class _VersusGameScreenState extends State<VersusGameScreen> {
  final VersusStore store = Get.find<VersusStore>();

  int? _myScore;
  bool _iAmDead = false;
  int? _opponentScore;
  bool _opponentIsDead = false;
  bool _resultShown = false;
  bool _waitingReplay = false;
  bool _opponentWantsReplay = false;

  String get _gameType => 'meteorScore';

  @override
  void initState() {
    super.initState();
    _setupListener();
  }

  void _setupListener() {
    store.bluetoothService.onMessageReceived = (message) {
      final type = message['type'] as String?;
      final data = message['data'] as Map<String, dynamic>?;

      if (type == _gameType && mounted) {
        setState(() {
          _opponentScore = data?['score'] as int?;
          _opponentIsDead = data?['isDead'] as bool? ?? false;
        });
        if (_iAmDead && _opponentIsDead && !_resultShown) _showResult();
      }

      if (type == 'replayRequest' && mounted) {
        setState(() => _opponentWantsReplay = true);
        if (_waitingReplay && _opponentWantsReplay) _bothReady();
      }

      if (type == 'replayAccepted' && mounted) {
        _restartGame();
      }
    };
  }

  void _onMyGameFinished(int score, bool isDead) {
    _myScore = score;
    _iAmDead = isDead;

    store.bluetoothService.sendMessage({
      'type': _gameType,
      'data': {'score': score, 'isDead': isDead},
    });

    if (_opponentIsDead && !_resultShown) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_resultShown && mounted) _showResult();
      });
    }
  }

  void _showResult() {
    _resultShown = true;

    final myScore = _myScore ?? 0;
    final oppScore = _opponentScore ?? 0;
    final isDraw = myScore == oppScore;
    final won = myScore > oppScore;

    if (isDraw) {
      settingsManager.playClick();
    } else if (won) {
      settingsManager.playVictory();
    } else {
      settingsManager.playDefeat();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF001A33),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: isDraw ? Colors.orangeAccent : (won ? const Color(0xFFD4AF37) : Colors.redAccent), width: 2),
          ),
          title: Text(isDraw ? '🤝 MATCH NUL !' : (won ? '🏆 VICTOIRE !' : '😓 DÉFAITE...'),
            textAlign: TextAlign.center,
            style: TextStyle(color: isDraw ? Colors.orangeAccent : (won ? const Color(0xFFD4AF37) : Colors.redAccent), fontSize: 24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isDraw ? Icons.handshake_rounded : (won ? Icons.emoji_events : Icons.sentiment_dissatisfied),
                  color: isDraw ? Colors.orangeAccent : (won ? const Color(0xFFD4AF37) : Colors.redAccent), size: 60),
              const SizedBox(height: 20),
              Text('VOUS: $myScore pts', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.bold)),
              Text('ADVERSAIRE: $oppScore pts', style: const TextStyle(color: Colors.blueAccent, fontSize: 20, fontWeight: FontWeight.bold)),
              if (isDraw) ...[
                const SizedBox(height: 16),
                _chip('Vous', _waitingReplay),
                const SizedBox(height: 4),
                _chip('Adversaire', _opponentWantsReplay),
              ],
            ],
          ),
          actions: [
            if (isDraw)
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(_waitingReplay ? Icons.check_circle : Icons.replay_rounded),
                  label: Text(_waitingReplay ? 'EN ATTENTE...' : 'REJOUER'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _waitingReplay ? Colors.grey : Colors.orangeAccent,
                    foregroundColor: const Color(0xFF001A33),
                  ),
                  onPressed: _waitingReplay ? null : () {
                    setState(() => _waitingReplay = true);
                    setDialogState(() {});
                    store.bluetoothService.sendMessage({'type': 'replayRequest', 'data': {}});
                    if (_opponentWantsReplay) _bothReady();
                  },
                ),
              ),
            if (!isDraw)
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
      ),
    );
  }

  Widget _chip(String label, bool ready) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(ready ? Icons.check_circle : Icons.hourglass_empty, color: ready ? Colors.greenAccent : Colors.white38, size: 16),
        const SizedBox(width: 6),
        Text('$label : ${ready ? "Prêt !" : "En attente..."}', style: TextStyle(color: ready ? Colors.greenAccent : Colors.white54, fontSize: 12)),
      ]),
    );
  }

  void _bothReady() {
    store.bluetoothService.sendMessage({'type': 'replayAccepted', 'data': {}});
    _restartGame();
  }

  void _restartGame() {
    // Fermer la popup
    if (Navigator.canPop(context)) Navigator.pop(context);

    // Remplacer l'écran entier par un nouveau (propre)
    Get.off(() => const VersusGameScreen());
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
                    Get.offAll(() => const VersusLobbyScreen());
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
            MeteorGameScreen(onVersusGameFinished: _onMyGameFinished),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    _opponentIsDead ? 'Adv: ${_opponentScore ?? "?"} pts ☠️' : 'Adv: en vie 🛸',
                    style: TextStyle(color: _opponentIsDead ? Colors.redAccent : Colors.greenAccent, fontSize: 11),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}