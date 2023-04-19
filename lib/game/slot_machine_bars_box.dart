import 'package:fantasy_adventurer_slot/abstract/gear.dart';
import 'package:fantasy_adventurer_slot/config/slot_game_config.dart';
import 'package:fantasy_adventurer_slot/game/slot_bar.dart';
import 'package:fantasy_adventurer_slot/game/slot_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class SlotMachineBarsBox extends PositionComponent with Gear, HasGameRef<SlotGame> {

  /// 盤面乘法 (x * y)
  Vector2 multiplication = Vector2.zero();

  /// 停留次數
  int _barStayCount = 0;

  /// 所有的槽條皆進入停留狀態
  Function()? onAllBarStay;

  /// 老虎機槽條箱
  SlotMachineBarsBox({
    required this.multiplication,
    required Vector2? position,
    required Vector2? size,
    this.onAllBarStay,
  }) : super(position: position, size: size, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // TODO: implement onLoad
    // TODO: 測試模式 (這個會降低效能，非必要不要開著)
    add(RectangleHitbox()..debugMode = SlotGameConfig.isDebugMode);

    // 設置老虎機槽條
    _setupSlotBars();

    return super.onLoad();
  }

  /// 設置老虎機槽條
  void _setupSlotBars() {
    final Vector2 position = Vector2(0, 0);
    final barWidth = this.size.x / multiplication.x;
    final Vector2 size = Vector2(barWidth, barWidth * multiplication.y);
    for (int i = 0; i < multiplication.x.toInt(); i++) {
      print("i: $i, width: $barWidth");
      final slotBar = SlotBar(
        index: i,
        itemCount: multiplication.y.toInt(),
        position: Vector2(position.x + (i * size.x), position.y),
        size: size,
        onStayFromSlotBarBox: _onStayFromSlotBarBox,
      );
      add(slotBar);
    }
  }

  /// 老虎機槽條物件箱進入停留狀態
  void _onStayFromSlotBarBox(int index) {
    print("SlotMachineBarsBox >> _onStayFromSlotBarBox index: $index");
    _barStayCount++;
    if (_barStayCount >= multiplication.x) {
      if (onAllBarStay != null) {
        onAllBarStay!();
      }
      _barStayCount = 0;
    }
  }

  /// 取得老虎機滾輪
  SlotBar? getSlotBar({required int index}) {
    for (Component component in children.toList()) {
      if (component is SlotBar) {
        SlotBar slotBar = component;
        if (slotBar.index == index) {
          return component;
        }
      }
    }
    return null;
  }
}