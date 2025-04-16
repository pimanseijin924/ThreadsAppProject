import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@immutable
class Thread {
  final String id;
  final String title;
  final int viewCount;
  final int commentCount;
  final int? maxCommentCount;
  final DateTime createdAt;
  final String? limitType;
  final DateTime? commentDeadline;

  Thread({
    required this.id,
    required this.title,
    this.viewCount = 0,
    this.commentCount = 0,
    this.maxCommentCount,
    DateTime? createdAt,
    this.limitType,
    this.commentDeadline,
  }) : createdAt = createdAt ?? DateTime.now();

  // 更新用のコピーを作成
  Thread copyWith({
    String? id,
    String? title,
    int? viewCount,
    int? commentCount,
    DateTime? createdAt,
  }) {
    return Thread(
      id: id ?? this.id,
      title: title ?? this.title,
      viewCount: viewCount ?? this.viewCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Thread.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Thread(
      id: doc.id,
      title: data['title'] ?? '',
      viewCount: data['viewCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
