import 'dart:math';
import 'package:fantasy_adventurer_slot/abstract/gear.dart';
import 'package:fantasy_adventurer_slot/config/slot_game_config.dart';
import 'package:fantasy_adventurer_slot/game/slot_game.dart';
import 'package:fantasy_adventurer_slot/game/slot_item.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SlotBarBox extends PositionComponent with Gear, HasGameRef<SlotGame> {

  /// 索引
  int index;

  /// 老虎機滾輪物件數量
  int itemCount;

  /// 生成位置
  Vector2? _generatePosition;

  /// 停留位置
  Vector2? stayPosition;

  /// 是否停留
  bool isStay;

  /// 進入停留狀態
  Function(int index)? onStay;

  /// 移除位置
  Vector2? removePosition;

  /// 是否進入移除位置
  Function(int index)? onRemovePosition;

  /// 預設速度
  double speed = 2.5;

  /// 老虎機滾輪物件內容編號陣列
  List<int>? itemIdList;

  /// 老虎機滾輪物件中獎索引陣列
  List<int>? itemLotteryIndexList;

  /// 錨點陣列
  List<Vector2>? _anchorPoints;

  /// 老虎機槽條物件箱
  SlotBarBox({
    required this.index,
    required this.itemCount,
    required Vector2? position,
    required Vector2? size,
    required this.stayPosition,
    required this.removePosition,
    required this.speed,
    this.isStay = false,
    this.onStay,
    this.itemIdList,
    this.itemLotteryIndexList,
    this.onRemovePosition,
    // this.onCollisionWithBottomReplyBox,
  }) : super(position: position, size: size, anchor: Anchor.center);

  @override
  Future<void>? onLoad() async {
    // TODO: 測試模式 (這個會降低效能，非必要不要開著)
    add(RectangleHitbox()..debugMode = SlotGameConfig.isDebugMode);

    _generatePosition = position;

    // // 設置碰撞檢測
    // _setupHitBox();

    // 設定錨點陣列
    _setupAnchorPoints();

    // 設置老虎機滾輪物件組
    _setupSlotItems();

    return super.onLoad();
  }

  /// 測試錨點標示物件
  RectangleComponent _getDebugAnchorItem({
    required Vector2 size,
    required Vector2 position,
    required Color pointColor,
    required Color contentColor,
  }) {
    return RectangleComponent(
        size: size,
        position: position,
        anchor: Anchor.center,
        children: [
          CircleComponent(
              radius: 15,
              position: Vector2(size.x / 2, size.y / 2),
              anchor: Anchor.center,
              paint: Paint()
                ..color = pointColor
                ..style = PaintingStyle.fill)
        ],
        paint: Paint()
          ..color = contentColor
          ..style = PaintingStyle.fill);
  }

  /// 設定錨點陣列
  void _setupAnchorPoints() {
    _anchorPoints ??= [];
    var itemWidth = size.x;
    var itemHeight = size.y / itemCount;
    var startPoint = Vector2(itemWidth / 2, itemHeight / 2);
    for (int i = 0; i < itemCount; i++) {
      var point = Vector2(startPoint.x, startPoint.y + (i * itemHeight));
      _anchorPoints!.add(point);
      if (SlotGameConfig.isDebugMode) {
        add(_getDebugAnchorItem(
          size: Vector2(itemWidth, itemWidth),
          position: point,
          pointColor: (itemIdList != null) ? Colors.white : Colors.black,
          contentColor: (itemIdList != null) ? Colors.white.withAlpha(150) : Colors.black.withAlpha(150),
        ));
      }
    }
  }


  /// 設置老虎機滾輪物件組
  void _setupSlotItems() {
    for (int i = 0; i < itemCount; i++) {
      // 判斷是否為中獎物件
      bool isLottery = false;
      if (itemLotteryIndexList != null) {
        final find = itemLotteryIndexList!.where((element) {
          return (element == i);
        });
        isLottery = (find.isNotEmpty);
      }

      // 裝載物件
      itemIdList ??= [];
      if (i < (itemIdList!.length)) {
        final itemId = itemIdList![i];
        final targetSlotItem = SlotItem(
          index: i,
          id: itemId,
          sprite: gameRef.slotMachine.rollItemSprites[itemId],
          size: Vector2(size.x * 1, size.x * 1),
          position: _anchorPoints![i],
          isTarget: true,
          isLottery: isLottery,
        );
        add(targetSlotItem);
      } else {
        final itemId = Random().nextInt(gameRef.slotMachine.rollItemSpritesCount);
        final randomSlotItem = SlotItem(
          index: i,
          id: itemId,
          sprite: gameRef.slotMachine.rollItemSprites[itemId],
          size: Vector2(size.x * 1, size.x * 1),
          position: _anchorPoints![i],
          isTarget: false,
          isLottery: isLottery,
        );
        add(randomSlotItem);
      }
    }
  }

  /// 取得老虎機滾輪
  SlotItem? getSlotItem({required int index}) {
    for (Component component in children.toList()) {
      if (component is SlotItem) {
        SlotItem slotItem = component;
        if (slotItem.index == index) {
          return component;
        }
      }
    }
    return null;
  }
}