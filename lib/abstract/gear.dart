import 'package:flame/components.dart';

/// 齒輪狀態
enum GearStatus {
  unknown,
  idle,
  run,
  finish,
}

/// 齒輪抽象類別
mixin Gear on Component {
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

  void run(double dtBegin) {
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
}
