import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../services/square_game/square_flame_game.dart';
import '../../widgets/square_game/game_over_overlay.dart';
import '../../widgets/countdown_overlay.dart';

class SquareGameScreen extends StatefulWidget {
  final bool vsBot;
  final bool isVersusMode;
  final bool startsFirst;
  final String myName;
  final String opponentName;
  final bool isMyTurn;
  final Function(int score, int maxScore)? onSoloGameFinished;
  final Function(int score, bool isDead)? onVersusGameFinished;
  final void Function(int row, int col)? onMoveMade;

  const SquareGameScreen({
    super.key,
    this.vsBot = true,
    this.isVersusMode = false,
    this.startsFirst = true,
    this.myName = 'Vous',
    this.opponentName = 'Adversaire',
    this.isMyTurn = true,
    this.onSoloGameFinished,
    this.onVersusGameFinished,
    this.onMoveMade,
  });

  @override
  State<SquareGameScreen> createState() => SquareGameScreenState();
}

class SquareGameScreenState extends State<SquareGameScreen> {
  late SquareFlameGame game;
  bool _showCountdown = true;
  bool _hasNotifiedVersus = false;

  @override
  void initState() {
    super.initState();
    game = SquareFlameGame(onSoloGameFinished: widget.onSoloGameFinished);
    game.isVsBot = widget.vsBot;
    game.isVersusMode = widget.isVersusMode;
    game.isMyTurn = widget.startsFirst;

    game.onVersusFinished = (score, isDead) {
      if (!_hasNotifiedVersus) {
        _hasNotifiedVersus = true;
        widget.onVersusGameFinished?.call(score, isDead);
      }
    };

    game.onMoveMade = widget.onMoveMade;
    game.pauseEngine();
  }

  void receiveOpponentMove(int row, int col) {
    game.receiveOpponentMove(row, col);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000814),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        //title: const Text('SQUARE CONQUEST', style: TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 2)),
        leading: widget.isVersusMode ? const SizedBox() : IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'GameOver': (context, SquareFlameGame g) => GameOverOverlay(
                game: g,
                onSoloGameFinished: widget.onSoloGameFinished,
              ),
            },
            initialActiveOverlays: const [],
          ),
          if (_showCountdown)
            CountdownOverlay(
              onFinished: () {
                setState(() => _showCountdown = false);
                game.resumeEngine();
              },
            ),
          // Barre d'info en bas (mode Versus)
          // if (widget.isVersusMode)
          //   Positioned(
          //     bottom: 0,
          //     left: 0,
          //     right: 0,
          //     child: Container(
          //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          //       decoration: BoxDecoration(
          //         color: Colors.black87,
          //         border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
          //       ),
          //       child: SafeArea(
          //         top: false,
          //         child: Column(
          //           mainAxisSize: MainAxisSize.min,
          //           children: [
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               children: [
          //                 const Icon(Icons.circle, color: Color(0xFFD4AF37), size: 10),
          //                 const SizedBox(width: 4),
          //                 Text(widget.myName, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12)),
          //                 const SizedBox(width: 16),
          //                 const Text('VS', style: TextStyle(color: Colors.white38, fontSize: 12)),
          //                 const SizedBox(width: 16),
          //                 Text(widget.opponentName, style: const TextStyle(color: Colors.blueAccent, fontSize: 12)),
          //                 const SizedBox(width: 4),
          //                 const Icon(Icons.circle, color: Colors.blueAccent, size: 10),
          //               ],
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}