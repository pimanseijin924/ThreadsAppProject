import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/models/thread_model.dart';
import 'package:my_app/models/comment_model.dart';
import 'package:my_app/services/thread_service.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// **スレッド全体を管理するプロバイダー**
final threadProvider = StateNotifierProvider<ThreadNotifier, List<Thread>>(
  (ref) => ThreadNotifier(),
);

/// 指定された boardId に属するスレッド一覧を取得する StreamProvider
final boardThreadsProvider = StreamProvider.family<List<Thread>, String>((
  ref,
  boardId,
) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('threads')
      .where('boardIds', arrayContains: boardId)
      //.orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Thread(
            id: doc.id,
            title: data['title'] ?? '',
            viewCount: data['viewCount'],
            createdAt: (data['createdAt'] as Timestamp).toDate(),
            commentCount: data['commentCount'] ?? 0,
            maxCommentCount: data['maxCommentCount'] ?? 1000,
            limitType: data['limitType'] ?? 'count',
            commentDeadline: (data['commentDeadline'] as Timestamp?)?.toDate(),
          );
        }).toList();
      });
});

// スレッドを見たときに閲覧数を増やすプロバイダー
final incrementThreadViewCountProvider = Provider.family<void, String>((
  ref,
  threadId,
) {
  final threadDocRef = FirebaseFirestore.instance
      .collection('threads')
      .doc(threadId);

  threadDocRef.update({'viewCount': FieldValue.increment(1)}).catchError((e) {
    print("閲覧数のインクリメントに失敗しました: $e");
  });
});

// threadIdを指定してスレッドの詳細を取得するプロバイダー
final threadByIdProvider = FutureProvider.family<Thread, String>((
  ref,
  threadId,
) async {
  try {
    final doc =
        await FirebaseFirestore.instance
            .collection('threads')
            .doc(threadId)
            .get();

    if (!doc.exists) {
      throw Exception('スレッドが見つかりません');
    }

    return Thread.fromFirestore(doc);
  } catch (e, stackTrace) {
    throw AsyncError(e, stackTrace);
  }
});

// threadIdを指定してそのスレッドのレスを取得するプロバイダー
final threadCommentsProvider = StreamProvider.family<List<Comment>, String>((
  ref,
  threadId,
) {
  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('threads')
      .doc(threadId)
      .collection('comments')
      .orderBy('resNumber')
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Comment.fromFireStore(doc)).toList(),
      );
});

// スレッドにコメントを追加するためのプロバイダー
final addCommentProvider = Provider((ref) => AddCommentService());

// スレッドを作成するためのプロバイダー
final createThreadProvider = Provider((ref) => CreateThreadService());

/// **スレッド管理クラス**
class ThreadNotifier extends StateNotifier<List<Thread>> {
  ThreadNotifier()
    : super([
        Thread(id: '1', title: 'Flutterの質問スレッド'),
        Thread(id: '2', title: 'Dartの基本を学ぼう'),
        Thread(id: '3', title: '初心者向けプログラミング'),
        Thread(id: '4', title: 'Flutterで匿名掲示板を作る'),
        Thread(id: '5', title: '技術雑談スレッド'),
      ]);

  /// **スレッドを追加**
  void addThread(String title, int viewCount, int commentCount) {
    final newThread = Thread(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      viewCount: viewCount,
      commentCount: commentCount,
      createdAt: DateTime.now(),
    );
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
          orElse: () => Thread(id: '0', title: '', commentCount: 0),
        )
        .commentCount;
  }

  /// **スレッドの作成日時を取得**
  DateTime? getThreadCreatedAt(String title) {
    return state
        .firstWhere(
          (thread) => thread.title == title,
          orElse: () => Thread(id: '0', title: '', commentCount: 0),
        )
        .createdAt;
  }
}

/// **スレッドごとのコメント管理**
// final threadCommentsProvider =
//     StateNotifierProvider.family<ThreadCommentsNotifier, List<Comment>, String>(
//       (ref, threadTitle) => ThreadCommentsNotifier(),
//     );

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
    required DateTime sendTime,
    List<String>? imageUrl,
    List<String>? imagePath,
  }) {
    final comment = Comment(
      resNumber: resNumber,
      name: name,
      email: email,
      content: content,
      userId: userId,
      sendTime: sendTime,
      imageUrl: imageUrl ?? [], // 画像URLは必須ではないので、nullの場合は空文字を設定
      imagePath: imagePath ?? [], // 画像パスもオプション
    );
    state = [...state, comment];
  }
}

// Uuid のインスタンスを提供するプロバイダー
final uuidProvider = Provider<Uuid>((ref) => Uuid());
