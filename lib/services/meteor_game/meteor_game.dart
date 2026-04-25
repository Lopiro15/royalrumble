import 'dart:async' as async;
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import '../../models/meteor_game/ship.dart';
import '../../models/meteor_game/meteor.dart';
import '../../models/meteor_game/bullet.dart';
import '../settings_manager.dart';

class MeteorGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  late Ship ship;
  double spawnTimer = 0;
  final Random random = Random();

  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  final ValueNotifier<int> ammoNotifier = ValueNotifier(0);
  bool isGameOver = false;

  final Function(int score, int maxScore)? onSoloGameFinished;
  bool _hasNotifiedSolo = false;

  // AJOUT : callback pour le mode Versus
  void Function(int score, bool isDead)? onVersusFinished;

  static const int maxPossibleScore = 1000;

  MeteorGame({this.onSoloGameFinished});

  @override
  Future<void> onLoad() async {
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF000814),
      priority: -1,
    ));

    ship = Ship();
    add(ship);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    spawnTimer += dt;
    if (spawnTimer > 1.0) {
      add(Meteor());
      spawnTimer = 0;
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) return;
    if (ammoNotifier.value > 0) {
      ammoNotifier.value--;
      add(Bullet(ship.position.clone()));
      settingsManager.playClick();
    }
  }

  void createExplosion(Vector2 pos, Color color, {int count = 20, double radius = 3.0}) {
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: count,
          lifespan: 0.8,
          generator: (i) {
            final speed = Vector2(
              (random.nextDouble() - 0.5) * 600,
              (random.nextDouble() - 0.5) * 600,
            );
            return AcceleratedParticle(
              speed: speed,
              acceleration: speed * -0.5,
              position: pos.clone(),
              child: CircleParticle(
                radius: 1.0 + random.nextDouble() * radius,
                paint: Paint()..color = color,
              ),
            );
          },
        ),
      ),
    );
  }

  void gameOver() {
    if (isGameOver) return;
    isGameOver = true;

    createExplosion(ship.position, const Color(0xFFD4AF37), count: 80, radius: 6.0);
    createExplosion(ship.position, Colors.orangeAccent, count: 40, radius: 4.0);
    createExplosion(ship.position, Colors.white, count: 20, radius: 2.0);

    ship.removeFromParent();

    _notifySoloGameFinished();

    // AJOUT : notifier le mode Versus
    onVersusFinished?.call(scoreNotifier.value, true);

    async.Timer(const Duration(milliseconds: 1000), () {
      pauseEngine();
      overlays.add('GameOver');
    });

    settingsManager.stopMusic();
  }

  void _notifySoloGameFinished() {
    if (onSoloGameFinished != null && !_hasNotifiedSolo) {
      _hasNotifiedSolo = true;
      onSoloGameFinished!(scoreNotifier.value, maxPossibleScore);
    }
  }

  void restart() {
    isGameOver = false;
    _hasNotifiedSolo = false;
    scoreNotifier.value = 0;
    ammoNotifier.value = 0;
    spawnTimer = 0;
    children.whereType<Meteor>().forEach((m) => m.removeFromParent());
    children.whereType<Bullet>().forEach((b) => b.removeFromParent());

    ship = Ship();
    add(ship);

    overlays.remove('GameOver');
    resumeEngine();
    settingsManager.startMusic();
  }
}