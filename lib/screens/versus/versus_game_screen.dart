import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../stores/versus_store.dart';
import '../../services/settings_manager.dart';
import '../play_menu_screen.dart';
import '../square_game/square_game_screen.dart';

class VersusGameScreen extends StatefulWidget {
  const VersusGameScreen({super.key});

  @override
  State<VersusGameScreen> createState() => _VersusGameScreenState();
}

class _VersusGameScreenState extends State<VersusGameScreen> {
  final VersusStore store = Get.find<VersusStore>();
  final GlobalKey<SquareGameScreenState> _gameKey = GlobalKey<SquareGameScreenState>();

  bool _roundEnded = false;
  int? _myScore;
  int? _opponentScore;
  bool _resultShown = false;
  bool _isMyTurn = false;
  String _myName = '';
  String _opponentName = '';

  String get _gameType => 'squareScore';

  @override
  void initState() {
    super.initState();

    // Récupérer les noms
    _myName = settingsManager.playerName;
    _opponentName = store.bluetoothService.connectedPlayer?.value?.name ?? 'Adversaire';

    // Celui qui a le nom en premier alphabétiquement commence
    _isMyTurn = _myName.compareTo(_opponentName) <= 0;

    debugPrint('🟡 $_myName vs 🔵 $_opponentName - Je commence: $_isMyTurn');

    _setupListener();
  }

  void _setupListener() {
    store.bluetoothService.onMessageReceived = (message) {
      if (_roundEnded) return;

      final type = message['type'] as String?;
      final data = message['data'] as Map<String, dynamic>?;

      if (type == 'squareMove') {
        final row = data?['row'] as int?;
        final col = data?['col'] as int?;
        if (row != null && col != null) {
          _gameKey.currentState?.receiveOpponentMove(row, col);
          setState(() => _isMyTurn = true);
        }
      }

      if (type == _gameType) {
        setState(() {
          _opponentScore = data?['score'] as int?;
          _roundEnded = true;
        });
        if (!_resultShown) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!_resultShown) _showResult();
          });
        }
      }
    };
  }

  void _onMyMove(int row, int col) {
    setState(() => _isMyTurn = false);
    store.bluetoothService.sendMessage({
      'type': 'squareMove',
      'data': {'row': row, 'col': col},
    });
  }

  void _onMyGameFinished(int score, bool isDead) {
    if (_roundEnded) return;
    _roundEnded = true;
    _myScore = score;

    store.bluetoothService.sendMessage({
      'type': _gameType,
      'data': {'score': score, 'finished': true},
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!_resultShown && mounted) _showResult();
    });
  }

  void _showResult() {
    if (_resultShown) return;
    _resultShown = true;

    final myScore = _myScore ?? 0;
    final oppScore = _opponentScore ?? 0;
    final isDraw = myScore == oppScore;
    final won = myScore > oppScore;

    if (won) {
      settingsManager.playVictory();
    } else if (isDraw) {
      settingsManager.playClick();
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
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            isDraw ? Icons.handshake_rounded : (won ? Icons.emoji_events : Icons.sentiment_dissatisfied),
            color: isDraw ? Colors.orangeAccent : (won ? const Color(0xFFD4AF37) : Colors.redAccent),
            size: 60,
          ),
          const SizedBox(height: 20),
          Text('$_myName (🟡 Or): $myScore pts',
              style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
          Text('$_opponentName (🔵 Bleu): $oppScore pts',
              style: const TextStyle(color: Colors.blueAccent, fontSize: 18)),
          if (isDraw) ...[
            const SizedBox(height: 12),
            const Text('⚡ Égalité !', style: TextStyle(color: Colors.orangeAccent, fontSize: 14)),
          ],
        ]),
        actions: [
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(isDraw ? 'REJOUER' : 'CONTINUER'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDraw ? Colors.orangeAccent : const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF001A33),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                if (isDraw) {
                  // Relancer
                  setState(() {
                    _roundEnded = false;
                    _myScore = null;
                    _opponentScore = null;
                    _resultShown = false;
                    _isMyTurn = _myName.compareTo(_opponentName) <= 0;
                  });
                  _setupListener();
                } else {
                  store.disconnectAndReset();
                  Get.offAll(() => const PlayMenuScreen());
                }
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
            SquareGameScreen(
              key: _gameKey,
              vsBot: false,
              isVersusMode: true,
              startsFirst: _isMyTurn,
              onVersusGameFinished: _onMyGameFinished,
              onMoveMade: _onMyMove,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Column(
                  children: [
                    // Info joueurs
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.circle, color: Color(0xFFD4AF37), size: 10),
                          const SizedBox(width: 4),
                          Text(_myName, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11)),
                          const SizedBox(width: 12),
                          const Text('VS', style: TextStyle(color: Colors.white38, fontSize: 11)),
                          const SizedBox(width: 12),
                          Text(_opponentName, style: const TextStyle(color: Colors.blueAccent, fontSize: 11)),
                          const SizedBox(width: 4),
                          const Icon(Icons.circle, color: Colors.blueAccent, size: 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Indicateur de tour
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isMyTurn ? const Color(0xFFD4AF37).withOpacity(0.3) : Colors.blueAccent.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _isMyTurn ? const Color(0xFFD4AF37) : Colors.blueAccent, width: 2),
                      ),
                      child: Text(
                        _isMyTurn ? '🟡 VOTRE TOUR' : '🔵 TOUR DE $_opponentName',
                        style: TextStyle(
                          color: _isMyTurn ? const Color(0xFFD4AF37) : Colors.blueAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}