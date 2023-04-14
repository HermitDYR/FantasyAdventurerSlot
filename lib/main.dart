import 'package:fantasy_adventurer_slot/game/slot_game.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';

void main() async {
  // 確認Flutter已剛成初始化綁定動作
  WidgetsFlutterBinding.ensureInitialized();

  // 設置Flame類
  await _setupFlameGame();

  // 啟動應用
  runApp(GameWidget(game: SlotGame()));
}

/// 設置Flame類
/// - 設置2D遊戲相關設定
Future<void> _setupFlameGame() async {
  // 填滿全畫面
  await Flame.device.fullScreen();
  // 螢幕垂直
  await Flame.device.setPortrait();
}
