import 'package:fantasy_adventurer_slot/config/target_device_info.dart';
import 'package:flame/game.dart';

/// 主遊戲設定
class SlotGameConfig {
  /// 使該類不可被實例化
  SlotGameConfig._();

  /// 是否為偵錯模式
  static bool isDebugMode = true;

  /// 遊戲相機場景大小
  /// - 在不同的設備尺寸中，自適應已定義的遊戲大小比例
  static Vector2 cameraFixedViewPort = Vector2(TargetDeviceInfo.pxWidth, TargetDeviceInfo.pxHeight);
}