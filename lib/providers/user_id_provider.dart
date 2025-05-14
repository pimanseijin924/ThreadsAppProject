import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userIdProvider = FutureProvider<String>((ref) async {
  return await getUserId();
});

// 許可される文字セット
const String _allowedChars =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+*-!';

// 公開IPを取得する(api.ipify.orgを使用)
Future<String> fetchPublicIp() async {
  final response = await http.get(
    Uri.parse('https://api.ipify.org?format=json'),
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['ip'] as String;
  } else {
    throw Exception('IPアドレス取得失敗: ${response.statusCode}');
  }
}

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
  if (savedDate != todayKey || savedId == null || savedId.isEmpty) {
    final ip = await fetchPublicIp();
    final newId = _generateFromIp(ip, todayKey);
    //final newUserId = _generateUserId(deviceId);
    await prefs.setString('user_id', newId);
    await prefs.setString('user_id_date', todayKey);
    return newId;
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

// IPアドレスと日付をもとに匿名IDを生成
String _generateFromIp(String ip, String dateKey) {
  // IP+日付のハッシュをシードにしてRandomを初期化
  final seed = ip.hashCode ^ dateKey.hashCode;
  final random = Random(seed);
  //16文字分ランダムに選んで結合
  return List.generate(
    16,
    (_) => _allowedChars[random.nextInt(_allowedChars.length)],
  ).join();
}

// 設計した外部APIを利用してIPからIDを生成
Future<String> fetchAnonymousId() async {
  final url = Uri.parse(
    "https://us-central1-threadappproject.cloudfunctions.net/getAnonymousId",
  );
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return json["displayId"];
  } else {
    throw Exception("匿名IDの取得に失敗しました");
  }
}
