import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/quiz/quiz_data_invisible.dart';

// ---------------------------------------------------------------------------
// QuizTypeInvisible — Type 1 : Mémoire Flash
// Timings : flash 3s, réponse 18s
// questionIndex : index pré-calculé par le moteur (garantit l'unicité)
// onAnswered : appelé IMMÉDIATEMENT (plus de Future.delayed)
// ---------------------------------------------------------------------------
class QuizTypeInvisible extends StatefulWidget {
  final void Function(int pointsEarned) onAnswered;
  final int questionIndex; // Index unique fourni par QuizGameScreen

  const QuizTypeInvisible({
    super.key,
    required this.onAnswered,
    required this.questionIndex,
  });

  @override
  State<QuizTypeInvisible> createState() => _QuizTypeInvisibleState();
}

class _QuizTypeInvisibleState extends State<QuizTypeInvisible>
    with SingleTickerProviderStateMixin {

  static const int _flashMs  = 4000; // 4s de flash
  static const int _timerSec = 15;   // 15s pour répondre

  late final Map<String, dynamic> _scene;
  late final Map<String, dynamic> _question;
  bool    _isFlashing     = true;
  bool    _answered       = false;
  int     _timeLeft       = _timerSec;
  int     _flashLeft      = (_flashMs ~/ 1000);
  String? _selectedChoice;
  Timer?  _timer;
  Timer?  _flashCountdown;
  late final AnimationController _flashBarAnim;

  @override
  void initState() {
    super.initState();
    _flashBarAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _flashMs),
    )..forward();
    _pickQuestion();
    _startFlash();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flashCountdown?.cancel();
    _flashBarAnim.dispose();
    super.dispose();
  }

  /// Sélectionne la scène et une question via l'index fourni par le moteur.
  void _pickQuestion() {
    _scene = quizInvisibleScenes[widget.questionIndex % quizInvisibleScenes.length];
    final qs = _scene['questions'] as List;
    // Pour la question on tire au hasard parmi les 3 de la scène
    // (la scène est unique, pas la question individuelle)
    _question = qs[DateTime.now().millisecondsSinceEpoch % qs.length]
        as Map<String, dynamic>;
  }

  /// Affiche la scène 3s puis lance le timer de réponse.
  void _startFlash() {
    setState(() => _isFlashing = true);
    _flashCountdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _flashLeft--);
      if (_flashLeft <= 0) t.cancel();
    });
    Future.delayed(const Duration(milliseconds: _flashMs), () {
      if (!mounted) return;
      setState(() => _isFlashing = false);
      _startTimer();
    });
  }

  /// Démarre le compte à rebours de réponse.
  void _startTimer() {
    _timeLeft = _timerSec;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) { t.cancel(); _handleAnswer(null); }
    });
  }

  /// Traite la réponse et notifie le moteur IMMÉDIATEMENT (pas de délai).
  void _handleAnswer(String? choice) {
    if (_answered) return;
    _timer?.cancel();
    final bool correct = choice == _question['answer'] as String;
    setState(() { _answered = true; _selectedChoice = choice; });
    widget.onAnswered(correct ? 100 : 0);
  }

  @override
  Widget build(BuildContext context) {
    const Color gold = Color(0xFFD4AF37);
    return _isFlashing ? _buildFlashPhase(gold) : _buildQuestionPhase(gold);
  }

  Widget _buildFlashPhase(Color gold) {
    final String? imagePath = _scene['imagePath'] as String?;
    final String? sceneText = _scene['scene']     as String?;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTypeBadge('⚡ MÉMORISE !', gold),
            const SizedBox(height: 10),
            Text(
              _flashLeft > 0 ? 'Disparaît dans ${_flashLeft}s...' : 'Maintenant !',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12),
            ),
            const SizedBox(height: 6),
            AnimatedBuilder(
              animation: _flashBarAnim,
              builder: (_, __) => ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: 1 - _flashBarAnim.value,
                  minHeight: 5,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(gold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              constraints: const BoxConstraints(maxHeight: 280),
              padding: imagePath != null ? EdgeInsets.zero : const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF002147),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: gold.withValues(alpha: 0.6), width: 2),
                boxShadow: [BoxShadow(color: gold.withValues(alpha: 0.25),
                    blurRadius: 35, spreadRadius: 3)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: imagePath != null
                    ? Image.asset(imagePath, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text('⚠️ Image introuvable\n$imagePath',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.redAccent.withValues(alpha: 0.7), fontSize: 13)),
                        ))
                    : Text(sceneText ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 20, height: 1.7)),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(0.99, 0.99), end: const Offset(1.01, 1.01), duration: 1000.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionPhase(Color gold) {
    final choices      = _question['choices'] as List<dynamic>;
    final double ratio = _timeLeft / _timerSec;
    final Color tColor = ratio > 0.6 ? gold : ratio > 0.3 ? Colors.orange : Colors.redAccent;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        children: [
          _buildTypeBadge('🧠 QUIZ INVISIBLE', gold),
          const SizedBox(height: 12),
          _buildTimerBar(ratio, tColor),
          const SizedBox(height: 18),
          Text(_question['q'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 20, height: 1.4))
              .animate().fadeIn().slideY(begin: -0.1),
          const SizedBox(height: 20),
          ...choices.asMap().entries.map((e) =>
              _buildChoiceBtn(e.value as String, e.key, gold)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildChoiceBtn(String choice, int index, Color gold) {
    Color bg = const Color(0xFF002147), border = Colors.white24, text = Colors.white;
    if (_answered) {
      if (choice == _question['answer'] as String) {
        bg = Colors.green.withValues(alpha: 0.25); border = Colors.greenAccent; text = Colors.greenAccent;
      } else if (choice == _selectedChoice) {
        bg = Colors.red.withValues(alpha: 0.2); border = Colors.redAccent; text = Colors.redAccent;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: GestureDetector(
        onTap: _answered ? null : () => _handleAnswer(choice),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: 1.5)),
          child: Text(choice, textAlign: TextAlign.center,
              style: TextStyle(color: text, fontSize: 17)),
        ),
      ).animate().fadeIn(delay: (index * 70).ms).slideX(begin: 0.08),
    );
  }

  Widget _buildTimerBar(double ratio, Color color) {
    return Row(children: [
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: ratio, minHeight: 7,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(color)))),
      const SizedBox(width: 10),
      Text('$_timeLeft s', style: TextStyle(color: color, fontSize: 13)),
    ]);
  }

  Widget _buildTypeBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withValues(alpha: 0.4))),
      child: Text(label, style: TextStyle(color: color, fontSize: 13, letterSpacing: 1.5)),
    );
  }
}