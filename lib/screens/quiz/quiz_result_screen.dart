import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/settings_manager.dart';
import '../../services/score_manager.dart'; // Sauvegarde du meilleur score

// ---------------------------------------------------------------------------
// QuizResultScreen — Écran de fin de partie quiz
//
// Affiche le score sur 10 questions, un message selon la perf,
// et joue victory.mp3 (>= 50%) ou losing.mp3 (< 50%)
// Boutons : Rejouer (retour à GameMenuScreen) ou Menu principal
// ---------------------------------------------------------------------------
class QuizResultScreen extends StatefulWidget {
  final int score;        // Score obtenu
  final int maxScore;     // Score maximum (10 × 100 = 1000)
  final String quizName;  // Nom du quiz
  final String gameMode;  // Mode de jeu (solo/duo/entrainement)

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.maxScore,
    required this.quizName,
    required this.gameMode,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {

  @override
  void initState() {
    super.initState();
    _playResultMusic();
    _saveScore(); // Sauvegarde automatique du score à la fin de chaque partie
  }

  /// Sauvegarde le score dans le classement persistant via ScoreManager.
  /// Utilise le nom du joueur stocké dans settingsManager.
  Future<void> _saveScore() async {
    await scoreManager.saveScore(
      score:      widget.score,
      maxScore:   widget.maxScore,
      gameMode:   widget.gameMode,
      playerName: settingsManager.playerName,
      gameName:   widget.quizName, // "QUIZ" — sera "MEMORY" etc. pour les futurs jeux
    );
  }

  // Joue le son de victoire ou défaite selon le score
  void _playResultMusic() {
    final ratio = widget.maxScore > 0 ? widget.score / widget.maxScore : 0.0;
    if (ratio >= 0.5) {
      settingsManager.playVictory();
    } else {
      settingsManager.playDefeat();
    }
  }

  // Message et emoji selon la performance
  String get _resultTitle {
    final ratio = widget.score / widget.maxScore;
    if (ratio == 1.0)  return '🏆 PARFAIT !';
    if (ratio >= 0.8)  return '🥇 EXCELLENT !';
    if (ratio >= 0.6)  return '🥈 BIEN JOUÉ !';
    if (ratio >= 0.4)  return '💪 PAS MAL !';
    return '😬 ENCORE ESSAYER...';
  }

  // Couleur accent selon la performance
  Color get _resultColor {
    final ratio = widget.score / widget.maxScore;
    if (ratio >= 0.6) return const Color(0xFFD4AF37);
    if (ratio >= 0.4) return Colors.orange;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF001A33);
    final double ratio = widget.maxScore > 0 ? widget.score / widget.maxScore : 0;

    return Scaffold(
      backgroundColor: primaryBlue,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF002147), primaryBlue],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              // Mode de jeu
              Text(
                'MODE ${widget.gameMode.toUpperCase()}',
                style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12, letterSpacing: 3),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 8),

              // Titre résultat
              Text(
                _resultTitle,
                style: TextStyle(color: _resultColor, fontSize: 34, letterSpacing: 2),
              )
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    delay: 300.ms,
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),

              const SizedBox(height: 40),

              // Cercle de score animé
              SizedBox(
                width: 170, height: 170,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 170, height: 170,
                      child: CircularProgressIndicator(
                        value: ratio,
                        strokeWidth: 12,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(_resultColor),
                      ).animate().fadeIn(delay: 500.ms),
                    ),
                    Text(
                      '${(ratio * 100).round()}%',
                      style: TextStyle(color: _resultColor, fontSize: 42),
                    ).animate().fadeIn(delay: 700.ms),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Score détaillé
              Text(
                '${widget.score} pts',
                style: const TextStyle(color: Colors.white60, fontSize: 15, letterSpacing: 0.5),
              ).animate().fadeIn(delay: 700.ms),

              const Spacer(),

              // Boutons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    // Rejouer → retour au GameMenuScreen
                    _buildBtn(
                      label: 'REJOUER',
                      icon: Icons.replay_rounded,
                      color: _resultColor,
                      onTap: () {
                        settingsManager.playClick();
                        settingsManager.startMusic();
                        Navigator.pop(context);
                      },
                    ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2),

                    const SizedBox(height: 14),

                    // Menu principal → pop tout
                    _buildBtn(
                      label: 'MENU',
                      icon: Icons.home_rounded,
                      color: Colors.white.withOpacity(0.85),
                      textColor: const Color(0xFF001A33),
                      onTap: () {
                        settingsManager.playClick();
                        settingsManager.startMusic();
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    ).animate().fadeIn(delay: 1050.ms).slideY(begin: 0.2),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Bouton générique
  Widget _buildBtn({required String label, required IconData icon, required Color color, Color? textColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor ?? Colors.white, size: 26),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: textColor ?? Colors.white, fontSize: 22, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }
}