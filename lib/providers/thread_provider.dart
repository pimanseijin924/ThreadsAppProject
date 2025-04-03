import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/thread_model.dart';
import '../models/comment_model.dart';
import 'package:uuid/uuid.dart';

/// **スレッド全体を管理するプロバイダー**
final threadProvider = StateNotifierProvider<ThreadNotifier, List<Thread>>(
  (ref) => ThreadNotifier(),
);

/// **スレッド管理クラス**
class ThreadNotifier extends StateNotifier<List<Thread>> {
  ThreadNotifier()
    : super([
        Thread(title: 'Flutterの質問スレッド'),
        Thread(title: 'Dartの基本を学ぼう'),
        Thread(title: '初心者向けプログラミング'),
        Thread(title: 'Flutterで匿名掲示板を作る'),
        Thread(title: '技術雑談スレッド'),
      ]);

  /// **スレッドを追加**
  void addThread(String title) {
    final newThread = Thread(title: title);
    state = [...state, newThread];
  }

  /// **スレッドのビュー数を増やす**
  void incrementViewCount(String title) {
    state =
        state.map((thread) {
          if (thread.title == title) {
            return thread.copyWith(viewCount: thread.viewCount + 1);
          }
          return thread;
        }).toList();
  }

  /// **スレッドの書き込み数を増やす**
  void incrementCommentCount(String title) {
    state =
        state.map((thread) {
          if (thread.title == title) {
            return thread.copyWith(commentCount: thread.commentCount + 1);
          }
          return thread;
        }).toList();
  }

  // **追加**: スレッドの書き込み数を取得する
  int getCommentCount(String title) {
    return state
        .firstWhere(
          (thread) => thread.title == title,
          orElse: () => Thread(title: '', commentCount: 0),
        )
        .commentCount;
  }

  /// **スレッドの作成日時を取得**
  DateTime? getThreadCreatedAt(String title) {
    return state
        .firstWhere(
          (thread) => thread.title == title,
          orElse: () => Thread(title: ''),
        )
        .createdAt;
  }
}

/// **スレッドごとのコメント管理**
final threadCommentsProvider =
    StateNotifierProvider.family<ThreadCommentsNotifier, List<Comment>, String>(
      (ref, threadTitle) => ThreadCommentsNotifier(),
    );

/// **コメント管理クラス**
class ThreadCommentsNotifier extends StateNotifier<List<Comment>> {
  ThreadCommentsNotifier() : super([]);

  /// **コメント追加**
  void addComment({
    required int resNumber,
    required String name,
    required String email,
    required String content,
    required String userId,
    required String timestamp,
  }) {
    final comment = Comment(
      resNumber: resNumber,
      name: name,
      email: email,
      content: content,
      userId: userId,
      timestamp: timestamp,
    );
    state = [...state, comment];
  }
}

// Uuid のインスタンスを提供するプロバイダー
final uuidProvider = Provider<Uuid>((ref) => Uuid());
