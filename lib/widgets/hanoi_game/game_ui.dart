import 'package:flutter/material.dart';
import '../../services/hanoi_game/hanoi_flame_game.dart';

class GameUI extends StatelessWidget {
  final HanoiFlameGame game;
  const GameUI({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                _buildStat("COUPS", game.moves),
                _buildStat("TEMPS", game.seconds, isTime: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, ValueNotifier<int> notifier, {bool isTime = false}) {
    return ValueListenableBuilder<int>(
      valueListenable: notifier,
      builder: (context, val, _) {
        String display = isTime 
            ? "${val ~/ 60}:${(val % 60).toString().padLeft(2, '0')}" 
            : val.toString();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
              Text(display, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
}
