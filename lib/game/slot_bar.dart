import 'package:fantasy_adventurer_slot/abstract/gear.dart';
import 'package:fantasy_adventurer_slot/config/slot_game_config.dart';
import 'package:fantasy_adventurer_slot/game/slot_bar_box.dart';
import 'package:fantasy_adventurer_slot/game/slot_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class SlotBar extends PositionComponent with Gear, HasGameRef<SlotGame> {
  /// 索引
  int index = -1;

  /// 老虎機槽條物件數量
  int itemCount;

  /// 老虎機槽條物件內容編號陣列
  List<int>? _itemIdList;

  /// 老虎機槽條物件中獎索引陣列
  List<int>? _itemLotteryIndexList;

  /// 老虎機槽條物件箱
  SlotBarBox? targetSlotBarBox;

  /// 老虎機槽條物件箱進入停留狀態
  Function(int index)? onStayFromSlotBarBox;

  /// 老虎機槽條物件箱累計新增數量
  int slotBarBoxAddedCount = 0;

  /// 上方外部錨點
  Vector2 _topOutsideAnchorPoint = Vector2.zero();

  /// 內部錨點
  Vector2 _insideAnchorPoint = Vector2.zero();

  /// 下方內部錨點
  Vector2 _bottomOutsideAnchorPoint = Vector2.zero();

  /// 假的老虎機槽條物件箱
  SpriteAnimationComponent? fakeSlotBarBox;

  /// 設置假的老虎機槽條物件箱動畫精靈
  SpriteAnimation? fakeSlotBarBoxSpriteAnimation;

  /// 老虎機槽條
  SlotBar({
    required this.index,
    required this.itemCount,
    required Vector2? position,
    required Vector2? size,
    this.onStayFromSlotBarBox,
  }) : super(position: position, size: size);

  @override
  Future<void>? onLoad() async {
    if (SlotGameConfig.isDebugMode) {
      // TODO: 測試模式 (這個會降低效能，非必要不要開著)
      add(RectangleHitbox()..debugMode = SlotGameConfig.isDebugMode);
    }

    // 設定錨點陣列
    _setupAnchorPoints();

    // 設置假的老虎機槽條物件箱動畫精靈
    // await _setupFakeSlotBarBoxSpriteAnimation();

    // 將老虎機槽條物件箱子新增到內部錨點上
    addSlotBarBoxAtInside();

    return super.onLoad();
  }

  /// 測試錨點標示
  CircleComponent _getDebugAnchorPoint({required Vector2 position, required Color color}) {
    return CircleComponent(
        radius: 20,
        position: position,
        anchor: Anchor.center,
        paint: Paint()
          ..color = color
          ..style = PaintingStyle.fill);
  }

  /// 設定錨點陣列
  void _setupAnchorPoints() {
    _topOutsideAnchorPoint = Vector2(size.x / 2, size.y / 2 - size.y);
    _insideAnchorPoint = Vector2(size.x / 2, size.y / 2);
    _bottomOutsideAnchorPoint = Vector2(size.x / 2, size.y / 2 + size.y);

    if (SlotGameConfig.isDebugMode) {
      add(_getDebugAnchorPoint(position: _topOutsideAnchorPoint, color: Colors.green));
      add(_getDebugAnchorPoint(position: _insideAnchorPoint, color: Colors.blue));
      add(_getDebugAnchorPoint(position: _bottomOutsideAnchorPoint, color: Colors.red));
    }
  }

  /// 將老虎機槽條物件箱子新增到內部錨點上
  void addSlotBarBoxAtInside() {
    if (gameRef.slotMachine == null) return;

    // 取得遊戲模式開獎盤面(用於運作程式邏輯)
    List<List<int>> lottery = SlotGameConfig.getGameModeLottery(designModeAllLotteryList: gameRef.slotMachine!.designModeAllLotteryList, index: 0);
    targetSlotBarBox = null;
    targetSlotBarBox = SlotBarBox(
      index: index,
      itemCount: itemCount,
      position: _insideAnchorPoint,
      size: size,
      stayPosition: _insideAnchorPoint,
      removePosition: _bottomOutsideAnchorPoint,
      speed: gameRef.slotMachine!.slotBarBoxMoveSpeed.toDouble(),
      isStay: true,
      onStay: onStayFromSlotBarBox,
      itemIdList: (lottery.length > 0) ? lottery[index] : [],
      itemLotteryIndexList: _itemLotteryIndexList,
      onRemovePosition: _onRemovePosition,
      // onCollisionWithBottomReplyBox: _onCollisionWithBottomReplyBoxFromSlotBarBox,
    );
    add(targetSlotBarBox!);
    slotBarBoxAddedCount++;
    _itemIdList = null;
    _itemLotteryIndexList = null;
  }

  /// 設置假的老虎機槽條物件箱動畫精靈
  Future<void> _setupFakeSlotBarBoxSpriteAnimation() async {
    // CUP效能限制程度
    // - PC Flutter Web >= Android Mobile Flutter App & iOS Mobile Flutter App > Mobile Flutter Web(效能吃緊)
    // 如果要運作在Mobile的Web瀏覽器上要特別注意效能限制的問題(PC Flutter Web、Android Mobile Flutter App & iOS Mobile Flutter App除外)
    // 1. SpriteSheet張數不要太多(大約8楨~32楨以內)
    // 2. SpriteSheet切割單圖不要太大(像素在適當的螢幕大小下能清楚顯示即可)
    // 3. SpriteSheet總大小在1.5MB以內(能越小當然越好)
    const stepTime = 0.025;
    final textureSize = Vector2(150, 450);
    const frameCount = 14;
    fakeSlotBarBoxSpriteAnimation = await gameRef.loadSpriteAnimation(
      'game/fake_slot_bar_box_spritesheet_$index.png',
      SpriteAnimationData.sequenced(
        amount: frameCount,
        stepTime: stepTime,
        textureSize: textureSize,
      ),
    );
    return;
  }

  /// 設置假的老虎機槽條物件箱
  void addFakeSlotBarBox() {
    // print("SlotBar >> addFakeSlotBarBox~~~");
    if (fakeSlotBarBoxSpriteAnimation != null && fakeSlotBarBox == null) {
      print("SlotBar >> addFakeSlotBarBox~~~ Do!!!");
      // TODO: https://stackoverflow.com/questions/71183657/why-spriteanimation-oncomplete-do-not-trigger-after-restarting-the-game-in-flutt
      fakeSlotBarBoxSpriteAnimation!.reset();

      fakeSlotBarBox = SpriteAnimationComponent(
        animation: fakeSlotBarBoxSpriteAnimation,
        size: size,
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
        removeOnFinish: true,
      );
      add(fakeSlotBarBox!);
    }
  }

  /// 待補
  void _onRemovePosition(int index) {
    if (targetSlotBarBox != null) {
      targetSlotBarBox = null;
    }
  }
}