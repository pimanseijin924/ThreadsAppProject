import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userIdProvider = FutureProvider<String>((ref) async {
  return await getUserId();
});

// 許可される文字セット
const String _allowedChars =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+*-/!';

/// ユーザーIDを取得 or 生成するメソッド
Future<String> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;
  final deviceId = androidInfo.id; // デバイスUUIDを取得
  final today = DateTime.now().toUtc().add(
    Duration(hours: 9),
  ); // 日本時間 (JST) に変換
  final todayKey = '${today.year}-${today.month}-${today.day}';

  // 既存のIDと日付を取得
  final savedId = prefs.getString('user_id');
  final savedDate = prefs.getString('user_id_date');

  // 日付が変わった or IDが未設定なら新しいIDを生成
  if (savedDate != todayKey || savedId == null) {
    final newUserId = _generateUserId(deviceId);
    await prefs.setString('user_id', newUserId);
    await prefs.setString('user_id_date', todayKey);
    return newUserId;
  }

  return savedId;
}

// UUIDを元にランダムなIDを生成
String _generateUserId(String uuid) {
  // UUIDのハッシュ値を使ってシードを設定
  //final random = Random(uuid.hashCode);
  //　NOTE:ID生成方法：UUIDに依存せず完全にランダムにする
  final random = Random(); //
  return List.generate(
    13,
    (index) => _allowedChars[random.nextInt(_allowedChars.length)],
  ).join();
}
