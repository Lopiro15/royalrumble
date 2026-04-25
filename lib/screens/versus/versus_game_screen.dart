import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../stores/versus_store.dart';
import '../../services/settings_manager.dart';
import '../car_game/car_game_screen.dart';

class VersusGameScreen extends StatefulWidget {
  const VersusGameScreen({super.key});

  @override
  State<VersusGameScreen> createState() => _VersusGameScreenState();
}

class _VersusGameScreenState extends State<VersusGameScreen> {
  final VersusStore store = Get.find<VersusStore>();

  // État du jeu
  int? _myScore;
  bool _iAmDead = false;
  int? _opponentScore;
  bool _opponentIsDead = false;
  bool _resultShown = false;

  // État du replay
  bool _waitingReplay = false;
  bool _opponentWantsReplay = false;
  bool _replayTriggered = false;

  // Clé pour reconstruire le widget de jeu
  Key _gameKey = UniqueKey();

  @override
  void initState() {
    super.initState();

    // Le Store garde le contrôle des messages généraux
    // Mais on écoute les messages spécifiques au jeu
    store.bluetoothService.onMessageReceived = (message) {
      final type = message['type'] as String?;
      final data = message['data'] as Map<String, dynamic>?;

      if (type == 'carScore') {
        setState(() {
          _opponentScore = data?['score'] as int?;
          _opponentIsDead = data?['isDead'] as bool? ?? false;
        });

        if (_iAmDead && _opponentIsDead && !_resultShown) {
          _showResult();
        }
      }

      if (type == 'replayRequest') {
        debugPrint('🔄 Adversaire veut rejouer');
        setState(() => _opponentWantsReplay = true);
        _checkBothReadyToReplay();
      }

      if (type == 'replayAccepted') {
        debugPrint('🔄 Replay accepté, relancement !');
        _doRestartGame();
      }
    };
  }

  void _onMyGameFinished(int score, bool isDead) {
    if (_replayTriggered) return; // Ignorer si replay en cours

    _myScore = score;
    _iAmDead = isDead;

    store.bluetoothService.sendMessage({
      'type': 'carScore',
      'data': {'score': score, 'isDead': isDead},
    });

    if (_opponentIsDead && !_resultShown) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_resultShown) _showResult();
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
            side: BorderSide(
              color: isDraw ? Colors.orangeAccent : (won ? const Color(0xFFD4AF37) : Colors.redAccent),
              width: 2,
            ),
          ),
          title: Text(
            isDraw ? '🤝 MATCH NUL !' : (won ? '🏆 VICTOIRE !' : '😓 DÉFAITE...'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDraw ? Colors.orangeAccent : (won ? const Color(0xFFD4AF37) : Colors.redAccent),
              fontSize: 24,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDraw ? Icons.handshake_rounded : (won ? Icons.emoji_events : Icons.sentiment_dissatisfied),
                color: isDraw ? Colors.orangeAccent : (won ? const Color(0xFFD4AF37) : Colors.redAccent),
                size: 60,
              ),
              const SizedBox(height: 20),
              Text('VOUS: $myScore pts', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.bold)),
              Text('ADVERSAIRE: $oppScore pts', style: const TextStyle(color: Colors.blueAccent, fontSize: 20, fontWeight: FontWeight.bold)),
              if (isDraw) ...[
                const SizedBox(height: 12),
                const Text('⚡ Égalité ! Les deux joueurs doivent cliquer sur REJOUER.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 13),
                ),
                const SizedBox(height: 8),
                // Statut de l'adversaire
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _opponentWantsReplay ? Icons.check_circle : Icons.hourglass_empty,
                        color: _opponentWantsReplay ? Colors.greenAccent : Colors.white38,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _opponentWantsReplay ? 'Adversaire prêt !' : 'En attente de l\'adversaire...',
                        style: TextStyle(
                          color: _opponentWantsReplay ? Colors.greenAccent : Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _waitingReplay ? Icons.check_circle : Icons.hourglass_empty,
                        color: _waitingReplay ? Colors.greenAccent : Colors.white38,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _waitingReplay ? 'Vous êtes prêt !' : 'Cliquez sur REJOUER',
                        style: TextStyle(
                          color: _waitingReplay ? Colors.greenAccent : Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: _waitingReplay ? null : () {
                    debugPrint('🔄 Je veux rejouer !');
                    setDialogState(() => _waitingReplay = true);
                    store.bluetoothService.sendMessage({'type': 'replayRequest', 'data': {}});
                    _checkBothReadyToReplay();
                  },
                ),
              ),
            if (!isDraw)
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('CONTINUER'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF001A33),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    store.disconnectAndReset();
                    Get.until((route) => route.isFirst);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _checkBothReadyToReplay() {
    debugPrint('🔄 Check replay: moi=$_waitingReplay, adv=$_opponentWantsReplay');
    if (_waitingReplay && _opponentWantsReplay && !_replayTriggered) {
      _replayTriggered = true;
      debugPrint('🔄 Les deux sont prêts, envoi replayAccepted');
      store.bluetoothService.sendMessage({'type': 'replayAccepted', 'data': {}});
      _doRestartGame();
    }
  }

  void _doRestartGame() {
    debugPrint('🔄 Redémarrage du jeu !');
    // Fermer le dialog s'il est ouvert
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // Réinitialiser l'état
    setState(() {
      _myScore = null;
      _iAmDead = false;
      _opponentScore = null;
      _opponentIsDead = false;
      _resultShown = false;
      _waitingReplay = false;
      _opponentWantsReplay = false;
      _replayTriggered = false;
      _gameKey = UniqueKey(); // Nouvelle clé pour reconstruire le widget
    });
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
              content: const Text('Vous perdrez la partie.', style: TextStyle(color: Colors.white70)),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULER')),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    store.bluetoothService.sendMessage({'type': 'disconnect', 'data': {}});
                    store.disconnectAndReset();
                    Get.until((route) => route.isFirst);
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
            // Clé unique pour forcer la reconstruction du jeu
            CarGameScreen(
              key: _gameKey,
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
                    _opponentIsDead ? 'Adv: ${_opponentScore ?? "?"} pts ☠️' : 'Adv: en vie 🏎️',
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