import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../stores/versus_store.dart';
import '../../services/settings_manager.dart';
import '../air_hockey/air_hockey_screen.dart';
import '../play_menu_screen.dart';

class VersusGameScreen extends StatefulWidget {
  const VersusGameScreen({super.key});

  @override
  State<VersusGameScreen> createState() => _VersusGameScreenState();
}

class _VersusGameScreenState extends State<VersusGameScreen> {
  final VersusStore store = Get.find<VersusStore>();

  int? _myScore;
  bool _iBeatBot = false;
  int _myGoalsFor = 0;
  int _myGoalsAgainst = 0;

  int? _opponentScore;
  bool _opponentBeatBot = false;
  int _opponentGoalsFor = 0;
  int _opponentGoalsAgainst = 0;

  bool _resultShown = false;
  bool _waitingReplay = false;
  bool _opponentWantsReplay = false;
  String _myName = '';
  String _opponentName = '';

  Key _gameKey = UniqueKey();
  String get _gameType => 'airHockeyScore';

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
        _opponentScore = data?['score'] as int?;
        _opponentBeatBot = data?['beatBot'] as bool? ?? false;
        _opponentGoalsFor = data?['goalsFor'] as int? ?? 0;
        _opponentGoalsAgainst = data?['goalsAgainst'] as int? ?? 0;

        if (_myScore != null && _opponentScore != null && !_resultShown && mounted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!_resultShown && mounted) _showResult();
          });
        }
      }

      if (type == 'replayRequest') {
        debugPrint('🔄 replayRequest reçu de l\'adversaire');
        _opponentWantsReplay = true;
        if (_waitingReplay) {
          debugPrint('🔄 Les deux veulent rejouer !');
          _bothReady();
        } else {
          // Mettre à jour l'UI pour montrer que l'adversaire est prêt
          if (mounted) setState(() {});
        }
      }

      if (type == 'replayAccepted') {
        debugPrint('🔄 replayAccepted reçu');
        _restartGame();
      }
    };
  }

  void _onMyGameFinished(int score, bool isDead, int goalsFor, int goalsAgainst) {
    if (_myScore != null) return;
    _myScore = score;
    _iBeatBot = !isDead;
    _myGoalsFor = goalsFor;
    _myGoalsAgainst = goalsAgainst;

    store.bluetoothService.sendMessage({
      'type': _gameType,
      'data': {
        'score': score,
        'beatBot': _iBeatBot,
        'goalsFor': goalsFor,
        'goalsAgainst': goalsAgainst,
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
    final myDiff = _myGoalsFor - _myGoalsAgainst;
    final oppDiff = _opponentGoalsFor - _opponentGoalsAgainst;

    String resultText;
    IconData resultIcon;
    Color resultColor;
    bool isDraw = false;
    bool won = false;

    if (_iBeatBot && !_opponentBeatBot) {
      won = true;
    } else if (!_iBeatBot && _opponentBeatBot) {
      won = false;
    } else if (_iBeatBot && _opponentBeatBot) {
      if (myDiff > oppDiff) {
        won = true;
      } else if (oppDiff > myDiff) {
        won = false;
      } else if (myScore > oppScore) {
        won = true;
      } else if (oppScore > myScore) {
        won = false;
      } else {
        isDraw = true;
      }
    } else {
      if (myDiff > oppDiff) {
        won = true;
      } else if (oppDiff > myDiff) {
        won = false;
      } else if (myScore > oppScore) {
        won = true;
      } else if (oppScore > myScore) {
        won = false;
      } else {
        isDraw = true;
      }
    }

    if (won) {
      resultText = '🏆 VICTOIRE !';
      resultIcon = Icons.emoji_events;
      resultColor = const Color(0xFFD4AF37);
      settingsManager.playVictory();
    } else if (isDraw) {
      resultText = '🤝 MATCH NUL !';
      resultIcon = Icons.handshake_rounded;
      resultColor = Colors.orangeAccent;
      settingsManager.playClick();
    } else {
      resultText = '😓 DÉFAITE...';
      resultIcon = Icons.sentiment_dissatisfied;
      resultColor = Colors.redAccent;
      settingsManager.playDefeat();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF001A33),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: resultColor, width: 2)),
          title: Text(resultText, textAlign: TextAlign.center, style: TextStyle(color: resultColor, fontSize: 24)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(resultIcon, color: resultColor, size: 60),
            const SizedBox(height: 20),
            _playerRow(_myName, '🟡', myScore, _iBeatBot, myDiff),
            const SizedBox(height: 8),
            _playerRow(_opponentName, '🔵', oppScore, _opponentBeatBot, oppDiff),
            if (isDraw) ...[
              const SizedBox(height: 16),
              _chip('Vous', _waitingReplay),
              const SizedBox(height: 4),
              _chip('Adversaire', _opponentWantsReplay),
            ],
          ]),
          actions: [
            if (isDraw)
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(_waitingReplay ? Icons.check_circle : Icons.replay_rounded),
                  label: Text(_waitingReplay ? 'EN ATTENTE...' : 'REJOUER'),
                  style: ElevatedButton.styleFrom(backgroundColor: _waitingReplay ? Colors.grey : Colors.orangeAccent, foregroundColor: const Color(0xFF001A33)),
                  onPressed: _waitingReplay ? null : () {
                    _waitingReplay = true;
                    // Mettre à jour le dialog immédiatement
                    setDialogState(() {});
                    // Envoyer la demande de replay
                    store.bluetoothService.sendMessage({'type': 'replayRequest', 'data': {}});
                    debugPrint('🔄 J\'ai envoyé replayRequest, opponentWantsReplay: $_opponentWantsReplay');
                    // Vérifier si l'adversaire avait déjà demandé
                    if (_opponentWantsReplay) {
                      debugPrint('🔄 L\'adversaire était déjà prêt, bothReady!');
                      _bothReady();
                    }
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

  Widget _playerRow(String name, String emoji, int score, bool beatBot, int diff) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$emoji $name', style: TextStyle(color: emoji == '🟡' ? const Color(0xFFD4AF37) : Colors.blueAccent, fontSize: 14)),
        const SizedBox(width: 12),
        Text('$score pts', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Text(beatBot ? '✅' : '❌', style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Text('Diff: ${diff >= 0 ? "+" : ""}$diff', style: TextStyle(color: diff > 0 ? Colors.greenAccent : (diff < 0 ? Colors.redAccent : Colors.white), fontSize: 12)),
      ]),
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
    debugPrint('🔄 bothReady! Envoi replayAccepted');
    store.bluetoothService.sendMessage({'type': 'replayAccepted', 'data': {}});
    _restartGame();
  }

  void _restartGame() {
    debugPrint('🔄 Restart game!');
    if (Navigator.canPop(context)) Navigator.pop(context);
    _myScore = null;
    _opponentScore = null;
    _resultShown = false;
    _waitingReplay = false;
    _opponentWantsReplay = false;
    _gameKey = UniqueKey();
    _setupListener();
    if (mounted) setState(() {});
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
      child: Scaffold(
        backgroundColor: const Color(0xFF000814),
        body: AirHockeyScreen(key: _gameKey, vsBot: true, onVersusGameFinished: _onMyGameFinished),
      ),
    );
  }
}