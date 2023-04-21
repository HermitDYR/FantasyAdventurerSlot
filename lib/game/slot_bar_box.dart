import 'dart:math';
import 'package:fantasy_adventurer_slot/abstract/gear.dart';
import 'package:fantasy_adventurer_slot/config/slot_game_config.dart';
import 'package:fantasy_adventurer_slot/game/slot_game.dart';
import 'package:fantasy_adventurer_slot/game/slot_item_box.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SlotBarBox extends PositionComponent with Gear, HasGameRef<SlotGame> {

  /// 索引
  int index;

  /// 老虎機槽條物件數量
  int itemCount;

  /// 生成位置
  Vector2? _generatePosition;

  /// 停留位置
  Vector2? stayPosition;

  /// 是否停留
  bool isStay;

  /// 進入停留狀態
  Function(int index)? onStay;

  /// 是否移動
  bool _isMove = true;

  /// 是否移動
  bool get isMove => _isMove;

  /// 是否開始移動
  Function(int index)? onMove;

  /// 移除位置
  Vector2? removePosition;

  /// 是否進入移除位置
  Function(int index)? onRemovePosition;

  /// 預設速度
  double speed = 2.5;

  /// 老虎機槽條物件內容編號陣列
  List<int>? itemIdList;

  /// 老虎機槽條物件中獎索引陣列
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
    this.onMove,
    this.itemIdList,
    this.itemLotteryIndexList,
    this.onRemovePosition,
    // this.onCollisionWithBottomReplyBox,
  }) : super(position: position, size: size, anchor: Anchor.center);

  @override
  Future<void>? onLoad() async {
    if (SlotGameConfig.isDebugMode) {
      // TODO: 測試模式 (這個會降低效能，非必要不要開著)
      add(RectangleHitbox()..debugMode = SlotGameConfig.isDebugMode);
    }

    _generatePosition = position;

    // 設定錨點陣列
    _setupAnchorPoints();

    // 設置老虎機槽條物件組
    _setupSlotItems();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 如果停留狀態啟用，則停止在停留點
    if (isStay) {
      if (stayPosition != null && position.y > stayPosition!.y) {
        position = stayPosition!;
        // print("SlotBarBox $index >> update to isStay~~~");
        setIsMove(!isStay);

        // 展示彈跳效果
        showBounce();

        if (onStay != null) {
          // 進入停留狀態
          onStay!(index);
        }
      }
    }

    if (isMove) {
      // 持續向下
      var x = position.x;
      var y = position.y + (dt * size.y * speed);
      position = Vector2(x, y);
    }

    if (position.y >= removePosition!.y) {
      // 刪除
      removeFromParent();
      if (onRemovePosition != null) {
        onRemovePosition!(index);
      }
    }
  }

  /// 設置是否移動
  void setIsMove(bool move) {
    print("SlotBarBox >> setIsMove: $move");
    _isMove = move;
    if (_isMove) {
      print("!!!!!!!!");
      if (onMove != null) {
        print("!!!!!!!!~~~~");
        // 進入移動狀態
        onMove!(index);
      }
    }
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
        add(getDebugAnchorRect(
          size: Vector2(itemWidth, itemWidth),
          position: point,
          pointColor: (itemIdList != null) ? Colors.white : Colors.black,
          contentColor: (itemIdList != null) ? Colors.white.withAlpha(150) : Colors.black.withAlpha(150),
        ));
      }
    }
  }


  /// 設置老虎機槽條物件組
  void _setupSlotItems() {
    if (gameRef.slotMachine == null) return;

    for (int i = 0; i < itemCount; i++) {
      // 判斷是否為中獎物件
      bool isLottery = false;
      if (itemLotteryIndexList != null && itemLotteryIndexList!.length > 0) {
        final find = itemLotteryIndexList!.where((element) {
          return (element == i);
        });
        isLottery = (find.isNotEmpty);
      }

      // 裝載物件
      itemIdList ??= [];
      if (i < (itemIdList!.length)) {
        final itemId = itemIdList![i];
        final targetSlotItem = SlotItemBox(
          barIndex: index,
          index: i,
          id: itemId,
          // sprite: (gameRef.slotMachine!.rollItemSprites.length > 0) ? gameRef.slotMachine!.rollItemSprites[itemId] : null,
          size: Vector2(size.x * 1, size.x * 1),
          position: _anchorPoints![i],
          isTarget: true,
          isLottery: isLottery,
        );
        add(targetSlotItem);
      } else {
        final itemId = Random().nextInt(gameRef.slotMachine!.rollItemSpritesCount);
        final randomSlotItem = SlotItemBox(
          barIndex: index,
          index: i,
          id: itemId,
          // sprite: (gameRef.slotMachine!.rollItemSprites.isNotEmpty) ? gameRef.slotMachine!.rollItemSprites[itemId] : null,
          size: Vector2(size.x * 1, size.x * 1),
          position: _anchorPoints![i],
          isTarget: false,
          isLottery: isLottery,
        );
        add(randomSlotItem);
      }
    }
  }

  /// 取得老虎機槽條內容物件
  SlotItemBox? getSlotItem({required int index}) {
    for (Component component in children.toList()) {
      if (component is SlotItemBox) {
        SlotItemBox slotItem = component;
        if (slotItem.index == index) {
          return component;
        }
      }
    }
    return null;
  }

  /// 展示彈跳效果
  void showBounce() {
    for (int i = 0; i < itemCount; i++) {
      SlotItemBox? slotItem = getSlotItem(index: i);
      if (slotItem != null) {
        // 靜止後的回彈
        slotItem.effectBounce();
      }
    }
  }

  /// 展示中獎效果
  void showLottery() {
    for (int i = 0; i < itemCount; i++) {
      SlotItemBox? slotItem = getSlotItem(index: i);
      if (slotItem != null) {
        if (slotItem.isLottery) {
          // 靜止後回彈 >> 縮放
          slotItem.effectBounceAfterScale();
        }
      }
    }
  }

}