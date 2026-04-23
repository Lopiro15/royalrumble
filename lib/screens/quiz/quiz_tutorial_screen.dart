import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/settings_manager.dart';
import 'quiz_game_screen.dart';

// ---------------------------------------------------------------------------
// QuizTutorialScreen — Tutoriel + compte à rebours avant la partie
// ---------------------------------------------------------------------------
class QuizTutorialScreen extends StatefulWidget {
  final String gameMode;
  final Function(int score, int maxScore)? onSoloGameFinished;

  const QuizTutorialScreen({
    super.key,
    required this.gameMode,
    this.onSoloGameFinished,
  });

  @override
  State<QuizTutorialScreen> createState() => _QuizTutorialScreenState();
}

class _QuizTutorialScreenState extends State<QuizTutorialScreen>
    with TickerProviderStateMixin {

  final PageController _pageController = PageController();
  int  _currentPage   = 0;
  bool _showCountdown = false;
  int  _countdownVal  = 3;
  Timer? _countdownTimer;
  late final AnimationController _countdownAnim;

  static const List<Map<String, dynamic>> _slides = [
    {
      'icon':    '⚡',
      'color':   Color(0xFFD4AF37),
      'title':   'QUIZ INVISIBLE',
      'tag':     'Mémoire Flash',
      'rule':    'Une scène s\'affiche 3 secondes.\nMémorise TOUT — les détails comptent !',
      'example': 'Ex : "De quelle couleur était le chapeau ?"',
      'tip':     '💡 Concentre-toi sur les couleurs et les objets.',
    },
    {
      'icon':    '⌨️',
      'color':   Color(0xFF4FC3F7),
      'title':   'MOT FANTÔME',
      'tag':     'Saisie sous pression',
      'rule':    'Une définition simple s\'affiche.\nTape le bon mot... si le clavier te laisse faire !',
      'example': 'Ex : "Animal qui fait MIAOU" → tape CHAT',
      'tip':     '💡 Le clavier se mélange toutes les 5s — sois rapide !',
    },
    {
      'icon':    '🪞',
      'color':   Color(0xFF81C784),
      'title':   'QUIZ MIROIR',
      'tag':     'Inversion Cognitive',
      'rule':    'La question est affichée À L\'ENVERS.\nLis-la et réponds le plus vite possible.',
      'example': 'Plus tu réponds vite → plus tu gagnes de points',
      'tip':     '💡 Répondre en < 5s = 100 pts. Attendre = moins de points.',
    },
    {
      'icon':    '⏱',
      'color':   Color(0xFFFFB74D),
      'title':   'ENCHÈRE INVERSÉE',
      'tag':     'Prise de risque',
      'rule':    'Question difficile → des indices apparaissent.\nRéponds vite pour garder le max de points !',
      'example': 'Répondre sans indice = 100 pts\nAvec 2 indices = 20 pts',
      'tip':     '💡 Ose répondre tôt — même si tu n\'es pas sûr.',
    },
    {
      'icon':    '🔍',
      'color':   Color(0xFFCE93D8),
      'title':   'INFILTRATION',
      'tag':     'Indices & Buzz',
      'rule':    'Des indices se dévoilent un à un.\nAppuie sur BUZZ quand tu penses savoir !',
      'example': 'Buzz tôt = 100 pts\nBuzz tard = 20 pts\n3 tentatives pour trouver après le buzz',
      'tip':     '💡 Attendre trop = 0 pt pour tout le monde !',
    },
  ];

  @override
  void initState() {
    super.initState();
    _countdownAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _countdownTimer?.cancel();
    _countdownAnim.dispose();
    super.dispose();
  }

  void _nextPage() {
    settingsManager.playClick();
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _startCountdown();
    }
  }

  void _skipTutorial() {
    settingsManager.playClick();
    _startCountdown();
  }

  void _startCountdown() {
    setState(() { _showCountdown = true; _countdownVal = 3; });
    _animateCountdownNumber();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _countdownVal--);

      if (_countdownVal > 0) {
        _animateCountdownNumber();
      } else {
        settingsManager.playCountdownGo();
        _animateCountdownNumber();
        t.cancel();

        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          settingsManager.stopMusic();
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
                  QuizGameScreen(
                    gameMode: widget.gameMode,
                    onSoloGameFinished: widget.onSoloGameFinished,
                  ),
              transitionsBuilder: (_, anim, __, child) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end:   Offset.zero,
                ).animate(CurvedAnimation(
                  parent: anim,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        });
      }
    });
  }

  void _animateCountdownNumber() {
    _countdownAnim.reset();
    _countdownAnim.forward();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF001A33);

    return Scaffold(
      backgroundColor: primaryBlue,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end:   Alignment.bottomCenter,
                colors: [Color(0xFF002147), primaryBlue],
              ),
            ),
          ),
          _showCountdown ? _buildCountdown() : _buildTutorial(),
        ],
      ),
    );
  }

  Widget _buildTutorial() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildTutorialHeader(),
          const SizedBox(height: 8),
          _buildPageIndicators(),
          const SizedBox(height: 16),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (ctx, i) => _buildSlide(ctx, _slides[i]),
            ),
          ),
          _buildNextButton(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTutorialHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('COMMENT JOUER',
              style: TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 2)),
          GestureDetector(
            onTap: _skipTutorial,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: const Text('PASSER →',
                  style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length, (i) {
        final bool  active = i == _currentPage;
        final Color color  = _slides[i]['color'] as Color;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8, height: 8,
          decoration: BoxDecoration(
            color: active ? color : Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildSlide(BuildContext context, Map<String, dynamic> data) {
    final Color accent = data['color'] as Color;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data['icon'] as String,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height < 650 ? 52 : 68,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(0.92, 0.92), end: const Offset(1.08, 1.08),
              duration: 1800.ms, curve: Curves.easeInOut),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withValues(alpha: 0.5)),
            ),
            child: Text(data['tag'] as String,
                style: TextStyle(color: accent, fontSize: 12, letterSpacing: 1.5)),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 8),
          Text(data['title'] as String,
              style: TextStyle(color: accent, fontSize: 24, letterSpacing: 2))
              .animate().fadeIn(delay: 150.ms).slideY(begin: -0.1),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF002147),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withValues(alpha: 0.3)),
            ),
            child: Text(data['rule'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5)),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 10),
          Text(data['example'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12, height: 1.5, fontStyle: FontStyle.italic))
              .animate().fadeIn(delay: 280.ms),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent.withValues(alpha: 0.25)),
            ),
            child: Text(data['tip'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(color: accent, fontSize: 12)),
          ).animate().fadeIn(delay: 350.ms),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    final bool   isLast   = _currentPage == _slides.length - 1;
    final Color  accent   = _slides[_currentPage]['color'] as Color;
    final String label    = isLast ? '🚀  JE SUIS PRÊT !' : 'SUIVANT →';
    final Color  btnColor = isLast ? const Color(0xFFD4AF37) : accent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GestureDetector(
        onTap: _nextPage,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: btnColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: btnColor.withValues(alpha: 0.4),
                blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Text(label, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2)),
        ),
      )
          .animate(onPlay: (c) => isLast ? c.repeat(reverse: true) : null)
          .shimmer(delay: 1000.ms, duration: 1200.ms, color: Colors.white24),
    );
  }

  Widget _buildCountdown() {
    final bool   isGo  = _countdownVal <= 0;
    final String label = isGo ? 'GO !' : '$_countdownVal';
    final Color  color = isGo ? Colors.greenAccent : const Color(0xFFD4AF37);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('PRÉPARE-TOI...',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 16, letterSpacing: 3)),
          const SizedBox(height: 40),
          AnimatedBuilder(
            animation: _countdownAnim,
            builder: (_, __) {
              final double scale =
              Curves.elasticOut.transform(_countdownAnim.value);
              return Transform.scale(
                scale: 0.4 + scale * 0.8,
                child: Text(
                  label,
                  style: TextStyle(
                    color: color, fontSize: 120,
                    shadows: [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 40)],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: isGo ? 1.0 : (3 - _countdownVal) / 3,
                minHeight: 6,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}