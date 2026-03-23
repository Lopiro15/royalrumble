import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/quiz/quiz_data_infiltration.dart';

// ---------------------------------------------------------------------------
// InfiltrationPhase — États de la question (enum au niveau fichier)
// ---------------------------------------------------------------------------
enum InfiltrationPhase { hints, buzzed, failed, timeout }

// ---------------------------------------------------------------------------
// QuizTypeInfiltration — Type 5 : Indices & Buzz
// Timing : indice toutes les 6s (au lieu de 4s), buzz timer 15s (au lieu de 10s)
// questionIndex : index pré-calculé par le moteur (unicité garantie)
// onAnswered : appelé IMMÉDIATEMENT
// ---------------------------------------------------------------------------
class QuizTypeInfiltration extends StatefulWidget {
  final void Function(int pointsEarned) onAnswered;
  final int questionIndex;

  const QuizTypeInfiltration({
    super.key,
    required this.onAnswered,
    required this.questionIndex,
  });

  @override
  State<QuizTypeInfiltration> createState() => _QuizTypeInfiltrationState();
}

class _QuizTypeInfiltrationState extends State<QuizTypeInfiltration> {

  static const int _hintIntervalSec = 6;  // Indice toutes les 6s (augmenté)
  static const int _buzzTimerSec    = 15; // 15s après le buzz (augmenté)
  static const int _maxAttempts     = 3;

  late final Map<String, String> _question;
  InfiltrationPhase _phase        = InfiltrationPhase.hints;
  int  _hintsVisible  = 1;
  int  _buzzTimeLeft  = _buzzTimerSec;
  int  _attemptsLeft  = _maxAttempts;
  Timer? _hintTimer;
  Timer? _buzzTimer;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _question = quizInfiltrationQuestions[widget.questionIndex % quizInfiltrationQuestions.length];
    _startHintTimer();
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _buzzTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Révèle un indice toutes les 6s. Après 3 indices → timeout.
  void _startHintTimer() {
    _hintTimer = Timer.periodic(
      const Duration(seconds: _hintIntervalSec), (t) {
      if (!mounted || _phase != InfiltrationPhase.hints) { t.cancel(); return; }
      setState(() => _hintsVisible++);
      if (_hintsVisible > 3) {
        t.cancel();
        setState(() => _phase = InfiltrationPhase.timeout);
        widget.onAnswered(0);
      }
    });
  }

  /// Buzz : arrête les indices, lance le timer de saisie.
  void _onBuzz() {
    if (_phase != InfiltrationPhase.hints) return;
    _hintTimer?.cancel();
    setState(() => _phase = InfiltrationPhase.buzzed);
    _startBuzzTimer();
  }

