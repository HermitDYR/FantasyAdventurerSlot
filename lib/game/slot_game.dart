import 'package:fantasy_adventurer_slot/config/slot_game_config.dart';
import 'package:fantasy_adventurer_slot/game/slot_game_spin_button.dart';
import 'package:fantasy_adventurer_slot/game/slot_machine.dart';
import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class SlotGame extends FlameGame with HasTappables, HasCollisionDetection {

  SlotMachine? slotMachine;

  SlotGameSpinButton? slotGameSpinButton;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 設定遊戲相機
    _setupCamera();

    // 設定老虎機
    _setupSlotMachine();

    // 設定老虎機滾動按鈕
    _setupSlotSpinButton();

  }

  /// 設定老虎機滾動按鈕
  void _setupSlotSpinButton() {
    final size = Vector2(150.0, 150.0);
    final position = Vector2(SlotGameConfig.cameraFixedViewPort.x/2, SlotGameConfig.cameraFixedViewPort.y - size.y * 1.2);
    slotGameSpinButton = SlotGameSpinButton(position: position, size: size, onTap: _onTapSpinButton)..setIsLock(false);
    slotGameSpinButton!.setIsLock(false);
    add(slotGameSpinButton!);
  }

  /// 老虎機滾動按鈕點擊響應事件
  void _onTapSpinButton(SlotGameSpinButton button, bool isSpin) {
    button.setIsLock(false);
    print("_onTapSpinButton isSpin: $isSpin");
    if (slotMachine == null) return;
    if (!isSpin) {
      // 如果按鈕正在Spin狀態則老虎機停止
      slotMachine!.stop();
    } else {
      // 如果按鈕正在Stop狀態則老虎機轉動
      slotMachine!.spin();
    }
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

  /// 設定老虎機
  void _setupSlotMachine() {
    var barWidth = (SlotGameConfig.cameraFixedViewPort.x * 0.7) / SlotGameConfig.multiplication.x;
    var position = Vector2(SlotGameConfig.cameraFixedViewPort.x / 2, SlotGameConfig.cameraFixedViewPort.y / 2.2);
    var size = Vector2(barWidth * SlotGameConfig.multiplication.x, barWidth * SlotGameConfig.multiplication.y);
    slotMachine = SlotMachine(multiplication: SlotGameConfig.multiplication, position: position, size: size);
    add(slotMachine!);
  }
}