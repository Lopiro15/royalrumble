import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../services/air_hockey/air_hockey_game.dart';
import '../../widgets/air_hockey/victory_overlay.dart';
import '../../widgets/countdown_overlay.dart';

class AirHockeyScreen extends StatefulWidget {
  final bool vsBot;
  final Function(int score, int maxScore)? onSoloGameFinished;
  final Function(int score, bool isDead, int goalsFor, int goalsAgainst)? onVersusGameFinished;

  const AirHockeyScreen({
    super.key,
    this.vsBot = true,
    this.onSoloGameFinished,
    this.onVersusGameFinished,
  });

  @override
  State<AirHockeyScreen> createState() => _AirHockeyScreenState();
}

class _AirHockeyScreenState extends State<AirHockeyScreen> {
  late AirHockeyGame game;
  bool _showCountdown = true;
  bool _hasNotifiedVersus = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _hasNotifiedVersus = false;
    _showCountdown = true;
    game = AirHockeyGame(onSoloGameFinished: widget.onSoloGameFinished);
    game.isVsBot = widget.vsBot;

    game.onVersusFinished = (score, isDead, goalsFor, goalsAgainst) {
      if (!_hasNotifiedVersus) {
        _hasNotifiedVersus = true;
        widget.onVersusGameFinished?.call(score, isDead, goalsFor, goalsAgainst);
      }
    };

    game.pauseEngine();
  }

  @override
  void didUpdateWidget(AirHockeyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si la clé a changé (restart), réinitialiser le jeu
    if (oldWidget.key != widget.key) {
      _initGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isVersusMode = widget.onVersusGameFinished != null;

    return Scaffold(
      body: Stack(
        children: [
          GameWidget(
            game: game,
            overlayBuilderMap: {
              'GameOver': (context, AirHockeyGame g) {
                if (isVersusMode) {
                  return _buildVersusOverlay(g);
                } else {
                  return VictoryOverlay(game: g, onSoloGameFinished: widget.onSoloGameFinished);
                }
              },
            },
          ),
          if (_showCountdown)
            CountdownOverlay(
              onFinished: () {
                setState(() => _showCountdown = false);
                game.resumeEngine();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildVersusOverlay(AirHockeyGame g) {
    final int playerScore = g.p1Score.value;
    final int botScore = g.p2Score.value;
    final bool won = g.winner == 1;

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Container(
          width: 380,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF001A33),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: won ? const Color(0xFFD4AF37) : Colors.redAccent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                won ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                color: won ? const Color(0xFFD4AF37) : Colors.redAccent,
                size: 56,
              ),
              const SizedBox(height: 12),
              Text(
                won ? 'VICTOIRE !' : 'DÉFAITE...',
                style: TextStyle(
                  color: won ? const Color(0xFFD4AF37) : Colors.redAccent,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Container(width: 16, height: 16, decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 4),
                      Text('$playerScore', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      const Text('Vous', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('-', style: TextStyle(color: Colors.white38, fontSize: 28)),
                  ),
                  Column(
                    children: [
                      Container(width: 16, height: 16, decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 4),
                      Text('$botScore', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                      const Text('Bot', style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFFD4AF37), strokeWidth: 2)),
                  SizedBox(width: 10),
                  Text('En attente de l\'adversaire...', style: TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}