  /// Timer de 15s après le buzz.
  void _startBuzzTimer() {
    _buzzTimeLeft = _buzzTimerSec;
    _buzzTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _buzzTimeLeft--);
      if (_buzzTimeLeft <= 0) { t.cancel(); _handleFailure(); }
    });
  }

  /// Points selon les indices visibles au moment du buzz.
  int _computePoints() {
    if (_hintsVisible <= 1) return 100;
    if (_hintsVisible <= 2) return 50;
    return 20;
  }

  /// Valide la saisie IMMÉDIATEMENT.
  void _submitAnswer() {
    if (_phase != InfiltrationPhase.buzzed) return;
    final String typed   = _controller.text.trim().toUpperCase();
    final String correct = _question['answer']!.toUpperCase();

    if (typed == correct) {
      _buzzTimer?.cancel();
      setState(() => _phase = InfiltrationPhase.failed);
      widget.onAnswered(_computePoints());
    } else {
      setState(() { _attemptsLeft--; _controller.clear(); });
      if (_attemptsLeft <= 0) { _buzzTimer?.cancel(); _handleFailure(); }
    }
  }

  /// Échec : 0 point, appelé immédiatement.
  void _handleFailure() {
    if (_phase == InfiltrationPhase.failed || _phase == InfiltrationPhase.timeout) return;
    setState(() => _phase = InfiltrationPhase.failed);
    widget.onAnswered(0);
  }

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFFCE93D8);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        children: [
          _buildTypeBadge('🔍 INFILTRATION', accent),
          const SizedBox(height: 16),
          Expanded(
            child: switch (_phase) {
              InfiltrationPhase.hints   => _buildHintsPhase(accent),
              InfiltrationPhase.buzzed  => _buildBuzzedPhase(accent),
              InfiltrationPhase.failed  => _buildEndPhase('❌ Raté !'),
              InfiltrationPhase.timeout => _buildEndPhase('⌛ Trop tard !'),
            },
          ),
        ],
      ),
    );
  }

  /// Phase indices : liste des indices + bouton BUZZ pulsant.
  Widget _buildHintsPhase(Color accent) {
    return Column(
      children: [
        if (_hintsVisible >= 1) _buildHintTile(_question['hint1']!, 1, accent),
        if (_hintsVisible >= 2) _buildHintTile(_question['hint2']!, 2, accent),
        if (_hintsVisible >= 3) _buildHintTile(_question['hint3']!, 3, accent),
        const Spacer(),
        GestureDetector(
          onTap: _onBuzz,
          child: Container(
            width: 160, height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.redAccent.withValues(alpha: 0.15),
              border: Border.all(color: Colors.redAccent, width: 3),
              boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.3),
                  blurRadius: 30, spreadRadius: 5)],
            ),
            child: const Center(child: Text('BUZZ\n!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.redAccent, fontSize: 28, letterSpacing: 2))),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 800.ms),
        ),
        const Spacer(),
        Text('Prochain indice dans quelques secondes...',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11)),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Phase après buzz : champ de saisie + timer + tentatives.
  Widget _buildBuzzedPhase(Color accent) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTimerBar(_buzzTimeLeft / _buzzTimerSec, Colors.redAccent),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_maxAttempts, (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 14, height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < _attemptsLeft ? Colors.redAccent : Colors.white.withValues(alpha: 0.12),
              ),
            )),
          ),
          const SizedBox(height: 8),
          Text('$_attemptsLeft tentative${_attemptsLeft > 1 ? 's' : ''} restante${_attemptsLeft > 1 ? 's' : ''}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
          const SizedBox(height: 20),
          if (_hintsVisible >= 1) _buildHintTile(_question['hint1']!, 1, accent),
          if (_hintsVisible >= 2) _buildHintTile(_question['hint2']!, 2, accent),
          if (_hintsVisible >= 3) _buildHintTile(_question['hint3']!, 3, accent),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              filled: true, fillColor: const Color(0xFF002147),
              hintText: 'Ta réponse...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: accent.withValues(alpha: 0.4))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: accent.withValues(alpha: 0.4))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: accent, width: 2)),
            ),
            onSubmitted: (_) => _submitAnswer(),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _submitAnswer,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withValues(alpha: 0.6), width: 1.5),
              ),
              child: Text('VALIDER', textAlign: TextAlign.center,
                  style: TextStyle(color: accent, fontSize: 18, letterSpacing: 2)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEndPhase(String message) {
    return Center(
      child: Text(message, style: const TextStyle(color: Colors.redAccent, fontSize: 36))
          .animate().scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),
    );
  }

  Widget _buildHintTile(String hint, int number, Color accent) {
    final Color tileColor = number == 1 ? accent : number == 2 ? Colors.orange : Colors.redAccent;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: tileColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tileColor.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          Text('$number', style: TextStyle(color: tileColor, fontSize: 12, letterSpacing: 1)),
          const SizedBox(width: 10),
          Expanded(child: Text(hint, style: TextStyle(color: tileColor, fontSize: 13))),
        ]),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3),
    );
  }

  Widget _buildTimerBar(double ratio, Color color) {
    return Row(children: [
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: ratio, minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color)))),
      const SizedBox(width: 10),
      Text('$_buzzTimeLeft s', style: TextStyle(color: color, fontSize: 13)),
    ]);
  }

  Widget _buildTypeBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 13, letterSpacing: 1.5)),
    );
  }
}