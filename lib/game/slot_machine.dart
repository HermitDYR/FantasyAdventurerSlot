import 'dart:math';

import 'package:fantasy_adventurer_slot/abstract/gear.dart';
import 'package:fantasy_adventurer_slot/config/slot_game_config.dart';
import 'package:fantasy_adventurer_slot/game/slot_bar.dart';
import 'package:fantasy_adventurer_slot/game/slot_game.dart';
import 'package:fantasy_adventurer_slot/game/slot_machine_bars_box.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

/// 老虎機動作狀態
enum SlotMachineActionType {
  /// 未知
  unknown,
  /// 待機
  idle,
  /// 轉動
  spin,
  /// 停止
  stop,
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

class SlotMachine extends PositionComponent with Gear, HasGameRef<SlotGame>{

  SlotMachineActionType actionType = SlotMachineActionType.idle;

  /// 盤面乘法 (x * y)
  Vector2 multiplication = Vector2.zero();

  /// 老虎機槽條物件的精靈數量
  final rollItemSpritesCount = 11;

  /// 老虎機槽條物件的精靈列表
  final List<Sprite> rollItemSprites = [];

  /// 老虎機槽條箱移動速度
  final double slotBarBoxMoveSpeed = 2;

  /// 老虎機槽條箱
  SlotMachineBarsBox? slotMachineBarsBox;

  /// 是否為首次設定
  bool isFirstSetting = true;

  /// 是否滾動
  bool _isSpin = false;

  /// 是否滾動 (唯讀取)
  bool get isSpin => _isSpin;

  /// 開獎索引
  int lotteryIndex = 0;

  /// 取得遊戲模式開獎盤面
  List<List<int>> lottery = [];

  /// 老虎機目前的時間計數
  double currentDuration = 0.0;

  /// 老虎機的按鈕按下時間點
  double buttonTimePoint = 0.0;

  /// 老虎機各Bar的滾動延遲秒數
  double slotBarSpinDelay = 0.2;

  /// 老虎機各Bar的假滾動Box新增延遲秒數
  double fakeSlotBarBoxAddDelay = 0.2;

  /// 老虎機各Bar的停止延遲秒數
  double slotBarStopDelay = 0.2;

  /// 老虎機各Bar的假滾動Box移除延遲秒數
  double fakeSlotBarBoxRemoveDelay = 0.05;

  /// 老虎機各Bar的停止間隔時間點
  double nextStopTimePoint = 1.0;

  /// 是否自動停止
  bool isAutoStop = true;

  /// 老虎機各Bar的自動停止延遲秒數
  double slotBarAutoStopDelay = 2.0;

  /// 符合RTP中獎機率的設計模式開獎盤面列表(包含中獎、未中獎)
  List<List<List<int>>> designModeAllLotteryList = [];

  /// 符合RTP中獎機率的分數列表(包含中獎、未中獎)
  List<int> allLotteryPointList = [];

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
    if (actionType == SlotMachineActionType.idle) {
      if (currentDuration != 0.0) {
        currentDuration = 0.0;
        // print("currentDuration: $currentDuration");
      } else {
        return;
      }
    }

    if (gameRef.paused == false) {
      currentDuration += dt;
    }

    if (actionType == SlotMachineActionType.spin) {
      _checkSlotBarToSpin(currentDuration);

      if (isAutoStop) {
        if (currentDuration > buttonTimePoint + slotBarAutoStopDelay) {
          stop();
        }
      }
    }

    if (actionType == SlotMachineActionType.stop) {
      _checkSlotBarToStop(currentDuration);
    }

    super.update(dt);
  }

  /// 設置槽條箱
  void _setupSlotBarsBox() {
    var position = Vector2(this.size.x / 2, this.size.y / 2);
    slotMachineBarsBox = SlotMachineBarsBox(multiplication: multiplication, position: position, size: this.size);
    add(slotMachineBarsBox!);
  }

