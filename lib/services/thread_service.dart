import 'package:cloud_firestore/cloud_firestore.dart';

// スレッドにコメントを追加するためのサービス
class AddCommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addComment({
    required String threadId,
    required String writerId,
    required String writerName,
    required String writerEmail,
    required String content,
    List<String>? imageUrls,
  }) async {
    final threadDocRef = _firestore.collection('threads').doc(threadId);
    final commentsCollectionRef = threadDocRef.collection('comments');

    await _firestore.runTransaction((transaction) async {
      final threadSnapshot = await transaction.get(threadDocRef);

      if (!threadSnapshot.exists) {
        throw Exception("スレッドが存在しません");
      }

      final currentCommentCount = threadSnapshot.get('commentCount') as int;
      final newCommentNumber = currentCommentCount + 1;

      // 新しいレスのドキュメントIDをresNumberと同じにする
      final newCommentRef = commentsCollectionRef.doc(
        newCommentNumber.toString(),
      );

      // レス追加
      transaction.set(newCommentRef, {
        'resNumber': newCommentNumber,
        'writerId': writerId,
        'writerName': writerName,
        'writerEmail': writerEmail,
        'content': content,
        'sendtime': FieldValue.serverTimestamp(),
        if (imageUrls != null && imageUrls.isNotEmpty) 'imageUrl': imageUrls,
      });

      // commentCountのインクリメント
      transaction.update(threadDocRef, {
        'commentCount': FieldValue.increment(1),
      });
    });
  }
}

// スレッドを作成するためのサービス
class CreateThreadService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// スレッドを作成する
  Future<String> createThread({
    required String title,
    required List<String> boardIds,
    required int maxCommentCount,
    required String limitType, // 'count' または 'time'
    DateTime? commentDeadline,
  }) async {
    // コレクション参照を取得
    final colRef = _firestore.collection('threads');
    String docRefId = '';

    //  add() でドキュメントを追加（自動生成 ID）
    final docRef = await colRef.add({
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
      'boardIds': boardIds,
      'viewCount': 0,
      'commentCount': 0,
      'maxCommentCount': maxCommentCount,
      'limitType': limitType,
      'commentDeadline':
          commentDeadline ??
          DateTime.now().add(Duration(days: 365 * 100)), // デフォルトは100年後
    });

    // ドキュメントのIDを取得して、ドキュメントに保存
    await docRef.set({'id': docRef.id}, SetOptions(merge: true));

    // 自動生成IDを取得
    docRefId = docRef.id;

    // 自動生成IDを取得
    return docRefId;
  }
}
