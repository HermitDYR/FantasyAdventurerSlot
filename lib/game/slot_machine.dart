import 'package:fantasy_adventurer_slot/game/slot_game.dart';
import 'package:flame/components.dart';

/// 老虎機動作狀態
enum SlotMachineActionType {
  unknown,
  idle,
}

/// 老虎機動作物件
class SlotMachineAction {
  /// 老虎機動作狀態
  SlotMachineActionType type = SlotMachineActionType.unknown;

  /// 動作時間點(秒)
  double actionTime = 0.0;

  /// 延遲時間(秒)
  double delay = 0.0;
}

class SlotMachine extends PositionComponent with HasGameRef<SlotGame>{

  /// 盤面乘法 (x * y)
  Vector2 multiplication = Vector2.zero();

  List<SlotMachineAction>? slotMachineActionList;

  /// 老虎機
  SlotMachine({
    required this.multiplication,
    required Vector2? position,
    required Vector2? size,
  }) : super(position: position, size: size, anchor: Anchor.center);


  @override
  Future<void>? onLoad() async {
    // TODO: implement onLoad

    var action = SlotMachineAction()..type = SlotMachineActionType.idle;
    addAction(action);

    return super.onLoad();
  }

  void addAction(SlotMachineAction action) {
    slotMachineActionList ??= [];
    slotMachineActionList!.add(action);
  }

  void _checkActions() {
    if (slotMachineActionList != null) {
      if (slotMachineActionList!.first.type == SlotMachineActionType.idle) {

      }
    }
  }

  @override
  void update(double dt) {
    // TODO: implement update

    super.update(dt);
  }
}