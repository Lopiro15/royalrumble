import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import '../../services/score_manager.dart';
import '../../services/settings_manager.dart';
import '../../stores/versus_store.dart';

class VersusRoundResultScreen extends StatelessWidget {
  final bool won;
  final int myScore;
  final int opponentScore;
  final int myWins;
  final int opponentWins;
  final int winsNeeded;
  final String gameName;
  final VoidCallback onContinue;

  const VersusRoundResultScreen({
    super.key,
    required this.won,
    required this.myScore,
    required this.opponentScore,
    required this.myWins,
    required this.opponentWins,
    required this.winsNeeded,
    required this.gameName,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF001A33);
    const Color royalGold = Color(0xFFD4AF37);

    if (won) {
      settingsManager.playVictory();
    } else {
      settingsManager.playDefeat();
    }

    return Scaffold(
      backgroundColor: primaryBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF002147), primaryBlue]),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(won ? '🏆' : '😓', style: const TextStyle(fontSize: 72))
                      .animate().scale(begin: const Offset(0.3, 0.3), end: const Offset(1, 1), duration: 500.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 16),
                  Text(won ? 'MANCHE GAGNÉE !' : 'MANCHE PERDUE...',
                      style: TextStyle(color: won ? royalGold : Colors.redAccent, fontSize: 28, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: royalGold.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(gameName, style: const TextStyle(color: royalGold, fontSize: 14)),
                  ),
                  const SizedBox(height: 24),
                  Text('$myScore - $opponentScore', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  _buildScoreBar(myWins, opponentWins, winsNeeded, royalGold),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () {
                      settingsManager.playClick();
                      onContinue();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(color: royalGold, borderRadius: BorderRadius.circular(20)),
                      child: const Text('MANCHE SUIVANTE', textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF001A33), fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBar(int myWins, int oppWins, int needed, Color gold) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('VOUS: $myWins', style: TextStyle(color: gold, fontSize: 14)),
            const SizedBox(width: 20),
            Text('ADV: $oppWins', style: const TextStyle(color: Colors.blueAccent, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(needed, (i) {
            Color color = i < myWins ? gold : (i < oppWins ? Colors.blueAccent : Colors.white24);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 24, height: 24,
              decoration: BoxDecoration(color: color.withOpacity(0.3), borderRadius: BorderRadius.circular(4), border: Border.all(color: color)),
              child: i < myWins ? const Icon(Icons.check, color: Color(0xFF001A33), size: 16) : null,
            );
          }),
        ),
        const SizedBox(height: 4),
        Text('Premier à $needed victoires', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
      ],
    );
  }
}

/// Recapitulatif final du duel
///
class VersusFinalRecapScreen extends StatefulWidget {
  final bool won;
  final int myWins;
  final int opponentWins;
  final List<Map<String, dynamic>> roundResults;
  final bool isHost;

  const VersusFinalRecapScreen({
    super.key,
    required this.won,
    required this.myWins,
    required this.opponentWins,
    required this.roundResults,
    required this.isHost,
  });

  @override
  State<VersusFinalRecapScreen> createState() => _VersusFinalRecapScreenState();
}

class _VersusFinalRecapScreenState extends State<VersusFinalRecapScreen> {
  @override
  void initState() {
    super.initState();
    _saveScore();
    if (widget.won) {
      settingsManager.playVictory();
    } else {
      settingsManager.playDefeat();
    }
  }

  Future<void> _saveScore() async {
    final opponentName = Get.find<VersusStore>().bluetoothService.connectedPlayer?.value?.name ?? 'Adversaire';

    await scoreManager.saveScore(
      score:        widget.myWins * 100 + 50, // Score pondéré
      maxScore:     (widget.myWins + widget.opponentWins) * 100,
      gameMode:     'duo',
      playerName:   settingsManager.playerName,
      gameName:     'VERSUS',
      opponentName: opponentName,
      won:          widget.won,
      finalScore:   '${widget.myWins}-${widget.opponentWins}',
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF001A33);
    const Color royalGold = Color(0xFFD4AF37);

    if (widget.won) {
      settingsManager.playVictory();
    } else {
      settingsManager.playDefeat();
    }

    return Scaffold(
      backgroundColor: primaryBlue,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF002147), primaryBlue]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(widget.won ? '🏆 VICTOIRE !' : '💪 BIEN JOUÉ !', style: TextStyle(color: widget.won ? royalGold : Colors.orange, fontSize: 32, letterSpacing: 3))
                  .animate().scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text('Score final: ${widget.myWins} - ${widget.opponentWins}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  itemCount: widget.roundResults.length,
                  itemBuilder: (context, index) {
                    final r = widget.roundResults[index];
                    final game = r['game'] as String;
                    final hostWon = r['hostWon'] as bool;
                    final iWon = widget.isHost ? hostWon : !hostWon;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF002147),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: iWon ? royalGold.withOpacity(0.5) : Colors.white24),
                      ),
                      child: Row(children: [
                        Container(width: 36, child: Text('${index + 1}', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.4)))),
                        const SizedBox(width: 12),
                        Expanded(child: Text(game, style: const TextStyle(color: Colors.white, fontSize: 14))),
                        Icon(iWon ? Icons.check_circle : Icons.cancel, color: iWon ? Colors.greenAccent : Colors.redAccent, size: 22),
                      ]),
                    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: -0.2);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: GestureDetector(
                  onTap: () {
                    settingsManager.playClick();
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(color: royalGold, borderRadius: BorderRadius.circular(20)),
                    child: const Text('MENU PRINCIPAL', textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF001A33), fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}