  void _checkSlotBarToSpin(double time) {

    var list = [];
    for (int i = 0; i < multiplication.x; i++) {
      list.add(buttonTimePoint + (i * slotBarSpinDelay));
    }

    if (slotMachineBarsBox != null) {
      for (int i = 0; i < multiplication.x; i++) {
        SlotBar? slotBar = slotMachineBarsBox!.getSlotBar(index: i);
        if (slotBar != null) {

          if (time > list[i] && time < (slotBarSpinDelay + list[i])) {
            // 寫法一，同步滾動
            slotBar.spin();
          }

          if (time > (list[i] + fakeSlotBarBoxAddDelay) && time < (slotBarSpinDelay + list[i] + fakeSlotBarBoxAddDelay)) {
            // 設置假的老虎機滾輪物件箱
            slotBar.addFakeSlotBarBox();
          }
        }
      }
    }
  }

  void _checkSlotBarToStop(double time) {
    // print("_checkSlotBarToStop currentDuration: $currentDuration, buttonTimePoint: $buttonTimePoint");
    // 設置盤面內容
    var timeList = [];
    for (int i = 0; i < multiplication.x; i++) {
      timeList.add(buttonTimePoint + (i * slotBarStopDelay) + nextStopTimePoint);
      SlotBar? slotBar = slotMachineBarsBox!.getSlotBar(index: i);
      if (slotBar != null && lottery.length > 0) {
        // 設置老虎機滾輪物件內容編號陣列
        slotBar.setupItemIdList(itemIdList: lottery[i]);
        // 取得當前Bar有中獎的索引陣列
        final lotteryIndexList = getLotteryIndexOnBar(lotteryNumbers: lottery, barIndex: i);
        slotBar.setupItemLotteryIndexList(itemLotteryIndexList: lotteryIndexList);

        if (time > timeList[i] && time < (slotBarStopDelay + timeList[i])) {
          // print("SlotBar $i to Stop Do!!!");
          // 將老虎機滾輪物件箱子新增到上方外部錨點上
          slotBar.addSlotBarBoxAtTopOutside();
        }

        if (time > timeList[i] + fakeSlotBarBoxRemoveDelay && time < (slotBarStopDelay + timeList[i] + fakeSlotBarBoxRemoveDelay)) {
          // print("SlotBar $i to Stop Do Delay!!!");
          // 將假的老虎機滾輪物件箱移除
          if (slotBar.fakeSlotBarBox != null) {
            slotBar.fakeSlotBarBox!.removeFromParent();
            slotBar.fakeSlotBarBox = null;
          }

          if (i == multiplication.x - 1) {
            actionType = SlotMachineActionType.idle;

            // 按鈕解除鎖定
            // gameRef.slotGameControlMenu.slotGameSpinButton!.setIsLock(false);
          }
        }
      }
    }
  }


  /// 取得當前Bar有中獎的索引陣列
  /// - 判斷橫向直線開獎，確認每個Bar裡相同的Index下LotteryNumber是否一致
  /// - 判斷左上到右下斜線開獎
  /// - 判斷左下到右上斜線開獎
  List<int>? getLotteryIndexOnBar({required List<List<int>> lotteryNumbers, required int barIndex}) {
    if (lotteryNumbers.length != multiplication.x || lotteryNumbers.first.length != multiplication.y) {
      // print("數量有誤");
      return null;
    }

    // 中獎陣列
    List<int> lotteryIndexList = [];

    // 判斷橫向直線開獎，確認每個Bar裡相同的Index下LotteryNumber是否一致
    for (int j = 0; j < multiplication.y; j++) {
      List<int> horizontalCheckList = [];
      for (int i = 0; i < multiplication.x; i++) {
        horizontalCheckList.add(lotteryNumbers[i][j]);
      }
      // print("SlotMachine >> barItemCount Index $j BarsRowList $horizontalCheckList");
      final horizontalFind = horizontalCheckList.where((element) {
        return (element == horizontalCheckList.first);
      });
      if (horizontalFind.length == multiplication.x) {
        lotteryIndexList.add(j);
      }
    }

    // 判斷左上到右下斜線開獎
    int leftTopToRightBottomTargetIndex = barIndex;
    List<int> leftTopToRightBottomCheckList = [];
    for (int i = 0; i < multiplication.x; i++) {
      leftTopToRightBottomCheckList.add(lotteryNumbers[i][i]);
    }
    final leftTopToRightBottomFind = leftTopToRightBottomCheckList.where((element) {
      return (element == leftTopToRightBottomCheckList.first);
    });
    if (leftTopToRightBottomFind.length == multiplication.x) {
      lotteryIndexList.add(leftTopToRightBottomTargetIndex);
    }

    // 判斷左下到右上斜線開獎
    List<int> leftBottomToRightTopCheckList = [];
    int leftBottomToRightTopTargetIndex = ((multiplication.x - 1.0) - barIndex).toInt();
    for (int i = 0; i < multiplication.x; i++) {
      leftBottomToRightTopCheckList.add(lotteryNumbers[i][((multiplication.x - 1.0) - i).toInt()]);
    }
    final find = leftBottomToRightTopCheckList.where((element) {
      return (element == leftBottomToRightTopCheckList.first);
    });
    if (find.length == multiplication.x) {
      lotteryIndexList.add(leftBottomToRightTopTargetIndex);
    }

    // print("SlotMachine >> lotteryIndexList: $lotteryIndexList");

    // 去除重複內容(索引)
    lotteryIndexList = lotteryIndexList.toSet().toList();
    // print("SlotMachine >> lotteryIndexList(After to Set): $lotteryIndexList");

    return lotteryIndexList;
  }

