import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// 齒輪狀態
enum GearStatus {
  unknown,
  idle,
  run,
  finish,
}

/// 齒輪抽象類別
mixin Gear on Component {

  /// 偵錯矩陣
  RectangleComponent? debugRect;

  /// 狀態
  GearStatus status = GearStatus.unknown;

  /// 開始時間
  get beginTime => _beginTime;

  /// 開始時間
  double _beginTime = 0.0;

  /// 是否運行
  bool isRun = false;

  /// 持續時間
  double runTime = 0.0;

  /// 是否完成
  bool isFinish = false;

  /// 完成時間
  double? finishTime;

  /// 完成回調
  Function(double begin, double run, double finished)? onFinish;

  @override
  void update(double dt) {
    // TODO: implement update
    if (status == GearStatus.idle) {
      runTime = 0.0;
      return;
    }

    if (status == GearStatus.run) {
      if (isRun == false) {
        isRun = true;
      }
      runTime += dt;
    }

    if (finishTime != null && runTime >= finishTime!) {
      if (isFinish == false) {
        isFinish = true;
        finished(finishTime!);
      }
      return;
    }

    super.update(dt);
  }

  void idle() {
    print("I'm idle.");
    status = GearStatus.idle;
  }

  void runBegin(double dtBegin) {
    print("I'm running~~~");
    status = GearStatus.run;
    _beginTime = dtBegin;
  }

  void finished(double dtFinish) {
    print("I'm finished~~~ $dtFinish");
    status = GearStatus.finish;
    if (onFinish != null) {
      onFinish!(beginTime, runTime, finishTime!);
    }
  }

  /// 測試錨點標示物件
  RectangleComponent getDebugAnchorRect({
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
}
