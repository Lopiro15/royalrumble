import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/settings_manager.dart';

class CountdownOverlay extends StatefulWidget {
  final VoidCallback onFinished;

  const CountdownOverlay({super.key, required this.onFinished});

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  int _count = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    settingsManager.stopMusic();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_count > 1) {
          _count--;
          settingsManager.playClick();
        } else if (_count == 1) {
          _count = 0; // Signifie "GO !"
          settingsManager.playGameStart();
        } else {
          _timer?.cancel();
          widget.onFinished();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        key: ValueKey(_count),
        child: Text(
          _count == 0 ? 'GO !' : '$_count',
          style: TextStyle(
            color: const Color(0xFFD4AF37),
            fontSize: _count == 0 ? 120 : 180,
            fontWeight: FontWeight.bold,
            fontFamily: 'Luckiest Guy',
            shadows: const [
              Shadow(blurRadius: 20, color: Colors.black, offset: Offset(5, 5)),
            ],
          ),
        )
            .animate()
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.2, 1.2),
              duration: 400.ms,
              curve: Curves.elasticOut,
            )
            .fadeOut(delay: 600.ms),
      ),
    );
  }
}