  /// 設置是否滾動
  void setIsSpin(bool spin) {
    _isSpin = spin;
    // if (gameRef.slotGameControlMenu.slotGameSpinButton != null) {
    //   gameRef.slotGameControlMenu.slotGameSpinButton!.setIsSpin(_isSpin);
    // }
  }

  /// 開始滾動
  void spin() async {
    print("SlotMachine >> spin~~~");

    buttonTimePoint = currentDuration;
    actionType = SlotMachineActionType.spin;
    print("buttonTimePoint(currentDuration): $buttonTimePoint");

    // 設置是否滾動
    // setIsSpin((gameRef.gameBalance > 0));

    // 確認餘額是否足夠
    // if (!(gameRef.gameBalance > bet)) {
    //   setIsSpin((gameRef.gameBalance > bet));
    //   return;
    // }

    // 確認是否為最大回合數
    // if (_checkIsMaxGameRound()) return;

    // 確認遊戲回合
    // _checkGameRound();

    // 播放背景音樂
    // gameRef.audioPlayBGM();

    // 播放滾動音效
    // _audioPlaySpin(delayMilliseconds: 0);

    // 更新得分
    // win = 0;

    // 更新下注
    // bet = 100;

    // 更新餘額
    // gameRef.gameBalance -= bet;

    // 進行得分動畫
    // gameRef.slotGameControlMenu.showWin(win: win);

    // 進行下注動畫
    // gameRef.slotGameControlMenu.showBet(bet: bet);

    // 進行餘額動畫
    // gameRef.slotGameControlMenu.showBalance(balance: gameRef.gameBalance);

    // // 指定時間後停止
    // int delayStopMilliseconds = (barCount * slotBarDelayMilliseconds) * 2;
    // Future.delayed(Duration(milliseconds: delayStopMilliseconds), () {
    //   print("Delay to Stop!!!");
    //   stop();
    // });
  }

  /// 停止滾動
  void stop() async {
    if (actionType == SlotMachineActionType.stop) {
      return;
    }
    print("SlotMachine >> stop!!!");

    buttonTimePoint = currentDuration;
    actionType = SlotMachineActionType.stop;
    print("buttonTimePoint(currentDuration): $buttonTimePoint");

    // 設置是否滾動
    setIsSpin(false);

    // 播放停止音效
    // _audioPlayStop(delayMilliseconds: 0);

    // 設置下一輪滾輪組的盤面內容
    if (slotMachineBarsBox != null) {
      lotteryIndex = 0;
      if (isFirstSetting) {
        isFirstSetting = false;
      } else {
        lotteryIndex = Random().nextInt(designModeAllLotteryList.length);
      }

      // 取得遊戲模式開獎盤面(用於運作程式邏輯)
      lottery = SlotGameConfig.getGameModeLottery(designModeAllLotteryList: designModeAllLotteryList, index: lotteryIndex);

      // 更新得分
      // win = allLotteryPointList[lotteryIndex];

      // 更新餘額
      // gameRef.gameBalance += win;

      // 判斷是否進入Bonus遊戲模式準備階段
      // _checkBonusGame();
    }
  }

}