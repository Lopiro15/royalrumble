import 'dart:async' as async;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../services/labyrinth_game/labyrinth_game.dart';

class Ball extends PositionComponent with HasGameRef<LabyrinthGame>, CollisionCallbacks {
  double tiltX = 0;
  double tiltY = 0;
  double _velX = 0;
  double _velY = 0;

  // Variables pour la logique de "cliquet"
  double _maxTiltX = 0;
  double _maxTiltY = 0;

  async.StreamSubscription? _subscription;

  Ball({required Vector2 position}) : super(position: position, size: Vector2.all(22), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox(radius: 11));
    _subscription = accelerometerEvents.listen((event) {
      tiltX = -event.x;
      tiltY = event.y;
    });
  }

  @override
  void update(double dt) {
    if (gameRef.isWon) return;

    // 1. Paramètres de sensibilité et friction
    const double sensitivity = 130; // Sensibilité encore réduite pour un contrôle total
    const double friction = 0.7;    // Arrêt plus brusque pour la précision
    const double deadZone = 0.8;

    double effectiveTiltX = 0;
    double effectiveTiltY = 0;

    // 2. Logique de Cliquet pour l'axe X
    if (tiltX.abs() < 0.2) {
      _maxTiltX = 0; // Réinitialisation au passage par 0
    } else {
      if (tiltX > 0) { // Inclinaison à droite
        if (tiltX >= _maxTiltX) {
          _maxTiltX = tiltX;
          effectiveTiltX = tiltX;
        }
      } else { // Inclinaison à gauche
        if (tiltX <= _maxTiltX) {
          _maxTiltX = tiltX;
          effectiveTiltX = tiltX;
        }
      }
    }

    // 3. Logique de Cliquet pour l'axe Y
    if (tiltY.abs() < 0.2) {
      _maxTiltY = 0; // Réinitialisation au passage par 0
    } else {
      if (tiltY > 0) { // Inclinaison vers le bas
        if (tiltY >= _maxTiltY) {
          _maxTiltY = tiltY;
          effectiveTiltY = tiltY;
        }
      } else { // Inclinaison vers le haut
        if (tiltY <= _maxTiltY) {
          _maxTiltY = tiltY;
          effectiveTiltY = tiltY;
        }
      }
    }

    // 4. Calcul de la vitesse
    _velX = (_velX * friction) + (effectiveTiltX * sensitivity * dt);
    _velY = (_velY * friction) + (effectiveTiltY * sensitivity * dt);

    // 5. Déplacement préventif (Axe par Axe pour glisser sur les murs)
    double nextX = position.x + _velX;
    Rect nextRectX = Rect.fromCenter(
      center: Offset(nextX, position.y),
      width: size.x - 2,
      height: size.y - 2,
    );

    if (!gameRef.isCollidingWithWall(nextRectX)) {
      position.x = nextX;
    } else {
      _velX = 0;
      _maxTiltX = 0; // Reset du cliquet au choc
    }

    double nextY = position.y + _velY;
    Rect nextRectY = Rect.fromCenter(
      center: Offset(position.x, nextY),
      width: size.x - 2,
      height: size.y - 2,
    );

    if (!gameRef.isCollidingWithWall(nextRectY)) {
      position.y = nextY;
    } else {
      _velY = 0;
      _maxTiltY = 0; // Reset du cliquet au choc
    }

    // Limites écran
    position.x = position.x.clamp(size.x / 2, gameRef.size.x - size.x / 2);
    position.y = position.y.clamp(size.y / 2, gameRef.size.y - size.y / 2);

    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFD4AF37);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);
    canvas.drawCircle(Offset(size.x * 0.3, size.y * 0.3), size.x * 0.15, Paint()..color = Colors.white.withOpacity(0.6));
  }

  @override
  void onRemove() {
    _subscription?.cancel();
    super.onRemove();
  }
}

class Wall extends RectangleComponent {
  Wall({required Vector2 position, required Vector2 size})
      : super(
          position: position,
          size: size,
          paint: Paint()..color = const Color(0xFF002147),
        );
}

class ExitPortal extends CircleComponent with HasGameRef<LabyrinthGame>, CollisionCallbacks {
  ExitPortal({required Vector2 position})
      : super(
          position: position,
          radius: 25,
          anchor: Anchor.center,
          paint: Paint()..color = Colors.greenAccent.withOpacity(0.7),
        );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
    add(OpacityEffect.to(0.3, EffectController(duration: 1, reverseDuration: 1, infinite: true)));
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Ball) {
      gameRef.victory();
    }
  }
}
