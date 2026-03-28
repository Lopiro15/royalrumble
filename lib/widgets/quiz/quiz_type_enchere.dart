import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/quiz/quiz_data_enchere.dart';

// ---------------------------------------------------------------------------
// QuizTypeEnchere — Type 4 : Enchère Inversée
// Timing : 20s total, indice 1 à 5s, indice 2 à 12s
// Score : 100 / 40 / 20 pts selon le moment
// onAnswered : appelé IMMÉDIATEMENT
// ---------------------------------------------------------------------------
class QuizTypeEnchere extends StatefulWidget {
  final void Function(int pointsEarned) onAnswered;
  final int questionIndex;

  const QuizTypeEnchere({
    super.key,
    required this.onAnswered,
    required this.questionIndex,
  });

  @override
  State<QuizTypeEnchere> createState() => _QuizTypeEnchereState();
}

class _QuizTypeEnchereState extends State<QuizTypeEnchere> {

  static const int _totalSec = 20; // Augmenté
  static const int _hint1Sec = 5;  // Indice 1 à 5s écoulées
  static const int _hint2Sec = 12; // Indice 2 à 12s écoulées

  late final Map<String, dynamic> _question;
  bool    _answered       = false;
  String? _selectedChoice;
  int     _elapsed        = 0;
  int     _hintsVisible   = 0;
  Timer?  _timer;

  @override
  void initState() {
    super.initState();
    _question = quizEnchereQuestions[widget.questionIndex % quizEnchereQuestions.length];
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Timer qui décompte et révèle les indices aux bons moments.
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _elapsed++;
        if (_elapsed == _hint1Sec) _hintsVisible = 1;
        if (_elapsed == _hint2Sec) _hintsVisible = 2;
      });
      if (_elapsed >= _totalSec) { t.cancel(); _handleAnswer(null); }
    });
  }

  /// Points selon le moment de la réponse.
  int _computePoints() {
    if (_elapsed < _hint1Sec) return 100;
    if (_elapsed < _hint2Sec) return 40;
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
    const Color accent = Color(0xFFFFB74D);
    final choices      = _question['choices'] as List<dynamic>;
    final double ratio = 1 - (_elapsed / _totalSec);
    final Color tColor = ratio > 0.5 ? accent : ratio > 0.25 ? Colors.orange : Colors.redAccent;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        children: [
          _buildTypeBadge('⏱ ENCHÈRE INVERSÉE', accent),
          const SizedBox(height: 12),
          _buildTimerBar(ratio, tColor),
          const SizedBox(height: 10),
          _buildLivePoints(accent),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF002147),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Text(_question['question'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.5)),
          ).animate().fadeIn(),
          const SizedBox(height: 10),
          if (_hintsVisible >= 1) _buildHint(_question['hint1'] as String, accent),
          if (_hintsVisible >= 2) _buildHint(_question['hint2'] as String, Colors.orange),
          const SizedBox(height: 12),
          ...choices.asMap().entries.map((e) =>
              _buildChoiceBtn(e.value as String, e.key, accent)),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildLivePoints(Color accent) {
    final int pts       = _answered ? 0 : _computePoints();
    final Color ptColor = pts >= 100 ? Colors.greenAccent : pts >= 40 ? accent : Colors.orange;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: ptColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ptColor.withValues(alpha: 0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('Répondre maintenant → ',
            style: TextStyle(color: Colors.white54, fontSize: 13)),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text('$pts pts', key: ValueKey(pts),
              style: TextStyle(color: ptColor, fontSize: 18, letterSpacing: 0.5)),
        ),
      ]),
    );
  }

  Widget _buildHint(String hint, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Text(hint, style: TextStyle(color: color, fontSize: 13)),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3, curve: Curves.easeOut),
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
      padding: const EdgeInsets.only(bottom: 9),
      child: GestureDetector(
        onTap: _answered ? null : () => _handleAnswer(choice),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: 1.5)),
          child: Text(choice, textAlign: TextAlign.center,
              style: TextStyle(color: text, fontSize: 16)),
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
      Text('${_totalSec - _elapsed} s', style: TextStyle(color: color, fontSize: 13)),
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