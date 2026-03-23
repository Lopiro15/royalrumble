import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/quiz/quiz_data_mot_fantome.dart';

// ---------------------------------------------------------------------------
// QuizTypeMotFantome — Type 2 : Saisie sous pression
// Timing inchangé : 20s (le clavier chaotique crée déjà assez de pression)
// questionIndex : index pré-calculé par le moteur (unicité garantie)
// Overflow fix : LayoutBuilder adaptatif + padding réduit
// onAnswered : appelé IMMÉDIATEMENT
// ---------------------------------------------------------------------------
class QuizTypeMotFantome extends StatefulWidget {
  final void Function(int pointsEarned) onAnswered;
  final int questionIndex;

  const QuizTypeMotFantome({
    super.key,
    required this.onAnswered,
    required this.questionIndex,
  });

  @override
  State<QuizTypeMotFantome> createState() => _QuizTypeMotFantomeState();
}

class _QuizTypeMotFantomeState extends State<QuizTypeMotFantome>
    with SingleTickerProviderStateMixin {

  static const int _timerSec           = 20;
  static const int _shuffleIntervalSec = 5;

  static const List<String> _allLetters = [
    'A','B','C','D','E','F','G','H','I','J','K','L','M',
    'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
  ];

  late final Map<String, String> _question;
  String  _typed      = '';
  bool    _answered   = false;
  int     _timeLeft   = _timerSec;
  int     _shuffleIn  = _shuffleIntervalSec;
  bool    _shaking    = false;
  bool    _wrongFlash = false;
  List<String> _keyboard = List.from(_allLetters);
  Timer? _gameTimer;
  Timer? _shuffleTimer;
  late final AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _question  = quizMotFantomeQuestions[widget.questionIndex % quizMotFantomeQuestions.length];
    _startTimers();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _shuffleTimer?.cancel();
    _shakeCtrl.dispose();
    super.dispose();
  }

  /// Lance le timer principal + le timer de shuffle du clavier.
  void _startTimers() {
    _timeLeft  = _timerSec;
    _shuffleIn = _shuffleIntervalSec;

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) { t.cancel(); _shuffleTimer?.cancel(); _handleResult(false); }
    });

    _shuffleTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _answered) { t.cancel(); return; }
      setState(() {
        _shuffleIn--;
        if (_shuffleIn <= 0) {
          _shuffleIn = _shuffleIntervalSec;
          _keyboard  = List.from(_allLetters)..shuffle(Random());
        }
      });
    });
  }

  /// Ajoute une lettre et vérifie la réponse.
  void _onKeyTap(String letter) {
    if (_answered) return;
    setState(() => _typed += letter);
    if (_typed == _question['answer']) {
      _gameTimer?.cancel();
      _shuffleTimer?.cancel();
      _handleResult(true);
    } else if (_typed.length >= _question['answer']!.length) {
      _triggerShake();
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) setState(() => _typed = '');
      });
    }
  }

  /// Efface la dernière lettre.
  void _onDelete() {
    if (_answered || _typed.isEmpty) return;
    setState(() => _typed = _typed.substring(0, _typed.length - 1));
  }

  /// Tremblement du clavier + flash rouge sur les touches.
  void _triggerShake() {
    _shakeCtrl.reset();
    _shakeCtrl.forward();
    setState(() { _shaking = true; _wrongFlash = true; });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() { _shaking = false; _wrongFlash = false; });
    });
  }

  /// Notifie le moteur IMMÉDIATEMENT sans délai.
  void _handleResult(bool success) {
    if (_answered) return;
    setState(() => _answered = true);
    widget.onAnswered(success ? 100 : 0);
  }

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFF4FC3F7);
    final double ratio = _timeLeft / _timerSec;
    final Color tColor = ratio > 0.5 ? accent : ratio > 0.25 ? Colors.orange : Colors.redAccent;

    // LayoutBuilder pour calculer l'espace disponible et adapter les tailles
    return LayoutBuilder(
      builder: (context, constraints) {
        // Hauteur allouée aux éléments fixes (badge + timer + shuffle + définition + cases)
        const double fixedHeight = 170.0;
        // Hauteur restante pour le clavier
        final double keyboardH = (constraints.maxHeight - fixedHeight).clamp(120.0, 400.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            children: [
              _buildTypeBadge('⌨️ MOT FANTÔME', accent),
              const SizedBox(height: 10),
              _buildTimerBar(ratio, tColor),
              const SizedBox(height: 4),
              Text('Mélange dans ${_shuffleIn}s',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11)),
              const SizedBox(height: 12),
              Text(_question['definition']!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 19, height: 1.3))
                  .animate().fadeIn(),
              const SizedBox(height: 12),
              _buildTypedDisplay(accent),
              const SizedBox(height: 10),
              // Clavier avec hauteur contrainte
              SizedBox(height: keyboardH, child: _buildKeyboard(accent, keyboardH)),
            ],
          ),
        );
      },
    );
  }

  /// Cases affichant les lettres saisies.
  Widget _buildTypedDisplay(Color accent) {
    final int len = _question['answer']!.length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(len, (i) {
        final bool filled = i < _typed.length;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 34, height: 42,
          decoration: BoxDecoration(
            color: filled ? accent.withValues(alpha: 0.2) : Colors.white10,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: filled ? accent : Colors.white24, width: filled ? 2 : 1.5),
          ),
          child: Center(child: Text(filled ? _typed[i] : '',
              style: TextStyle(color: accent, fontSize: 19))),
        );
      }),
    );
  }

  /// Clavier adaptatif : taille des touches calculée selon la hauteur disponible.
  Widget _buildKeyboard(Color accent, double availableH) {
    final rows = _buildRows();
    // Nombre de rangées : lettres + 1 rangée effacement
    final int totalRows = rows.length + 1;
    // Hauteur d'une rangée
    final double rowH    = (availableH - totalRows * 4) / totalRows;
    final double keySize = rowH.clamp(28.0, 44.0);
    final double fSize   = (keySize * 0.38).clamp(10.0, 16.0);

    Widget keyboard = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...rows.map((row) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((l) => _buildKey(l, accent, keySize, fSize)).toList(),
          ),
        )),
        const SizedBox(height: 4),
        // Touche effacement
        GestureDetector(
          onTap: _onDelete,
          child: Container(
            height: keySize,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.backspace_rounded, color: Colors.redAccent, size: keySize * 0.4),
              const SizedBox(width: 6),
              Text('EFFACER', style: TextStyle(color: Colors.redAccent, fontSize: fSize)),
            ]),
          ),
        ),
      ],
    );

    if (_shaking) {
      keyboard = keyboard.animate().shakeX(amount: 10, duration: 350.ms);
    }
    return keyboard;
  }

  List<List<String>> _buildRows() {
    const int perRow = 6;
    final rows = <List<String>>[];
    for (int i = 0; i < _keyboard.length; i += perRow) {
      rows.add(_keyboard.sublist(i, min(i + perRow, _keyboard.length)));
    }
    return rows;
  }

  Widget _buildKey(String letter, Color accent, double size, double fontSize) {
    return GestureDetector(
      onTap: () => _onKeyTap(letter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.all(2),
        width: size, height: size,
        decoration: BoxDecoration(
          color: _wrongFlash ? Colors.red.withValues(alpha: 0.2) : const Color(0xFF002147),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _wrongFlash ? Colors.redAccent.withValues(alpha: 0.6) : accent.withValues(alpha: 0.3)),
        ),
        child: Center(child: Text(letter, style: TextStyle(color: accent, fontSize: fontSize))),
      ),
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