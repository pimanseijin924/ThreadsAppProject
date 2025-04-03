import 'package:flutter/foundation.dart';

@immutable
class Thread {
  final String title;
  final int viewCount;
  final int commentCount;
  final DateTime createdAt;

  Thread({
    required this.title,
    this.viewCount = 0,
    this.commentCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // 更新用のコピーを作成
  Thread copyWith({
    String? title,
    int? viewCount,
    int? commentCount,
    DateTime? createdAt,
  }) {
    return Thread(
      title: title ?? this.title,
      viewCount: viewCount ?? this.viewCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
