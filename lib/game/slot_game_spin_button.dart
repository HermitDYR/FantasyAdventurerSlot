import 'dart:math' as math;
import 'package:fantasy_adventurer_slot/abstract/gear.dart';
import 'package:fantasy_adventurer_slot/config/slot_game_config.dart';
import 'package:fantasy_adventurer_slot/game/slot_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class SlotGameSpinButton extends PositionComponent with Gear, Tappable, HasGameRef<SlotGame> {

  /// 點擊
  Function(SlotGameSpinButton, bool)? onTap;

  /// 是否滾動
  bool _isSpin = false;
  bool get isSpin => _isSpin;

  /// 是否鎖定
  bool _isLock = true;
  bool get isLock => _isLock;

  /// 速度
  double? speed;

  /// 預設速度
  final _defaultSpeed = 10.0;

  /// 老虎機滾動按鈕
  SlotGameSpinButton({
    required Vector2? position,
    required Vector2? size,
    this.onTap,
    this.speed,
  }) : super(position: position, size: size, anchor: Anchor.center);

  @override
  Future<void>? onLoad() async {
    // TODO: implement onLoad
    // TODO: 測試模式 (這個會降低效能，非必要不要開著)
    add(RectangleHitbox()..debugMode = SlotGameConfig.isDebugMode);

    speed ??= _defaultSpeed;

    // 設置偵錯矩陣
    _setupDebugRect();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (speed == null) return;

    // 滾動狀態時旋轉按鈕
    if (isSpin) {
      angle += speed! * dt;
      angle %= 2 * math.pi;
    } else {
      angle = 0.0;
    }
  }

  @override
  bool onTapUp(TapUpInfo info) {
    if (isLock) return true;
    _checkTapUp();
    return true;
  }

  void _checkTapUp() {
    // 更新滾動狀態
    setIsSpin(!isSpin);
    if(isSpin) {
      runBegin(runTime);
    }

    // 點擊回彈
    effectClickBounce();

    // 按鈕鎖定
    setIsLock(true);

    // 對外通知
    if (onTap != null) {
      onTap!(this, isSpin);
    }
  }

  /// 設置偵錯矩陣
  void _setupDebugRect() {
    if (SlotGameConfig.isDebugMode) {
      debugRect = getDebugAnchorRect(
        size: Vector2(size.x, size.y),
        position: Vector2(size.x/2, size.y/2),
        pointColor: _isLock ? Colors.white : Colors.grey,
        contentColor: _isLock ? Colors.white.withAlpha(150) : Colors.grey.withAlpha(150),
      );
      add(debugRect!);
    }
  }

  /// 是否鎖定
  void setIsLock(bool lock) {
    _isLock = lock;
    // sprite = isLock ? spriteDisabled : spriteNormal;
  }

  /// 是否滾動
  void setIsSpin(bool spin) {
    print("spin: $spin");
    _isSpin = spin;
  }

  /// 點擊回彈
  void effectClickBounce() {
    EffectController sineEffectController = SineEffectController(period: 0.5);
    int repeatCount = 1;
    EffectController repeatedEffectController = RepeatedEffectController(sineEffectController, repeatCount);
    Effect effect = ScaleEffect.by(
      Vector2.all(0.8),
      repeatedEffectController,
      onComplete: () {
        // print("effectBounceAfterScale Finish!!!");
      },
    );
    add(effect);
  }
}