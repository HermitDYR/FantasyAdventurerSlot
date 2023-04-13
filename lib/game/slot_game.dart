import 'package:flame/game.dart';

class SlotGame extends FlameGame with HasTappables, HasCollisionDetection {
  /// 相機場景大小
  final Vector2 cameraFixedViewPort = Vector2(900.0, 1334.0);
}