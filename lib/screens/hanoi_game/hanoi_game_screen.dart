import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/settings_manager.dart';
import '../../widgets/countdown_overlay.dart';
import '../../widgets/menu_button.dart';

class HanoiGameScreen extends StatefulWidget {
  const HanoiGameScreen({super.key});

  @override
  State<HanoiGameScreen> createState() => _HanoiGameScreenState();
}

class _HanoiGameScreenState extends State<HanoiGameScreen> {
  late int numDisks;
  bool _showCountdown = true;
  late List<List<int>> pegs;
  late List<Color> diskColors;
  int moves = 0;
  int secondsElapsed = 0;
  Timer? timer;
  bool isGameStarted = false;
  bool isWon = false;

  final List<Color> availableColors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.tealAccent,
    Colors.pinkAccent,
  ];

  @override
  void initState() {
    super.initState();
    numDisks = Random().nextInt(3) + 4;
    _resetGame();
  }

  void _resetGame() {
    //numDisks = Random().nextInt(3) + 4; // Entre 4 et 6
    pegs = [
      List.generate(numDisks, (i) => numDisks - i),
      [],
      [],
    ];
    
    // Générer des couleurs aléatoires pour chaque taille de disque
    List<Color> shuffledColors = List.from(availableColors)..shuffle();
    diskColors = List.generate(numDisks + 1, (index) => shuffledColors[index % shuffledColors.length]);

    moves = 0;
    secondsElapsed = 0;
    isWon = false;
    isGameStarted = false;
    timer?.cancel();
    setState(() {});
  }

  void _startTimer() {
    isGameStarted = true;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        secondsElapsed++;
      });
    });
  }

  void _moveDisk(int from, int to) {
    if (pegs[from].isEmpty) return;
    
    int diskToMove = pegs[from].last;

    if (pegs[to].isEmpty || pegs[to].last > diskToMove) {
      if (!isGameStarted) _startTimer();
      settingsManager.playClick();
      setState(() {
        pegs[to].add(pegs[from].removeLast());
        moves++;
        _checkWin();
      });
    }
  }

  void _checkWin() {
    if (pegs[2].length == numDisks) {
      setState(() {
        isWon = true;
        timer?.cancel();
      });
      settingsManager.playWin();
      _showWinDialog();
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF002147),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFD4AF37))),
        title: const Text('TOUR RÉUSSIE !', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFD4AF37))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Color(0xFFD4AF37), size: 60).animate().scale(duration: 600.ms).then().shake(),
            const SizedBox(height: 20),
            Text('DISQUES : $numDisks', style: const TextStyle(color: Colors.white70)),
            Text('TEMPS : ${_formatTime(secondsElapsed)}', style: const TextStyle(color: Colors.white, fontSize: 18)),
            Text('COUPS : $moves', style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('REJOUER', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('MENU', style: TextStyle(color: Colors.white70)),
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
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF001A33);
    const Color royalGold = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('TOUR D\'HANOI', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF002147), primaryBlue],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoCard('COUPS', moves.toString()),
                    _buildInfoCard('TEMPS', _formatTime(secondsElapsed)),
                  ],
                ),
                const Spacer(),
                // Zone de jeu avec Drag and Drop
                SizedBox(
                  height: 350,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(3, (index) => _buildPegTarget(index, royalGold)),
                  ),
                ),
                 const Spacer(),
                // Padding(
                //   padding: const EdgeInsets.all(30),
                //   child: MenuButton(
                //     label: 'RECOMMENCER',
                //     icon: Icons.refresh_rounded,
                //     color: Colors.white10,
                //     fontSize: 18,
                //     onTap: _resetGame,
                //   ),
                // ),
              ],
            ),
          ),
          if (_showCountdown)
            CountdownOverlay(
              onFinished: () {
                setState(() => _showCountdown = false);
                _resetGame();
                _startTimer();
              },
            ),
        ],
      )
    );
  }

  Widget _buildPegTarget(int pegIndex, Color gold) {
    return DragTarget<Map<String, int>>(
      onWillAccept: (data) {
        if (isWon || data == null) return false;
        int fromPeg = data['fromPeg']!;
        int diskSize = data['diskSize']!;
        
        // On ne peut accepter que si c'est le disque du dessus et que la règle est respectée
        return pegs[pegIndex].isEmpty || pegs[pegIndex].last > diskSize;
      },
      onAccept: (data) {
        _moveDisk(data['fromPeg']!, pegIndex);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 110,
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // La tige
              Container(
                width: 10,
                height: 220,
                decoration: BoxDecoration(
                  color: candidateData.isNotEmpty ? gold : gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              // Socle de la tige
              Container(
                width: 80,
                height: 5,
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Les disques
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: List.generate(pegs[pegIndex].length, (i) {
                    int diskSize = pegs[pegIndex][i];
                    bool isTopDisk = i == pegs[pegIndex].length - 1;

                    if (isTopDisk && !isWon) {
                      return Draggable<Map<String, int>>(
                        data: {'fromPeg': pegIndex, 'diskSize': diskSize},
                        feedback: _buildDisk(diskSize, diskColors[diskSize], true),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: _buildDisk(diskSize, diskColors[diskSize]),
                        ),
                        child: _buildDisk(diskSize, diskColors[diskSize]),
                      );
                    }
                    return _buildDisk(diskSize, diskColors[diskSize]);
                  }).reversed.toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDisk(int size, Color color, [bool isFeedback = false]) {
    double width = 40.0 + (size * 12.0);
    
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        width: width,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: isFeedback ? 10 : 4,
              offset: const Offset(0, 2),
            ),
          ],
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Center(
          child: Text(
            size.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text(value, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
