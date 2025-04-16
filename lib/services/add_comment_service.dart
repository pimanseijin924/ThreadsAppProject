import 'package:cloud_firestore/cloud_firestore.dart';

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
