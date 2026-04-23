import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/settings_manager.dart';
import '../../widgets/countdown_overlay.dart';

enum ObstacleType { sedan, truck, f1 }

class Obstacle {
  double y;
  int lane;
  ObstacleType type;
  bool overtaken = false;

  Obstacle({required this.y, required this.lane, required this.type});
}

class CarGameScreen extends StatefulWidget {
  final Function(int score, int maxScore)? onSoloGameFinished;

  const CarGameScreen({super.key, this.onSoloGameFinished});

  @override
  State<CarGameScreen> createState() => _CarGameScreenState();
}

class _CarGameScreenState extends State<CarGameScreen> with TickerProviderStateMixin {
  late Timer gameTimer;
  int score = 0;
  int secondsElapsed = 0;
  Timer? chronoTimer;
  bool _showCountdown = true;

  double gameSpeed = 8.0;
  double roadOffset = 0;
  int playerLane = 1;
  bool isJumping = false;
  bool isGameOver = false;
  bool _hasNotifiedSolo = false;

  List<Obstacle> obstacles = [];
  final Random random = Random();

  late AnimationController _jumpController;

  // Score maximum approximatif pour Car Royal (basé sur le temps)
  static const int maxPossibleScore = 1000;

  @override
  void initState() {
    super.initState();
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  void _startGame() {
    score = 0;
    secondsElapsed = 0;
    gameSpeed = 8.0;
    roadOffset = 0;
    playerLane = 1;
    isJumping = false;
    isGameOver = false;
    _hasNotifiedSolo = false;
    obstacles.clear();

    chronoTimer?.cancel();
    chronoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isGameOver) {
        setState(() {
          secondsElapsed++;
          if (gameSpeed < 25) gameSpeed += 0.3;
        });
      }
    });

    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!isGameOver) {
        _updateGame();
      } else {
        timer.cancel();
      }
    });
  }

  void _updateGame() {
    setState(() {
      roadOffset += gameSpeed;
      if (roadOffset > 100) roadOffset = 0;

      for (var obs in obstacles) {
        double speedMultiplier = obs.type == ObstacleType.f1 ? 2.0 : 1.2;
        obs.y += gameSpeed * speedMultiplier;
      }

      obstacles.removeWhere((obs) {
        if (obs.y > MediaQuery.of(context).size.height) {
          if (!obs.overtaken) {
            score += (obs.type == ObstacleType.f1 ? 2 : 1);
            obs.overtaken = true;
          }
          return true;
        }
        return false;
      });

      if (obstacles.isEmpty || (obstacles.last.y > 500 && random.nextDouble() < 0.06)) {
        double spawnChance = random.nextDouble();
        int count = spawnChance < 0.4 ? 1 : (spawnChance < 0.8 ? 2 : 3);

        List<int> availableLanes = [0, 1, 2, 3]..shuffle();
        double formationRand = random.nextDouble();
        double baseY = -350.0;

        for (int i = 0; i < count; i++) {
          int lane = availableLanes[i];

          double randType = random.nextDouble();
          ObstacleType type = randType > 0.92 ? ObstacleType.f1 : (randType > 0.7 ? ObstacleType.truck : ObstacleType.sedan);

          double yOffset;
          if (formationRand < 0.35) {
            yOffset = random.nextDouble() * 30.0;
          } else if (formationRand < 0.75) {
            yOffset = i * (120.0 + random.nextDouble() * 50.0);
          } else {
            yOffset = i * (250.0 + random.nextDouble() * 150.0);
          }

          obstacles.add(Obstacle(
            y: baseY - yOffset,
            lane: lane,
            type: type,
          ));
        }
      }

      for (var obs in obstacles) {
        double carTop = MediaQuery.of(context).size.height - 180;
        double carBottom = carTop + 80;
        double obsTop = obs.y;
        double obsBottom = obs.y + (obs.type == ObstacleType.truck ? 200 : 80);

        if (obs.lane == playerLane && obsBottom > carTop && obsTop < carBottom) {
          if (isJumping) {
            if (obs.type == ObstacleType.truck) {
              _gameOver();
            }
          } else {
            _gameOver();
          }
        }
      }
    });
  }

  void _gameOver() {
    if (isGameOver) return;
    isGameOver = true;
    chronoTimer?.cancel();

    // Notifier le mode solo
    if (widget.onSoloGameFinished != null && !_hasNotifiedSolo) {
      _hasNotifiedSolo = true;
      widget.onSoloGameFinished!(score, maxPossibleScore);
    }

    _showGameOverDialog();
  }

  void _jump() {
    if (isJumping || isGameOver) return;
    setState(() => isJumping = true);
    settingsManager.playClick();
    _jumpController.forward(from: 0).then((_) {
      setState(() => isJumping = false);
    });
  }

  void _showGameOverDialog() {
    final bool isSoloMode = widget.onSoloGameFinished != null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF001A33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFD4AF37), width: 2)),
        title: const Text('CRASH ROYAL !', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFD4AF37), fontSize: 24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.car_crash_rounded, color: Colors.orangeAccent, size: 80).animate().shake(),
            const SizedBox(height: 20),
            Text('SCORE: $score', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            Text('TEMPS: ${_formatTime(secondsElapsed)}', style: const TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
        actions: [
          Center(
            child: Column(
              children: [
                if (isSoloMode) ...[
                  // Mode Solo : bouton neutre
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF001A33)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('TERMINÉ', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ] else ...[
                  // Mode Entraînement : Rejouer + Quitter
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37), foregroundColor: const Color(0xFF001A33)),
                    onPressed: () {
                      Navigator.pop(context);
                      _startGame();
                    },
                    child: const Text('REPRENDRE LA ROUTE', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('QUITTER', style: TextStyle(color: Colors.white54)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int sec) {
    int minutes = sec ~/ 60;
    int remainingSeconds = sec % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    gameTimer.cancel();
    chronoTimer?.cancel();
    _jumpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (isGameOver) return;
          if (details.primaryVelocity! < -300 && playerLane > 0) {
            setState(() => playerLane--);
            settingsManager.playClick();
          } else if (details.primaryVelocity! > 300 && playerLane < 3) {
            setState(() => playerLane++);
            settingsManager.playClick();
          }
        },
        onTap: _jump,
        child: Stack(
          children: [
            _buildRoad(),
            ...obstacles.map((obs) => _buildObstacleWidget(obs)),
            _buildPlayerWidget(),
            _buildUI(),
            if (_showCountdown)
              CountdownOverlay(
                onFinished: () {
                  setState(() => _showCountdown = false);
                  _startGame();
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoad() {
    return CustomPaint(
      size: Size.infinite,
      painter: RoadPainter(
        offset: roadOffset,
        lanes: 4,
      ),
    );
  }

  Widget _buildPlayerWidget() {
    double laneWidth = MediaQuery.of(context).size.width / 4;
    double xPos = laneWidth * playerLane + (laneWidth / 2) - 25;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      bottom: 100,
      left: xPos,
      child: ScaleTransition(
        scale: TweenSequence([
          TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.4), weight: 50),
          TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 1.0), weight: 50),
        ]).animate(_jumpController),
        child: Container(
          width: 50,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isJumping ? 0.4 : 0.6),
                blurRadius: isJumping ? 20 : 8,
                offset: Offset(0, isJumping ? 15 : 4),
              ),
            ],
          ),
          child: _buildCarDetails(const Color(0xFFD4AF37), isPlayer: true),
        ),
      ),
    );
  }

  Widget _buildObstacleWidget(Obstacle obs) {
    double laneWidth = MediaQuery.of(context).size.width / 4;
    double xPos = laneWidth * obs.lane + (laneWidth / 2) - 25;
    bool isTruck = obs.type == ObstacleType.truck;
    bool isF1 = obs.type == ObstacleType.f1;

    return Positioned(
      top: obs.y,
      left: xPos,
      child: RotatedBox(
        quarterTurns: 2,
        child: Container(
          width: 50,
          height: isTruck ? 200 : 80,
          decoration: BoxDecoration(
            color: isTruck ? Colors.transparent : (isF1 ? Colors.greenAccent : Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
          child: isTruck
              ? _buildTruckDetails()
              : (isF1 ? _buildF1Details() : _buildCarDetails(Colors.white)),
        ),
      ),
    );
  }

  Widget _buildCarDetails(Color color, {bool isPlayer = false}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Stack(
        children: [
          Positioned(top: 10, left: 8, right: 8, child: Container(height: 12, decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)))),
          Positioned(bottom: 15, left: 10, right: 10, child: Container(height: 20, decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)))),
          Positioned(top: 5, left: 6, child: Container(width: 8, height: 4, decoration: BoxDecoration(color: isPlayer ? Colors.yellowAccent : Colors.redAccent, borderRadius: BorderRadius.circular(2)))),
          Positioned(top: 5, right: 6, child: Container(width: 8, height: 4, decoration: BoxDecoration(color: isPlayer ? Colors.yellowAccent : Colors.redAccent, borderRadius: BorderRadius.circular(2)))),
        ],
      ),
    );
  }

  Widget _buildF1Details() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.greenAccent[700],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, right: 0, child: Container(height: 10, color: Colors.black)),
          Center(child: Container(width: 15, height: 30, decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(10)))),
          Positioned(top: 15, left: -5, child: Container(width: 12, height: 20, color: Colors.black)),
          Positioned(top: 15, right: -5, child: Container(width: 12, height: 20, color: Colors.black)),
          Positioned(bottom: 10, left: -5, child: Container(width: 12, height: 20, color: Colors.black)),
          Positioned(bottom: 10, right: -5, child: Container(width: 12, height: 20, color: Colors.black)),
          Positioned(top: 5, left: 10, child: Container(width: 5, height: 2, color: Colors.cyanAccent)),
          Positioned(top: 5, right: 10, child: Container(width: 5, height: 2, color: Colors.cyanAccent)),
        ],
      ),
    );
  }

  Widget _buildTruckDetails() {
    return Column(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.blueGrey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Positioned(top: 5, left: 5, child: Container(width: 8, height: 4, color: Colors.orange)),
              Positioned(top: 5, right: 5, child: Container(width: 8, height: 4, color: Colors.orange)),
            ],
          ),
        ),
        Container(width: 12, height: 10, color: Colors.black),
        Expanded(
          child: Container(
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: const Center(child: RotatedBox(quarterTurns: 1, child: Text("DANGER", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 10)))),
          ),
        ),
      ],
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildHeaderStat("SCORE", score.toString(), Colors.orangeAccent),
            _buildHeaderStat("CHRONO", _formatTime(secondsElapsed), Colors.cyanAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class RoadPainter extends CustomPainter {
  final double offset;
  final int lanes;
  RoadPainter({required this.offset, required this.lanes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white24..strokeWidth = 2;
    double laneWidth = size.width / lanes;

    for (int i = 1; i < lanes; i++) {
      double x = laneWidth * i;
      double dashHeight = 40;
      double dashSpace = 20;
      double startY = offset % (dashHeight + dashSpace);

      while (startY < size.height) {
        canvas.drawLine(Offset(x, startY), Offset(x, startY + dashHeight), paint);
        startY += dashHeight + dashSpace;
      }

      double backY = startY - (dashHeight + dashSpace);
      while (backY > -dashHeight) {
        canvas.drawLine(Offset(x, backY), Offset(x, backY + dashHeight), paint);
        backY -= (dashHeight + dashSpace);
      }
    }
  }

  @override
  bool shouldRepaint(RoadPainter oldDelegate) => true;
}