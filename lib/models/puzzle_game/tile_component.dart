import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../../services/puzzle_game/puzzle_flame_game.dart';

class TileComponent extends SpriteComponent with HasGameRef<PuzzleFlameGame>, TapCallbacks {
  final int value;
  final int currentIndex;

  TileComponent({
    required this.value,
    required this.currentIndex,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    final image = await gameRef.images.load('logo.png');
    double unitW = image.width / 3;
    double unitH = image.height / 3;
    sprite = Sprite(
      image,
      srcPosition: Vector2((value % 3) * unitW, (value ~/ 3) * unitH),
      srcSize: Vector2(unitW, unitH),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    gameRef.tryMove(currentIndex);
  }
}
