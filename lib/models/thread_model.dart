import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

@immutable
class Thread {
  final String id;
  final String title;
  final int viewCount;
  final int commentCount;
  final DateTime createdAt;
  final String? limitType;
  final int? maxCommentCount;
  final DateTime? commentDeadline;
  final bool isDat;
  final String? label;

  Thread({
    required this.id,
    required this.title,
    this.viewCount = 0,
    this.commentCount = 0,
    required this.createdAt,
    this.limitType,
    this.maxCommentCount,
    this.commentDeadline,
    required this.isDat,
    this.label,
  });

  // 更新用のコピーを作成
  Thread copyWith({
    String? id,
    String? title,
    int? viewCount,
    int? commentCount,
    DateTime? createdAt,
    String? limitType,
    int? maxCommentCount,
    DateTime? commentDeadline,
    bool? isDat,
    String? label,
  }) {
    return Thread(
      id: id ?? this.id,
      title: title ?? this.title,
      viewCount: viewCount ?? this.viewCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      limitType: limitType ?? this.limitType,
      maxCommentCount: maxCommentCount ?? this.maxCommentCount,
      commentDeadline: commentDeadline ?? this.commentDeadline,
      isDat: isDat ?? this.isDat,
      label: label ?? this.label,
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
      limitType: data['limitType'] as String,
      maxCommentCount: data['maxCommentCount'] as int,
      commentDeadline: (data['commentDeadline'] as Timestamp?)?.toDate(),
      isDat: data['isDat'] as bool? ?? false,
      label: data['label'] as String,
    );
  }
}
