import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/settings_manager.dart';
import '../../data/quiz/quiz_data_invisible.dart';
import '../../data/quiz/quiz_data_mot_fantome.dart';
import '../../data/quiz/quiz_data_miroir.dart';
import '../../data/quiz/quiz_data_enchere.dart';
import '../../data/quiz/quiz_data_infiltration.dart';
import '../../widgets/quiz/quiz_type_invisible.dart';
import '../../widgets/quiz/quiz_type_mot_fantome.dart';
import '../../widgets/quiz/quiz_type_miroir.dart';
import '../../widgets/quiz/quiz_type_enchere.dart';
import '../../widgets/quiz/quiz_type_infiltration.dart';
import 'quiz_result_screen.dart';

// ---------------------------------------------------------------------------
// QuizGameScreen — Moteur central de la partie quiz
//
// Corrections apportées :
//   1. Questions uniques : chaque question n'apparaît qu'une seule fois par partie
//      via un Set d'indices déjà utilisés transmis à chaque widget
//   2. Bug feedback ✗ corrigé : suppression du Future.delayed(400ms) dans les widgets
//      → onAnswered est appelé immédiatement, le feedback vient du moteur
//   3. Musique de partie : startQuizMusic() au lieu de playGameStart()
//   4. Timings augmentés (sauf Mot Fantôme)
// ---------------------------------------------------------------------------
class QuizGameScreen extends StatefulWidget {
  final String gameMode;
  const QuizGameScreen({super.key, required this.gameMode});

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen>
    with TickerProviderStateMixin {

  static const int _totalQuestions  = 10;
  static const List<int> _availableTypes = [0, 1, 2, 3, 4];

  // --- État de partie ---
  int  _currentIndex      = 0;
  int  _score             = 0;
  int  _pointsJustEarned  = 0;
  bool _showFeedback      = false;
  bool _lastAnswerCorrect = false;
  bool _transitioning     = false;

  late final List<int> _questionSequence;

  // Indices pré-calculés une fois pour toutes au démarrage.
  // _questionIndices[i] = index dans la base de données pour la question i.
  // Calculé dans initState → jamais recalculé dans build() → 0 question fantôme.
  late final List<int> _questionIndices;

  // Suivi des questions déjà utilisées par type (pour éviter les doublons)
  final Map<int, Set<int>> _usedIndices = {
    0: {}, 1: {}, 2: {}, 3: {}, 4: {},
  };

  late final AnimationController _scoreAnim;

  // ---------------------------------------------------------------------------
  // Cycle de vie
  // ---------------------------------------------------------------------------

  /// Initialise la partie, génère la séquence, pré-calcule tous les indices,
  /// lance la musique de quiz.
  @override
  void initState() {
    super.initState();
    _questionSequence = _generateSequence();
    // Pré-calcule un index unique pour CHACUNE des 10 questions dès le départ.
    // Ainsi build() ne tire jamais de nouvel index → plus de question fantôme.
    _questionIndices = List.generate(
      _totalQuestions,
      (i) => _getNextQuestionIndex(_questionSequence[i]),
    );
    _scoreAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    settingsManager.startQuizMusic();
  }

  /// Arrête la musique de partie quand on quitte cet écran (quelle que soit la raison).
  @override
  void dispose() {
    settingsManager.stopMusic();
    _scoreAnim.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Logique
  // ---------------------------------------------------------------------------

  /// Génère une séquence de 10 types : 1 de chaque + 5 aléatoires, mélangés.
  List<int> _generateSequence() {
    final rand = Random();
    final List<int> seq = List.from(_availableTypes);
    while (seq.length < _totalQuestions) {
      seq.add(_availableTypes[rand.nextInt(_availableTypes.length)]);
    }
    seq.shuffle(rand);
    return seq;
  }

  /// Retourne le prochain index de question non utilisé pour un type donné.
  /// Si toutes les questions ont été posées, repart du début (reset du Set).
  int _getNextQuestionIndex(int type) {
    final int total = _totalQuestionsForType(type);
    final Set<int> used = _usedIndices[type]!;

    // Si tout a été utilisé, reset pour éviter de bloquer
    if (used.length >= total) used.clear();

    // Tire un index non encore utilisé
    final rand = Random();
    int idx;
    do { idx = rand.nextInt(total); } while (used.contains(idx));
    used.add(idx);
    return idx;
  }

  /// Retourne le nombre total de questions disponibles pour un type.
  int _totalQuestionsForType(int type) {
    switch (type) {
      case 0: return quizInvisibleScenes.length;
      case 1: return quizMotFantomeQuestions.length;
      case 2: return quizMiroirQuestions.length;
      case 3: return quizEnchereQuestions.length;
      case 4: return quizInfiltrationQuestions.length;
      default: return 1;
    }
  }

  /// Callback appelé immédiatement par chaque widget quand le joueur répond.
  /// CORRECTION BUG : plus de Future.delayed ici — le feedback est instantané
  /// et _lastAnswerCorrect reflète exactement les points reçus.
  void _onAnswered(int pointsEarned) {
    if (!mounted || _transitioning) return;

    setState(() {
      _score             += pointsEarned;
      _pointsJustEarned   = pointsEarned;
      // Correct = tout score > 0 (y compris 40, 50, 70 pts des types à score variable)
      _lastAnswerCorrect  = pointsEarned > 0;
      _showFeedback       = true;
      _transitioning      = true;
    });

    // Animation bounce sur le score si points gagnés
    if (pointsEarned > 0) {
      _scoreAnim.reset();
      _scoreAnim.forward();
    }

    // Feedback visible 1.0s puis question suivante
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() {
        _showFeedback  = false;
        _currentIndex++;
        _transitioning = false;
      });
      if (_currentIndex >= _totalQuestions) _finishGame();
    });
  }

  /// Navigue vers l'écran de résultats.
  void _finishGame() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => QuizResultScreen(
          score:    _score,
          maxScore: _totalQuestions * 100,
          quizName: 'QUIZ',
          gameMode: widget.gameMode,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF001A33);
    const Color royalGold   = Color(0xFFD4AF37);

    if (_currentIndex >= _totalQuestions) {
      return const Scaffold(
        backgroundColor: Color(0xFF001A33),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
      );
    }

    return Scaffold(
      backgroundColor: primaryBlue,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end:   Alignment.bottomCenter,
            colors: [Color(0xFF002147), primaryBlue],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildTopBar(royalGold),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, anim) => SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.08, 0),
                          end:   Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: anim, curve: Curves.easeOutCubic)),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: _buildCurrentQuestion(),
                    ),
                  ),
                ],
              ),
              if (_showFeedback) _buildFeedbackOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  /// Barre supérieure : score animé + badge type + progression.
  Widget _buildTopBar(Color gold) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Score avec animation bounce
              AnimatedBuilder(
                animation: _scoreAnim,
                builder: (_, __) {
                  final double scale = 1.0 +
                      Curves.elasticOut.transform(_scoreAnim.value) * 0.15;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: gold.withValues(alpha: 0.4)),
                      ),
                      child: Text('⭐ $_score pts',
                          style: TextStyle(color: gold, fontSize: 14, letterSpacing: 1)),
                    ),
                  );
                },
              ),
              _buildQuestionTypeBadge(),
              Text('${_currentIndex + 1} / $_totalQuestions',
                  style: const TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 8),
          // Barre de progression animée
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _currentIndex / _totalQuestions),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value, minHeight: 6,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(gold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Badge coloré indiquant le type de la question en cours.
  Widget _buildQuestionTypeBadge() {
    const List<Map<String, dynamic>> typeInfo = [
      {'label': '⚡ INVISIBLE',    'color': Color(0xFFD4AF37)},
      {'label': '⌨️ FANTÔME',     'color': Color(0xFF4FC3F7)},
      {'label': '🪞 MIROIR',       'color': Color(0xFF81C784)},
      {'label': '⏱ ENCHÈRE',      'color': Color(0xFFFFB74D)},
      {'label': '🔍 INFILTRATION', 'color': Color(0xFFCE93D8)},
    ];
    if (_currentIndex >= _totalQuestions) return const SizedBox.shrink();
    final info = typeInfo[_questionSequence[_currentIndex]];
    final Color c = info['color'] as Color;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.4)),
      ),
      child: Text(info['label'] as String,
          style: TextStyle(color: c, fontSize: 11, letterSpacing: 0.5)),
    );
  }

  /// Retourne le widget du type de question en cours.
  /// Utilise l'index pré-calculé dans initState → jamais de tirage dans build().
  Widget _buildCurrentQuestion() {
    final int type        = _questionSequence[_currentIndex];
    final int questionIdx = _questionIndices[_currentIndex]; // ← pré-calculé, stable
    final key             = ValueKey('q_$_currentIndex');    // clé simple suffit

    switch (type) {
      case 0: return QuizTypeInvisible(
          key: key, questionIndex: questionIdx, onAnswered: _onAnswered);
      case 1: return QuizTypeMotFantome(
          key: key, questionIndex: questionIdx, onAnswered: _onAnswered);
      case 2: return QuizTypeMiroir(
          key: key, questionIndex: questionIdx, onAnswered: _onAnswered);
      case 3: return QuizTypeEnchere(
          key: key, questionIndex: questionIdx, onAnswered: _onAnswered);
      case 4: return QuizTypeInfiltration(
          key: key, questionIndex: questionIdx, onAnswered: _onAnswered);
      default: return QuizTypeInvisible(
          key: key, questionIndex: questionIdx, onAnswered: _onAnswered);
    }
  }

  /// Overlay feedback : vert si correct (même 40pts), rouge si 0pt.
  Widget _buildFeedbackOverlay() {
    final bool   correct = _lastAnswerCorrect;
    final Color  color   = correct ? Colors.greenAccent : Colors.redAccent;
    // Affiche le nombre exact de points ou ✗
    final String text    = correct ? '+$_pointsJustEarned' : '✗';

    return IgnorePointer(
      child: Stack(
        children: [
          // Flash de fond coloré
          Container(
            color: correct
                ? Colors.green.withValues(alpha: 0.07)
                : Colors.red.withValues(alpha: 0.07),
          ),
          // Texte central animé qui monte et disparaît
          Center(
            child: Text(
              text,
              style: TextStyle(
                color: color, fontSize: 90,
                shadows: [Shadow(color: color.withValues(alpha: 0.7), blurRadius: 40)],
              ),
            )
                .animate()
                .fadeIn(duration: 150.ms)
                .scale(begin: const Offset(0.4, 0.4), duration: 400.ms,
                    curve: Curves.elasticOut)
                .then()
                .moveY(begin: 0, end: -60, duration: 600.ms, curve: Curves.easeIn)
                .fadeOut(duration: 400.ms),
          ),
        ],
      ),
    );
  }
}