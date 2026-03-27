import 'dart:async' as async;
import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../services/settings_manager.dart';

class MeteorGameScreen extends StatelessWidget {
  const MeteorGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = MeteorGame();
    return Scaffold(
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'GameOver': (context, MeteorGame g) => _GameOverOverlay(game: g),
          'UI': (context, MeteorGame g) => _GameUI(game: g),
        },
        initialActiveOverlays: const ['UI'],
      ),
    );
  }
}

class MeteorGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  late Ship ship;
  double spawnTimer = 0;
  final Random random = Random();
  
  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  final ValueNotifier<int> ammoNotifier = ValueNotifier(0);
  bool isGameOver = false;

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
    
    // 1. Explosion spectaculaire
    createExplosion(ship.position, const Color(0xFFD4AF37), count: 80, radius: 6.0);
    createExplosion(ship.position, Colors.orangeAccent, count: 40, radius: 4.0);
    createExplosion(ship.position, Colors.white, count: 20, radius: 2.0);
    
    // 2. Faire disparaître le vaisseau
    ship.removeFromParent();
    
    // 3. Attendre que l'explosion se produise avant de figer le jeu
    async.Timer(const Duration(milliseconds: 1000), () {
      pauseEngine();
      overlays.add('GameOver');
    });
    
    settingsManager.stopMusic();
  }

  void restart() {
    isGameOver = false;
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

class Ship extends PositionComponent with HasGameRef<MeteorGame>, CollisionCallbacks {
  double currentVelocityX = 0;
  double rawTiltX = 0;
  async.StreamSubscription? _subscription;

  Ship() : super(size: Vector2(50, 50), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    _subscription = accelerometerEvents.listen((event) {
      rawTiltX = -event.x; 
    });
    position = Vector2(gameRef.size.x / 2, gameRef.size.y - 100);
  }

  @override
  void update(double dt) {
    super.update(dt);

    double targetSpeed = 0;
    if (rawTiltX.abs() > 1.2) {
      targetSpeed = rawTiltX * 180;
    }

    double lerpFactor = targetSpeed == 0 ? 0.1 : 0.05;
    currentVelocityX = currentVelocityX + (targetSpeed - currentVelocityX) * lerpFactor;

    position.x += currentVelocityX * dt;
    position.x = position.x.clamp(size.x / 2, gameRef.size.x - size.x / 2);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFD4AF37);
    final path = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(0, size.y)
      ..lineTo(size.x, size.y)
      ..close();
    
    canvas.drawShadow(path, Colors.orangeAccent, 5, true);
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(size.x / 2, size.y * 0.6), 8, Paint()..color = Colors.black45);
  }

  @override
  void onRemove() {
    _subscription?.cancel();
    super.onRemove();
  }
}

class Meteor extends PositionComponent with HasGameRef<MeteorGame>, CollisionCallbacks {
  late double speed;
  late int maxLife;
  late int currentLife;
  late double radius;

  Meteor() : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final rand = Random();
    double typeRand = rand.nextDouble();

    if (typeRand > 0.85) {
      radius = 40;
      maxLife = 6;
      speed = 100 + rand.nextDouble() * 50;
    } else if (typeRand > 0.5) {
      radius = 25;
      maxLife = 3;
      speed = 150 + rand.nextDouble() * 80;
    } else {
      radius = 15;
      maxLife = 1;
      speed = 200 + rand.nextDouble() * 100;
    }

    currentLife = maxLife;
    size = Vector2(radius * 2, radius * 2);
    position = Vector2(rand.nextDouble() * gameRef.size.x, -radius);
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;

    if (position.y > gameRef.size.y + radius) {
      int reward = maxLife == 6 ? 4 : (maxLife == 3 ? 2 : 1);
      gameRef.scoreNotifier.value += reward;
      gameRef.ammoNotifier.value += reward;
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    double healthPercent = currentLife / maxLife;
    final paint = Paint()..color = Color.lerp(Colors.redAccent, Colors.grey[600]!, healthPercent)!;
    canvas.drawCircle(Offset(radius, radius), radius, paint);
    canvas.drawCircle(Offset(radius * 0.5, radius * 0.5), radius * 0.2, Paint()..color = Colors.black26);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Ship) {
      gameRef.gameOver();
    }
  }

  void hit() {
    currentLife--;
    gameRef.createExplosion(position, Colors.orangeAccent, count: 5, radius: 2.0);
    
    if (currentLife <= 0) {
      int reward = maxLife == 6 ? 12 : (maxLife == 3 ? 6 : 2);
      gameRef.scoreNotifier.value += reward;
      gameRef.createExplosion(position, Colors.grey, count: 25, radius: 4.0);
      removeFromParent();
    }
  }
}

class Bullet extends PositionComponent with HasGameRef<MeteorGame>, CollisionCallbacks {
  Bullet(Vector2 pos) : super(position: pos, size: Vector2(8, 20), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= 700 * dt;
    if (position.y < -20) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(RRect.fromRectAndRadius(size.toRect(), const Radius.circular(4)), Paint()..color = Colors.cyanAccent);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Meteor) {
      other.hit();
      removeFromParent();
    }
  }
}

class _GameOverOverlay extends StatelessWidget {
  final MeteorGame game;
  const _GameOverOverlay({required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: const Color(0xFF001A33),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('VAISSEAU DÉTRUIT', style: TextStyle(color: Colors.redAccent, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ValueListenableBuilder<int>(
              valueListenable: game.scoreNotifier,
              builder: (context, score, _) => Text('SCORE FINAL : $score', style: const TextStyle(color: Colors.white, fontSize: 24)),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
              onPressed: game.restart,
              child: const Text('RÉESSAYER', style: TextStyle(color: Color(0xFF001A33))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('QUITTER', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameUI extends StatelessWidget {
  final MeteorGame game;
  const _GameUI({required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: game.scoreNotifier,
              builder: (context, score, _) => _buildStat('SCORE', score.toString(), Colors.orangeAccent),
            ),
            ValueListenableBuilder<int>(
              valueListenable: game.ammoNotifier,
              builder: (context, ammo, _) => _buildStat('MUNITIONS', ammo.toString(), Colors.cyanAccent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
