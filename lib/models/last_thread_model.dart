//import 'dart:convert';

/// 直近に見たスレッドの板ID＋スレッドIDをセットで保持するモデル
class LastThread {
  final String boardId;
  final String threadId;

  LastThread({required this.boardId, required this.threadId});

  /// JSON ←→ Dart オブジェクト変換用
  Map<String, dynamic> toJson() => {'boardId': boardId, 'threadId': threadId};

  factory LastThread.fromJson(Map<String, dynamic> json) {
    return LastThread(
      boardId: json['boardId'] as String,
      threadId: json['threadId'] as String,
    );
  }
}
