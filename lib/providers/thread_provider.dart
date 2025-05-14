import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/models/thread_model.dart';
import 'package:my_app/models/comment_model.dart';
import 'package:my_app/models/last_thread_model.dart';
import 'package:my_app/services/thread_service.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// **スレッド全体を管理するプロバイダー**
// final threadProvider = StateNotifierProvider<ThreadNotifier, List<Thread>>(
//   (ref) => ThreadNotifier(),
// );

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
            createdAt: (data['createdAt'] as Timestamp).toDate(),
            viewCount: data['viewCount'],
            commentCount: data['commentCount'] ?? 0,
            limitType: data['limitType'] ?? 'count',
            maxCommentCount: data['maxCommentCount'] ?? 1000,
            commentDeadline: (data['commentDeadline'] as Timestamp?)?.toDate(),
            isDat: data['isDat'] ?? false,
            label: data['label'] ?? '',
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

// 閲覧している直近の板情報をローカルに保存
///SharedPreferences インスタンスをグローバルに提供
final sharedPrefsProvider = FutureProvider<SharedPreferences>((_) async {
  return await SharedPreferences.getInstance();
});

///直近閲覧板IDを管理する StateNotifier
class LastBoardNotifier extends StateNotifier<String?> {
  static const _key = 'last_board_id';
  final SharedPreferences? _prefs;

  LastBoardNotifier(this._prefs) : super(_prefs?.getString(_key));

  /// 板ID を更新し、SharedPreferences にも書き込む
  Future<void> setBoardId(String boardId) async {
    state = boardId;
    await _prefs?.setString(_key, boardId);
  }
}

///StateNotifierProvider を定義
final lastBoardProvider = StateNotifierProvider<LastBoardNotifier, String?>((
  ref,
) {
  final prefs = ref
      .watch(sharedPrefsProvider)
      .maybeWhen(data: (p) => p, orElse: () => null);
  return LastBoardNotifier(prefs);
});

/// 直近に見たスレッド情報を管理する StateNotifier
class LastThreadNotifier extends StateNotifier<LastThread?> {
  static const _key = 'last_thread';
  final SharedPreferences? _prefs;

  LastThreadNotifier(this._prefs)
    : super(
        // 起動時にキャッシュから復元。なければ null。
        _prefs?.getString(_key) != null
            ? LastThread.fromJson(jsonDecode(_prefs!.getString(_key)!))
            : null,
      );

  /// スレッド情報を更新し、SharedPreferences に JSON 文字列で永続化
  Future<void> setLastThread({
    required String boardId,
    required String threadId,
  }) async {
    final value = LastThread(boardId: boardId, threadId: threadId);
    state = value;
    final jsonString = jsonEncode(value.toJson());
    await _prefs?.setString(_key, jsonString);
  }

  /// キャッシュをクリアしたいとき
  Future<void> clear() async {
    state = null;
    await _prefs?.remove(_key);
  }
}

/// プロバイダー定義
final lastThreadProvider =
    StateNotifierProvider<LastThreadNotifier, LastThread?>((ref) {
      final prefs = ref
          .watch(sharedPrefsProvider)
          .maybeWhen(data: (p) => p, orElse: () => null);
      return LastThreadNotifier(prefs);
    });

// Uuid のインスタンスを提供するプロバイダー
final uuidProvider = Provider<Uuid>((ref) => Uuid());
