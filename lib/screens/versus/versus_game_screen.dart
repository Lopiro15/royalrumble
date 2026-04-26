import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../stores/versus_store.dart';
import '../../services/settings_manager.dart';
import '../car_game/car_game_screen.dart';
import '../meteor_game/meteor_game_screen.dart';
import '../hanoi_game/hanoi_game_screen.dart';
import '../puzzle_game/puzzle_game_screen.dart';
import '../square_game/square_game_screen.dart';
import '../air_hockey/air_hockey_screen.dart';
import '../quiz/quiz_game_screen.dart';
import '../play_menu_screen.dart';

// Import manquant pour VersusLobbyScreen dans Meteor
import '../versus/versus_lobby_screen.dart';

class VersusGameScreen extends StatefulWidget {
  final String gameName;

  const VersusGameScreen({super.key, required this.gameName});

  @override
  State<VersusGameScreen> createState() => _VersusGameScreenState();
}

class _VersusGameScreenState extends State<VersusGameScreen> {
  final VersusStore store = Get.find<VersusStore>();
  String _myName = '';
  String _opponentName = '';

  @override
  void initState() {
    super.initState();
    _myName = settingsManager.playerName;
    _opponentName =
        store.bluetoothService.connectedPlayer?.value?.name ?? 'Adversaire';
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.gameName) {
      case 'CAR ROYAL':
        return _CarVersusGame(store: store);
      case 'METEOR SHOWER':
        return _MeteorVersusGame(store: store);
      case 'TOUR D\'HANOI':
        return _HanoiVersusGame(store: store);
      case 'PUZZLE ROYAL':
        return _PuzzleVersusGame(store: store);
      case 'SQUARE CONQUEST':
        return _SquareVersusGame(
          store: store,
          myName: _myName,
          opponentName: _opponentName,
        );
      case 'AIR HOCKEY':
        return _AirHockeyVersusGame(
          store: store,
          myName: _myName,
          opponentName: _opponentName,
        );
      case 'QUIZ':
        return _QuizVersusGame(
          store: store,
          myName: _myName,
          opponentName: _opponentName,
        );
      default:
        return _CarVersusGame(store: store);
    }
  }
}

// ============================================================================
// CAR ROYAL
// ============================================================================
class _CarVersusGame extends StatefulWidget {
  final VersusStore store;

  const _CarVersusGame({required this.store});

  @override
  State<_CarVersusGame> createState() => _CarVersusGameState();
}

