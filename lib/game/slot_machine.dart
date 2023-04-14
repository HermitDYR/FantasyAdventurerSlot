import 'package:fantasy_adventurer_slot/abstract/gear.dart';
import 'package:fantasy_adventurer_slot/config/slot_game_config.dart';
import 'package:fantasy_adventurer_slot/game/slot_game.dart';
import 'package:fantasy_adventurer_slot/game/slot_machine_bar_box.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

// /// 老虎機動作狀態
// enum SlotMachineActionType {
//   unknown,
//   idle,
// }

// /// 老虎機動作物件
// class SlotMachineAction {
//   /// 老虎機動作狀態
//   SlotMachineActionType type = SlotMachineActionType.unknown;
//
//   /// 動作時間點(秒)
//   double actionTime = 0.0;
//
//   /// 延遲時間(秒)
//   double delay = 0.0;
// }

class SlotMachine extends PositionComponent with Gear, HasGameRef<SlotGame>{

  /// 盤面乘法 (x * y)
  Vector2 multiplication = Vector2.zero();

  SlotMachineBarsBox? slotMachineBarsBox;

  /// 老虎機
  SlotMachine({
    required this.multiplication,
    required Vector2? position,
    required Vector2? size,
  }) : super(position: position, size: size, anchor: Anchor.center);


  @override
  Future<void>? onLoad() async {
    // TODO: implement onLoad
    // TODO: 測試模式 (這個會降低效能，非必要不要開著)
    add(RectangleHitbox()..debugMode = SlotGameConfig.isDebugMode);

    // 設置槽條箱
    _setupSlotBarsBox();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // TODO: implement update
    super.update(dt);
  }

  /// 設置槽條箱
  void _setupSlotBarsBox() {
    var position = Vector2(this.size.x / 2, this.size.y / 2);
    slotMachineBarsBox = SlotMachineBarsBox(multiplication: multiplication, position: position, size: this.size);
    add(slotMachineBarsBox!);
  }

}