import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/comment_model.dart';
import 'package:uuid/uuid.dart';

// スレッドのリスト管理
final threadListProvider =
    StateNotifierProvider<ThreadListNotifier, List<String>>(
      (ref) => ThreadListNotifier(),
    );

// スレッドごとの閲覧数管理
final threadViewCountProvider =
    StateNotifierProvider<ThreadViewCountNotifier, Map<String, int>>(
      (ref) => ThreadViewCountNotifier(),
    );

class ThreadListNotifier extends StateNotifier<List<String>> {
  ThreadListNotifier()
    : super([
        'Flutterの質問スレッド',
        'Dartの基本を学ぼう',
        '初心者向けプログラミング',
        'Flutterで匿名掲示板を作る',
        '技術雑談スレッド',
      ]);

  void addThread(String threadTitle) {
    print('Thread added: $threadTitle');
    state = [...state, threadTitle];
  }
}

class ThreadViewCountNotifier extends StateNotifier<Map<String, int>> {
  ThreadViewCountNotifier() : super({});

  void incrementViewCount(String threadTitle) {
    print('Thread viewed: $threadTitle');
    state = {...state, threadTitle: (state[threadTitle] ?? 0) + 1};
  }
}

// コメントモデルの定義

final threadCommentsProvider =
    StateNotifierProvider.family<ThreadCommentsNotifier, List<Comment>, String>(
      (ref, threadTitle) => ThreadCommentsNotifier(),
    );

class ThreadCommentsNotifier extends StateNotifier<List<Comment>> {
  ThreadCommentsNotifier() : super([]);

  // コメント追加時に、既存のコメント数からレス番号を決定
  void addComment({
    required int resNumber,
    required String name,
    required String email,
    required String content,
    required String userId,
    required String timestamp,
  }) {
    // final int newResNumber = state.length + 1; // レス番号は現在のコメント数+1
    final comment = Comment(
      resNumber: resNumber,
      name: name,
      email: email,
      content: content,
      userId: userId,
      timestamp: timestamp,
    );
    print('Comment added: $comment');
    state = [...state, comment];
  }
}

// Uuid のインスタンスを提供するプロバイダー
final uuidProvider = Provider<Uuid>((ref) => Uuid());
