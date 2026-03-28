import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/quiz/quiz_data_miroir.dart';

// ---------------------------------------------------------------------------
// QuizTypeMiroir — Type 3 : Inversion Cognitive
// Timing : 20s (le cerveau a besoin de temps pour lire à l'envers)
// Score dégressif : 100 / 70 / 40 / 20 pts selon rapidité
// onAnswered : appelé IMMÉDIATEMENT
// ---------------------------------------------------------------------------
class QuizTypeMiroir extends StatefulWidget {
  final void Function(int pointsEarned) onAnswered;
  final int questionIndex;

  const QuizTypeMiroir({
    super.key,
    required this.onAnswered,
    required this.questionIndex,
  });

  @override
  State<QuizTypeMiroir> createState() => _QuizTypeMiroirState();
}

class _QuizTypeMiroirState extends State<QuizTypeMiroir> {

  static const int _timerSec = 20; // Augmenté : lire en miroir prend du temps

  late final Map<String, dynamic> _question;
  bool    _answered       = false;
  String? _selectedChoice;
  int     _timeLeft       = _timerSec;
  Timer?  _timer;

  @override
  void initState() {
    super.initState();
    _question = quizMiroirQuestions[widget.questionIndex % quizMiroirQuestions.length];
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Compte à rebours de 20s.
  void _startTimer() {
    _timeLeft = _timerSec;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) { t.cancel(); _handleAnswer(null); }
    });
  }

  /// Score dégressif selon le temps restant.
  int _computePoints() {
    if (_timeLeft >= 15) return 100;
    if (_timeLeft >= 10) return 70;
    if (_timeLeft >= 5)  return 40;
    return 20;
  }

  /// Traite la réponse et notifie le moteur IMMÉDIATEMENT.
  void _handleAnswer(String? choice) {
    if (_answered) return;
    _timer?.cancel();
    final bool correct = choice == _question['answer'] as String;
    setState(() { _answered = true; _selectedChoice = choice; });
    widget.onAnswered(correct ? _computePoints() : 0);
  }

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFF81C784);
    final choices      = _question['choices'] as List<dynamic>;
    final double ratio = _timeLeft / _timerSec;
    final Color tColor = ratio > 0.6 ? accent : ratio > 0.3 ? Colors.orange : Colors.redAccent;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        children: [
          _buildTypeBadge('🪞 QUIZ MIROIR', accent),
          const SizedBox(height: 12),
          _buildTimerBar(ratio, tColor),
          const SizedBox(height: 8),
          _buildLivePoints(accent),
          const SizedBox(height: 12),
          Text('Lis la question à l\'envers et réponds !',
              style: TextStyle(color: accent.withValues(alpha: 0.65), fontSize: 12, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          // Question en miroir horizontal
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF002147),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withValues(alpha: 0.45), width: 1.5),
              boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.1), blurRadius: 20)],
            ),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
              child: Text(_question['question'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 19, height: 1.5)),
            ),
          )
              .animate().fadeIn(duration: 300.ms)
              .then()
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveX(begin: -1, end: 1, duration: 2500.ms, curve: Curves.easeInOut),
          const SizedBox(height: 16),
          ...choices.asMap().entries.map((e) =>
              _buildChoiceBtn(e.value as String, e.key, accent)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  /// Indicateur de points disponibles en temps réel.
  Widget _buildLivePoints(Color accent) {
    final int pts       = _answered ? 0 : _computePoints();
    final Color ptColor = pts >= 100 ? Colors.greenAccent
        : pts >= 70  ? accent : pts >= 40 ? Colors.orange : Colors.redAccent;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: ptColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ptColor.withValues(alpha: 0.4)),
      ),
      child: Text('Réponds maintenant → $pts pts',
          style: TextStyle(color: ptColor, fontSize: 13, letterSpacing: 0.5)),
    );
  }

  Widget _buildChoiceBtn(String choice, int index, Color accent) {
    Color bg = const Color(0xFF002147), border = Colors.white24, text = Colors.white;
    if (_answered) {
      if (choice == _question['answer'] as String) {
        bg = Colors.green.withValues(alpha: 0.25); border = Colors.greenAccent; text = Colors.greenAccent;
      } else if (choice == _selectedChoice) {
        bg = Colors.red.withValues(alpha: 0.2); border = Colors.redAccent; text = Colors.redAccent;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: _answered ? null : () => _handleAnswer(choice),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
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