import 'package:fantasy_adventurer_slot/config/slot_game_config.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class SlotGame extends FlameGame with HasTappables, HasCollisionDetection {
  /// 相機場景大小
  final Vector2 cameraFixedViewPort = Vector2(900.0, 1334.0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // 設定遊戲相機
    _setupCamera();

    // 設定遊戲場景
    _setupScenes();
  }

  /// 設定遊戲相機
  void _setupCamera() {
    // 偵錯螢幕大小、遊戲相機場景大小
    if (SlotGameConfig.isDebugMode) {
      final double screenWidth = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width;
      final double screenHeight = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height;
      print("螢幕大小 screenWidth: $screenWidth, screenHeight: $screenHeight");
      print("相機場景大小 cameraFixedViewPortWidth: ${SlotGameConfig.cameraFixedViewPort.x}, cameraFixedViewPortHeight: ${SlotGameConfig.cameraFixedViewPort.y}");
    }

    // 設定遊戲相機場景大小
    camera.viewport = FixedResolutionViewport(SlotGameConfig.cameraFixedViewPort);
  }

  /// 設定遊戲場景
  void _setupScenes() {

  }
}