class _CarVersusGameState extends State<_CarVersusGame> {
  int? _myScore;
  bool _iAmDead = false;
  int? _opponentScore;
  bool _opponentIsDead = false;
  bool _resultShown = false;
  bool _waitingReplay = false;
  bool _opponentWantsReplay = false;
  bool _replayTriggered = false;
  Key _gameKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    widget.store.bluetoothService.onMessageReceived = (message) {
      final type = message['type'] as String?;
      final data = message['data'] as Map<String, dynamic>?;
      if (type == 'carScore') {
        setState(() {
          _opponentScore = data?['score'] as int?;
          _opponentIsDead = data?['isDead'] as bool? ?? false;
        });
        if (_iAmDead && _opponentIsDead && !_resultShown) _showResult();
      }
      if (type == 'replayRequest') {
        setState(() => _opponentWantsReplay = true);
        if (_waitingReplay && _opponentWantsReplay) _bothReady();
      }
      if (type == 'replayAccepted') _doRestartGame();
    };
  }

  void _onMyGameFinished(int score, bool isDead) {
    if (_replayTriggered) return;
    _myScore = score;
    _iAmDead = isDead;
    widget.store.bluetoothService.sendMessage({
      'type': 'carScore',
      'data': {'score': score, 'isDead': isDead},
    });
    if (_opponentIsDead && !_resultShown)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_resultShown) _showResult();
      });
  }

  void _showResult() {
    _resultShown = true;
    final myScore = _myScore ?? 0;
    final oppScore = _opponentScore ?? 0;
    final isDraw = myScore == oppScore;
    final won = myScore > oppScore;
    if (isDraw)
      settingsManager.playClick();
    else if (won)
      settingsManager.playVictory();
    else
      settingsManager.playDefeat();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF001A33),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isDraw
                  ? Colors.orangeAccent
                  : (won ? const Color(0xFFD4AF37) : Colors.redAccent),
              width: 2,
            ),
          ),
          title: Text(
            isDraw
                ? '🤝 MATCH NUL !'
                : (won ? '🏆 VICTOIRE !' : '😓 DÉFAITE...'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDraw
                  ? Colors.orangeAccent
                  : (won ? const Color(0xFFD4AF37) : Colors.redAccent),
              fontSize: 24,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDraw
                    ? Icons.handshake_rounded
                    : (won ? Icons.emoji_events : Icons.sentiment_dissatisfied),
                color: isDraw
                    ? Colors.orangeAccent
                    : (won ? const Color(0xFFD4AF37) : Colors.redAccent),
                size: 60,
              ),
              const SizedBox(height: 20),
              Text(
                'VOUS: $myScore pts',
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'ADVERSAIRE: $oppScore pts',
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isDraw) ...[
                const SizedBox(height: 12),
                const Text(
                  '⚡ Égalité ! Les deux joueurs doivent cliquer sur REJOUER.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 13),
                ),
                const SizedBox(height: 8),
                _chip('Adversaire', _opponentWantsReplay),
                const SizedBox(height: 4),
                _chip('Vous', _waitingReplay),
              ],
            ],
          ),
          actions: [
            if (isDraw)
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(
                    _waitingReplay ? Icons.check_circle : Icons.replay_rounded,
                  ),
                  label: Text(_waitingReplay ? 'EN ATTENTE...' : 'REJOUER'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _waitingReplay
                        ? Colors.grey
                        : Colors.orangeAccent,
                    foregroundColor: const Color(0xFF001A33),
                  ),
                  onPressed: _waitingReplay
                      ? null
                      : () {
                          setDialogState(() => _waitingReplay = true);
                          widget.store.bluetoothService.sendMessage({
                            'type': 'replayRequest',
                            'data': {},
                          });
                          if (_opponentWantsReplay) _bothReady();
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
                    widget.store.onRoundFinished(iWon: won, myScore: won ? myScore : oppScore, opponentScore: won ? oppScore : myScore);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool ready) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black26,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          ready ? Icons.check_circle : Icons.hourglass_empty,
          color: ready ? Colors.greenAccent : Colors.white38,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          '$label : ${ready ? "Prêt !" : "En attente..."}',
          style: TextStyle(
            color: ready ? Colors.greenAccent : Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );

  void _bothReady() {
    _replayTriggered = true;
    widget.store.bluetoothService.sendMessage({
      'type': 'replayAccepted',
      'data': {},
    });
    _doRestartGame();
  }

  void _doRestartGame() {
    if (Navigator.canPop(context)) Navigator.pop(context);
    setState(() {
      _myScore = null;
      _iAmDead = false;
      _opponentScore = null;
      _opponentIsDead = false;
      _resultShown = false;
      _waitingReplay = false;
      _opponentWantsReplay = false;
      _replayTriggered = false;
      _gameKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _showQuitDialog();
    },
    child: Scaffold(
      body: Stack(
        children: [
          CarGameScreen(key: _gameKey, onVersusGameFinished: _onMyGameFinished),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _opponentIsDead
                      ? 'Adv: ${_opponentScore ?? "?"} pts ☠️'
                      : 'Adv: en vie 🏎️',
                  style: TextStyle(
                    color: _opponentIsDead
                        ? Colors.redAccent
                        : Colors.greenAccent,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  void _showQuitDialog() => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF001A33),
      title: const Text('Quitter ?', style: TextStyle(color: Colors.white)),
      content: const Text(
        'Vous perdrez la partie.',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('ANNULER'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            widget.store.bluetoothService.sendMessage({
              'type': 'disconnect',
              'data': {},
            });
            widget.store.disconnectAndReset();
            Get.until((route) => route.isFirst);
          },
          child: const Text(
            'QUITTER',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );
}

// ============================================================================
// METEOR SHOWER
// ============================================================================
class _MeteorVersusGame extends StatefulWidget {
  final VersusStore store;

  const _MeteorVersusGame({required this.store});

  @override
  State<_MeteorVersusGame> createState() => _MeteorVersusGameState();
}

class _MeteorVersusGameState extends State<_MeteorVersusGame> {
  int? _myScore;
  bool _iAmDead = false;
  int? _opponentScore;
  bool _opponentIsDead = false;
  bool _resultShown = false;
  bool _waitingReplay = false;
  bool _opponentWantsReplay = false;

  @override
  void initState() {
    super.initState();
    widget.store.bluetoothService.onMessageReceived = (message) {
      final type = message['type'] as String?;
      final data = message['data'] as Map<String, dynamic>?;
      if (type == 'meteorScore') {
        setState(() {
          _opponentScore = data?['score'] as int?;
          _opponentIsDead = data?['isDead'] as bool? ?? false;
        });
        if (_iAmDead && _opponentIsDead && !_resultShown) _showResult();
      }
      if (type == 'replayRequest') {
        setState(() => _opponentWantsReplay = true);
        if (_waitingReplay && _opponentWantsReplay) _bothReady();
      }
      if (type == 'replayAccepted') _restartGame();
    };
  }

  void _onMyGameFinished(int score, bool isDead) {
    _myScore = score;
    _iAmDead = isDead;
    widget.store.bluetoothService.sendMessage({
      'type': 'meteorScore',
      'data': {'score': score, 'isDead': isDead},
    });
    if (_opponentIsDead && !_resultShown)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_resultShown) _showResult();
      });
  }

  void _showResult() {
    _resultShown = true;
    final myScore = _myScore ?? 0;
    final oppScore = _opponentScore ?? 0;
    final isDraw = myScore == oppScore;
    final won = myScore > oppScore;
    if (isDraw)
      settingsManager.playClick();
    else if (won)
      settingsManager.playVictory();
    else
      settingsManager.playDefeat();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF001A33),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isDraw
                  ? Colors.orangeAccent
                  : (won ? const Color(0xFFD4AF37) : Colors.redAccent),
              width: 2,
            ),
          ),
          title: Text(
            isDraw
                ? '🤝 MATCH NUL !'
                : (won ? '🏆 VICTOIRE !' : '😓 DÉFAITE...'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDraw
                  ? Colors.orangeAccent
                  : (won ? const Color(0xFFD4AF37) : Colors.redAccent),
              fontSize: 24,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDraw
                    ? Icons.handshake_rounded
                    : (won ? Icons.emoji_events : Icons.sentiment_dissatisfied),
                color: isDraw
                    ? Colors.orangeAccent
                    : (won ? const Color(0xFFD4AF37) : Colors.redAccent),
                size: 60,
              ),
              const SizedBox(height: 20),
              Text(
                'VOUS: $myScore pts',
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'ADVERSAIRE: $oppScore pts',
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                  icon: Icon(
                    _waitingReplay ? Icons.check_circle : Icons.replay_rounded,
                  ),
                  label: Text(_waitingReplay ? 'EN ATTENTE...' : 'REJOUER'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _waitingReplay
                        ? Colors.grey
                        : Colors.orangeAccent,
                    foregroundColor: const Color(0xFF001A33),
                  ),
                  onPressed: _waitingReplay
                      ? null
                      : () {
                          setState(() => _waitingReplay = true);
                          setDialogState(() {});
                          widget.store.bluetoothService.sendMessage({
                            'type': 'replayRequest',
                            'data': {},
                          });
                          if (_opponentWantsReplay) _bothReady();
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
                    widget.store.onRoundFinished(iWon: won, myScore: won ? myScore : oppScore, opponentScore: won ? oppScore : myScore);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool ready) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black26,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          ready ? Icons.check_circle : Icons.hourglass_empty,
          color: ready ? Colors.greenAccent : Colors.white38,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          '$label : ${ready ? "Prêt !" : "En attente..."}',
          style: TextStyle(
            color: ready ? Colors.greenAccent : Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );

  void _bothReady() {
    widget.store.bluetoothService.sendMessage({
      'type': 'replayAccepted',
      'data': {},
    });
    _restartGame();
  }

  void _restartGame() {
    if (Navigator.canPop(context)) Navigator.pop(context);
    Get.off(() => VersusGameScreen(gameName: 'METEOR SHOWER'));
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _showQuitDialog();
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _opponentIsDead
                      ? 'Adv: ${_opponentScore ?? "?"} pts ☠️'
                      : 'Adv: en vie 🛸',
                  style: TextStyle(
                    color: _opponentIsDead
                        ? Colors.redAccent
                        : Colors.greenAccent,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  void _showQuitDialog() => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF001A33),
      title: const Text('Quitter ?', style: TextStyle(color: Colors.white)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('ANNULER'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            widget.store.bluetoothService.sendMessage({
              'type': 'disconnect',
              'data': {},
            });
            widget.store.disconnectAndReset();
            Get.offAll(() => const VersusLobbyScreen());
          },
          child: const Text(
            'QUITTER',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );
}

// ============================================================================
// HANOI (COURSE)
// ============================================================================
class _HanoiVersusGame extends StatefulWidget {
  final VersusStore store;

  const _HanoiVersusGame({required this.store});

  @override
  State<_HanoiVersusGame> createState() => _HanoiVersusGameState();
}

class _HanoiVersusGameState extends State<_HanoiVersusGame> {
  bool _iFinished = false;
  int? _myScore;
  bool _opponentFinished = false;
  int? _opponentScore;
  bool _resultShown = false;
  final int _numDisks = 5;

  @override
  void initState() {
    super.initState();
    widget.store.bluetoothService.sendMessage({
      'type': 'hanoiSetup',
      'data': {'numDisks': _numDisks},
    });
    widget.store.bluetoothService.onMessageReceived = (message) {
      final type = message['type'] as String?;
      final data = message['data'] as Map<String, dynamic>?;
      if (type == 'hanoiScore') {
        setState(() {
          _opponentScore = data?['score'] as int?;
          _opponentFinished = true;
        });
        if (!_iFinished) {
          _myScore ??= 0;
          _showResult();
        }
        if (_iFinished) _showResult();
      }
      if (type == 'roundEnd') {
        setState(() {
          _opponentScore = data?['score'] as int?;
          _opponentFinished = true;
        });
        _myScore ??= 0;
        if (!_resultShown) _showResult();
      }
    };
  }

  void _onMyGameFinished(int score, bool isDead) {
    _myScore = score;
    _iFinished = true;
    widget.store.bluetoothService.sendMessage({
      'type': 'roundEnd',
      'data': {'score': score},
    });
    widget.store.bluetoothService.sendMessage({
      'type': 'hanoiScore',
      'data': {'score': score, 'finished': true},
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!_resultShown && mounted) _showResult();
    });
  }

  void _showResult() {
    if (_resultShown) return;
    _resultShown = true;
    final iWon = _iFinished;
    if (iWon)
      settingsManager.playVictory();
    else
      settingsManager.playDefeat();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF001A33),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: iWon ? const Color(0xFFD4AF37) : Colors.redAccent,
            width: 2,
          ),
        ),
        title: Text(
          iWon ? '🏆 VICTOIRE !' : '😓 DÉFAITE...',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: iWon ? const Color(0xFFD4AF37) : Colors.redAccent,
            fontSize: 24,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iWon ? Icons.emoji_events : Icons.sentiment_dissatisfied,
              color: iWon ? const Color(0xFFD4AF37) : Colors.redAccent,
              size: 60,
            ),
            const SizedBox(height: 20),
            Text(
              'VOUS: ${iWon ? "$_myScore pts ✅" : "Pas fini ❌"}',
              style: TextStyle(
                color: iWon ? const Color(0xFFD4AF37) : Colors.redAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'ADVERSAIRE: ${_opponentFinished ? "${_opponentScore} pts" : "Pas fini"}',
              style: TextStyle(
                color: _opponentFinished ? Colors.blueAccent : Colors.white70,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
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
                widget.store.onRoundFinished(iWon: iWon, myScore: iWon ? (_myScore ?? 0) : (_opponentScore ?? 0), opponentScore: iWon ? (_opponentScore ?? 0) : (_myScore ?? 0));
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _showQuitDialog();
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _opponentFinished
                      ? 'Adv: ${_opponentScore ?? "?"} pts ✅'
                      : 'Adv: en cours 🧠',
                  style: TextStyle(
                    color: _opponentFinished
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
          if (!_iFinished && _opponentFinished)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Text(
                  '⏰ L\'adversaire a terminé !',
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );

  void _showQuitDialog() => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF001A33),
      title: const Text('Quitter ?', style: TextStyle(color: Colors.white)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('ANNULER'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            widget.store.bluetoothService.sendMessage({
              'type': 'disconnect',
              'data': {},
            });
            widget.store.disconnectAndReset();
            Get.offAll(() => const PlayMenuScreen());
          },
          child: const Text(
            'QUITTER',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );
}

// ============================================================================
// PUZZLE (COURSE)
// ============================================================================
class _PuzzleVersusGame extends StatefulWidget {
  final VersusStore store;

  const _PuzzleVersusGame({required this.store});

  @override
  State<_PuzzleVersusGame> createState() => _PuzzleVersusGameState();
}

class _PuzzleVersusGameState extends State<_PuzzleVersusGame> {
  bool _iFinished = false;
  int? _myScore;
  bool _opponentFinished = false;
  int? _opponentScore;
  bool _resultShown = false;
  late List<int> _syncedTiles;
  late int _syncedSeed;

  @override
  void initState() {
    super.initState();
    _syncedSeed = DateTime.now().millisecond;
    _syncedTiles = _generateTilesFromSeed(_syncedSeed);
    widget.store.bluetoothService.sendMessage({
      'type': 'puzzleSetup',
      'data': {'seed': _syncedSeed},
    });
    widget.store.bluetoothService.onMessageReceived = (message) {
      final type = message['type'] as String?;
      final data = message['data'] as Map<String, dynamic>?;
      if (type == 'puzzleSetup') {
        final seed = data?['seed'] as int?;
        if (seed != null) _syncedTiles = _generateTilesFromSeed(seed);
      }
      if (type == 'puzzleScore') {
        setState(() {
          _opponentScore = data?['score'] as int?;
          _opponentFinished = true;
        });
        if (!_iFinished) {
          _myScore ??= 0;
          _showResult();
        }
        if (_iFinished) _showResult();
      }
      if (type == 'roundEnd') {
        setState(() {
          _opponentScore = data?['score'] as int?;
          _opponentFinished = true;
        });
        _myScore ??= 0;
        if (!_resultShown) _showResult();
      }
    };
  }

  List<int> _generateTilesFromSeed(int seed) {
    final random = Random(seed);
    List<int> tiles = List.generate(9, (i) => i);
    int emptyIndex = 8;
    for (int i = 0; i < 200; i++) {
      List<int> validMoves = [];
      int row = emptyIndex ~/ 3, col = emptyIndex % 3;
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

  void _onMyGameFinished(int score, bool isDead) {
    _myScore = score;
    _iFinished = true;
    widget.store.bluetoothService.sendMessage({
      'type': 'roundEnd',
      'data': {'score': score},
    });
    widget.store.bluetoothService.sendMessage({
      'type': 'puzzleScore',
      'data': {'score': score, 'finished': true},
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!_resultShown && mounted) _showResult();
    });
  }

  void _showResult() {
    if (_resultShown) return;
    _resultShown = true;
    final iWon = _iFinished;
    if (iWon)
      settingsManager.playVictory();
    else
      settingsManager.playDefeat();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF001A33),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: iWon ? const Color(0xFFD4AF37) : Colors.redAccent,
            width: 2,
          ),
        ),
        title: Text(
          iWon ? '🏆 VICTOIRE !' : '😓 DÉFAITE...',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: iWon ? const Color(0xFFD4AF37) : Colors.redAccent,
            fontSize: 24,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iWon ? Icons.emoji_events : Icons.sentiment_dissatisfied,
              color: iWon ? const Color(0xFFD4AF37) : Colors.redAccent,
              size: 60,
            ),
            const SizedBox(height: 20),
            Text(
              'VOUS: ${iWon ? "$_myScore pts ✅" : "Pas fini ❌"}',
              style: TextStyle(
                color: iWon ? const Color(0xFFD4AF37) : Colors.redAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'ADVERSAIRE: ${_opponentFinished ? "${_opponentScore} pts" : "Pas fini"}',
              style: TextStyle(
                color: _opponentFinished ? Colors.blueAccent : Colors.white70,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
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
                widget.store.onRoundFinished(iWon: iWon, myScore: iWon ? (_myScore ?? 0) : (_opponentScore ?? 0), opponentScore: iWon ? (_opponentScore ?? 0) : (_myScore ?? 0));
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _showQuitDialog();
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _opponentFinished
                      ? 'Adv: ${_opponentScore ?? "?"} pts ✅'
                      : 'Adv: en cours 🧩',
                  style: TextStyle(
                    color: _opponentFinished
                        ? Colors.greenAccent
                        : Colors.orangeAccent,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
          if (!_iFinished && _opponentFinished)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Text(
                  '⏰ L\'adversaire a terminé !',
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );

  void _showQuitDialog() => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF001A33),
      title: const Text('Quitter ?', style: TextStyle(color: Colors.white)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('ANNULER'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            widget.store.bluetoothService.sendMessage({
              'type': 'disconnect',
              'data': {},
            });
            widget.store.disconnectAndReset();
            Get.offAll(() => const PlayMenuScreen());
          },
          child: const Text(
            'QUITTER',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );
}

// ============================================================================
// SQUARE CONQUEST
// ============================================================================
class _SquareVersusGame extends StatefulWidget {
  final VersusStore store;
  final String myName;
  final String opponentName;

  const _SquareVersusGame({
    required this.store,
    required this.myName,
    required this.opponentName,
  });

  @override
  State<_SquareVersusGame> createState() => _SquareVersusGameState();
}

class _SquareVersusGameState extends State<_SquareVersusGame> {
  final GlobalKey<SquareGameScreenState> _gameKey =
      GlobalKey<SquareGameScreenState>();
  bool _roundEnded = false;
  int? _myScore;
  int? _opponentScore;
  bool _resultShown = false;
  bool _isMyTurn = false;

  @override
  void initState() {
    super.initState();
    _isMyTurn = widget.myName.compareTo(widget.opponentName) <= 0;
    widget.store.bluetoothService.onMessageReceived = (message) {
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
      if (type == 'squareScore') {
        setState(() {
          _opponentScore = data?['score'] as int?;
          _roundEnded = true;
        });
        if (!_resultShown)
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!_resultShown) _showResult();
          });
      }
    };
  }

  void _onMyMove(int row, int col) {
    setState(() => _isMyTurn = false);
    widget.store.bluetoothService.sendMessage({
      'type': 'squareMove',
      'data': {'row': row, 'col': col},
    });
  }

  void _onMyGameFinished(int score, bool isDead) {
    if (_roundEnded) return;
    _roundEnded = true;
    _myScore = score;
    widget.store.bluetoothService.sendMessage({
      'type': 'squareScore',
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
    final won = myScore > oppScore;
    if (won)
      settingsManager.playVictory();
    else
      settingsManager.playDefeat();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF001A33),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: won ? const Color(0xFFD4AF37) : Colors.redAccent,
            width: 2,
          ),
        ),
        title: Text(
          won ? '🏆 VICTOIRE !' : '😓 DÉFAITE...',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: won ? const Color(0xFFD4AF37) : Colors.redAccent,
            fontSize: 24,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              won ? Icons.emoji_events : Icons.sentiment_dissatisfied,
              color: won ? const Color(0xFFD4AF37) : Colors.redAccent,
              size: 60,
            ),
            const SizedBox(height: 20),
            Text(
              '${widget.myName} (🟡): $myScore pts',
              style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18),
            ),
            Text(
              '${widget.opponentName} (🔵): $oppScore pts',
              style: const TextStyle(color: Colors.blueAccent, fontSize: 18),
            ),
          ],
        ),
        actions: [
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
                widget.store.onRoundFinished(iWon: won, myScore: myScore, opponentScore: oppScore);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _showQuitDialog();
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.black87),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.circle,
                          color: Color(0xFFD4AF37),
                          size: 10,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.myName,
                          style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'VS',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.opponentName,
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.circle,
                          color: Colors.blueAccent,
                          size: 10,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _isMyTurn
                            ? const Color(0xFFD4AF37).withOpacity(0.2)
                            : Colors.blueAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isMyTurn
                              ? const Color(0xFFD4AF37)
                              : Colors.blueAccent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        _isMyTurn
                            ? '🟡 VOTRE TOUR'
                            : '🔵 TOUR DE ${widget.opponentName}',
                        style: TextStyle(
                          color: _isMyTurn
                              ? const Color(0xFFD4AF37)
                              : Colors.blueAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  void _showQuitDialog() => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF001A33),
      title: const Text('Quitter ?', style: TextStyle(color: Colors.white)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('ANNULER'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            widget.store.bluetoothService.sendMessage({
              'type': 'disconnect',
              'data': {},
            });
            widget.store.disconnectAndReset();
            Get.offAll(() => const PlayMenuScreen());
          },
          child: const Text(
            'QUITTER',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );
}

// ============================================================================
// AIR HOCKEY
// ============================================================================
class _AirHockeyVersusGame extends StatefulWidget {
  final VersusStore store;
  final String myName;
  final String opponentName;

  const _AirHockeyVersusGame({
    required this.store,
    required this.myName,
    required this.opponentName,
  });

  @override
  State<_AirHockeyVersusGame> createState() => _AirHockeyVersusGameState();
}

class _AirHockeyVersusGameState extends State<_AirHockeyVersusGame> {
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
  Key _gameKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    widget.store.bluetoothService.onMessageReceived = (message) {
      final type = message['type'] as String?;
      final data = message['data'] as Map<String, dynamic>?;
      if (type == 'airHockeyScore') {
        _opponentScore = data?['score'] as int?;
        _opponentBeatBot = data?['beatBot'] as bool? ?? false;
        _opponentGoalsFor = data?['goalsFor'] as int? ?? 0;
        _opponentGoalsAgainst = data?['goalsAgainst'] as int? ?? 0;
        if (_myScore != null && !_resultShown && mounted)
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!_resultShown && mounted) _showResult();
          });
      }
      if (type == 'replayRequest') {
        _opponentWantsReplay = true;
        if (_waitingReplay)
          _bothReady();
        else if (mounted)
          setState(() {});
      }
      if (type == 'replayAccepted') _restartGame();
    };
  }

  void _onMyGameFinished(
    int score,
    bool isDead,
    int goalsFor,
    int goalsAgainst,
  ) {
    if (_myScore != null) return;
    _myScore = score;
    _iBeatBot = !isDead;
    _myGoalsFor = goalsFor;
    _myGoalsAgainst = goalsAgainst;
    widget.store.bluetoothService.sendMessage({
      'type': 'airHockeyScore',
      'data': {
        'score': score,
        'beatBot': _iBeatBot,
        'goalsFor': goalsFor,
        'goalsAgainst': goalsAgainst,
      },
    });
    if (_opponentScore != null && !_resultShown && mounted)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_resultShown && mounted) _showResult();
      });
  }

  void _showResult() {
    if (_resultShown) return;
    _resultShown = true;
    final myScore = _myScore ?? 0;
    final oppScore = _opponentScore ?? 0;
    final myDiff = _myGoalsFor - _myGoalsAgainst;
    final oppDiff = _opponentGoalsFor - _opponentGoalsAgainst;
    bool won = false, isDraw = false;
    if (_iBeatBot && !_opponentBeatBot)
      won = true;
    else if (!_iBeatBot && _opponentBeatBot)
      won = false;
    else if (myDiff != oppDiff)
      won = myDiff > oppDiff;
    else if (myScore != oppScore)
      won = myScore > oppScore;
    else
      isDraw = true;
    final resultColor = isDraw
        ? Colors.orangeAccent
        : (won ? const Color(0xFFD4AF37) : Colors.redAccent);
    if (won)
      settingsManager.playVictory();
    else if (isDraw)
      settingsManager.playClick();
    else
      settingsManager.playDefeat();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF001A33),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: resultColor, width: 2),
          ),
          title: Text(
            isDraw
                ? '🤝 MATCH NUL !'
                : (won ? '🏆 VICTOIRE !' : '😓 DÉFAITE...'),
            textAlign: TextAlign.center,
            style: TextStyle(color: resultColor, fontSize: 24),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDraw
                    ? Icons.handshake_rounded
                    : (won ? Icons.emoji_events : Icons.sentiment_dissatisfied),
                color: resultColor,
                size: 60,
              ),
              const SizedBox(height: 20),
              _playerRow(widget.myName, '🟡', myScore, _iBeatBot, myDiff),
              const SizedBox(height: 8),
              _playerRow(
                widget.opponentName,
                '🔵',
                oppScore,
                _opponentBeatBot,
                oppDiff,
              ),
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
                  icon: Icon(
                    _waitingReplay ? Icons.check_circle : Icons.replay_rounded,
                  ),
                  label: Text(_waitingReplay ? 'EN ATTENTE...' : 'REJOUER'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _waitingReplay
                        ? Colors.grey
                        : Colors.orangeAccent,
                    foregroundColor: const Color(0xFF001A33),
                  ),
                  onPressed: _waitingReplay
                      ? null
                      : () {
                          _waitingReplay = true;
                          setDialogState(() {});
                          widget.store.bluetoothService.sendMessage({
                            'type': 'replayRequest',
                            'data': {},
                          });
                          if (_opponentWantsReplay) _bothReady();
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
                    widget.store.onRoundFinished(iWon: won, myScore: won ? myScore : oppScore, opponentScore: won ? oppScore : myScore);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _playerRow(
    String name,
    String emoji,
    int score,
    bool beatBot,
    int diff,
  ) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.black26,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$emoji $name',
          style: TextStyle(
            color: emoji == '🟡' ? const Color(0xFFD4AF37) : Colors.blueAccent,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$score pts',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Text(beatBot ? '✅' : '❌', style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Text(
          'Diff: ${diff >= 0 ? "+" : ""}$diff',
          style: TextStyle(
            color: diff > 0
                ? Colors.greenAccent
                : (diff < 0 ? Colors.redAccent : Colors.white),
            fontSize: 12,
          ),
        ),
      ],
    ),
  );

  Widget _chip(String label, bool ready) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black26,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          ready ? Icons.check_circle : Icons.hourglass_empty,
          color: ready ? Colors.greenAccent : Colors.white38,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          '$label : ${ready ? "Prêt !" : "En attente..."}',
          style: TextStyle(
            color: ready ? Colors.greenAccent : Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );

  void _bothReady() {
    widget.store.bluetoothService.sendMessage({
      'type': 'replayAccepted',
      'data': {},
    });
    _restartGame();
  }

  void _restartGame() {
    if (Navigator.canPop(context)) Navigator.pop(context);
    _myScore = null;
    _opponentScore = null;
    _resultShown = false;
    _waitingReplay = false;
    _opponentWantsReplay = false;
    _gameKey = UniqueKey();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _showQuitDialog();
    },
    child: Scaffold(
      backgroundColor: const Color(0xFF000814),
      body: Stack(
        children: [
          AirHockeyScreen(
            key: _gameKey,
            vsBot: true,
            onVersusGameFinished: _onMyGameFinished,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.black87),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.circle,
                      color: Color(0xFFD4AF37),
                      size: 10,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.myName,
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'VS',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      widget.opponentName,
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.circle,
                      color: Colors.blueAccent,
                      size: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  void _showQuitDialog() => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF001A33),
      title: const Text('Quitter ?', style: TextStyle(color: Colors.white)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('ANNULER'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            widget.store.bluetoothService.sendMessage({
              'type': 'disconnect',
              'data': {},
            });
            widget.store.disconnectAndReset();
            Get.offAll(() => const PlayMenuScreen());
          },
          child: const Text(
            'QUITTER',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );
}

// ============================================================================
// QUIZ
// ============================================================================
class _QuizVersusGame extends StatefulWidget {
  final VersusStore store;
  final String myName;
  final String opponentName;

  const _QuizVersusGame({
    required this.store,
    required this.myName,
    required this.opponentName,
  });

  @override
  State<_QuizVersusGame> createState() => _QuizVersusGameState();
}

class _QuizVersusGameState extends State<_QuizVersusGame> {
  int? _myScore;
  DateTime? _myFinishTime;
  int? _opponentScore;
  DateTime? _opponentFinishTime;
  bool _resultShown = false;
  late List<int> _syncedSequence;

  @override
  void initState() {
    super.initState();
    final seed = (widget.myName + widget.opponentName).hashCode.abs();
    _syncedSequence = _generateSequenceFromSeed(seed);
    widget.store.bluetoothService.sendMessage({
      'type': 'quizSetup',
      'data': {'seed': seed},
    });
    widget.store.bluetoothService.onMessageReceived = (message) {
      if (_resultShown) return;
      final type = message['type'] as String?;
      final data = message['data'] as Map<String, dynamic>?;
      if (type == 'quizSetup') {
        final s = data?['seed'] as int?;
        if (s != null && _syncedSequence.isEmpty)
          _syncedSequence = _generateSequenceFromSeed(s);
      }
      if (type == 'quizScore') {
        _opponentScore = data?['score'] as int?;
        _opponentFinishTime = data?['finishTime'] != null
            ? DateTime.fromMillisecondsSinceEpoch(data!['finishTime'] as int)
            : null;
        if (_myScore != null && !_resultShown && mounted)
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!_resultShown && mounted) _showResult();
          });
      }
    };
  }

  List<int> _generateSequenceFromSeed(int seed) {
    final rand = Random(seed);
    final List<int> seq = List.from([0, 1, 2, 3, 4]);
    while (seq.length < 10) seq.add([0, 1, 2, 3, 4][rand.nextInt(5)]);
    seq.shuffle(rand);
    return seq;
  }

  void _onMyGameFinished(int score, bool isDead) {
    if (_myScore != null) return;
    _myScore = score;
    _myFinishTime = DateTime.now();
    widget.store.bluetoothService.sendMessage({
      'type': 'quizScore',
      'data': {
        'score': score,
        'finishTime': _myFinishTime!.millisecondsSinceEpoch,
      },
    });
    if (_opponentScore != null && !_resultShown && mounted)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_resultShown && mounted) _showResult();
      });
  }

  void _showResult() {
    if (_resultShown) return;
    _resultShown = true;
    final myScore = _myScore ?? 0;
    final oppScore = _opponentScore ?? 0;
    bool won;
    if (myScore > oppScore)
      won = true;
    else if (oppScore > myScore)
      won = false;
    else {
      if (_myFinishTime != null && _opponentFinishTime != null)
        won = _myFinishTime!.isBefore(_opponentFinishTime!);
      else
        won = _myFinishTime != null;
    }
    if (won)
      settingsManager.playVictory();
    else
      settingsManager.playDefeat();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF001A33),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: won ? const Color(0xFFD4AF37) : Colors.redAccent,
            width: 2,
          ),
        ),
        title: Text(
          won ? '🏆 VICTOIRE !' : '😓 DÉFAITE...',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: won ? const Color(0xFFD4AF37) : Colors.redAccent,
            fontSize: 24,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              won ? Icons.emoji_events : Icons.sentiment_dissatisfied,
              color: won ? const Color(0xFFD4AF37) : Colors.redAccent,
              size: 60,
            ),
            const SizedBox(height: 20),
            Text(
              '${widget.myName}: $myScore pts',
              style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16),
            ),
            Text(
              '${widget.opponentName}: $oppScore pts',
              style: const TextStyle(color: Colors.blueAccent, fontSize: 16),
            ),
          ],
        ),
        actions: [
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
                widget.store.onRoundFinished(iWon: won, myScore: myScore, opponentScore: oppScore);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) _showQuitDialog();
    },
    child: QuizGameScreen(
      gameMode: 'duo',
      onVersusGameFinished: _onMyGameFinished,
      forcedSequence: _syncedSequence,
    ),
  );

  void _showQuitDialog() => showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF001A33),
      title: const Text('Quitter ?', style: TextStyle(color: Colors.white)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('ANNULER'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            widget.store.bluetoothService.sendMessage({
              'type': 'disconnect',
              'data': {},
            });
            widget.store.disconnectAndReset();
            Get.offAll(() => const PlayMenuScreen());
          },
          child: const Text(
            'QUITTER',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ),
  );
}
