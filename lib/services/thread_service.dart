import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as transaction;
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AddCommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addComment({
    required String threadId,
    required String writerId,
    required String writerName,
    required String writerEmail,
    required String content,
    List<String>? imageUrls,
    String? clientIp, // IPアドレスを渡せるなら引数に
  }) async {
    final threadDocRef = _firestore.collection('threads').doc(threadId);
    final userDocRef =
        writerId.isEmpty
            ? _firestore.collection('users').doc('NoID')
            : _firestore.collection('users').doc(writerId);
    final commentsCollectionRef = threadDocRef.collection('comments');

    await _firestore.runTransaction((transaction) async {
      // 1. スレッド情報取得
      final threadSnap = await transaction.get(threadDocRef);
      if (!threadSnap.exists) {
        throw Exception("スレッドが存在しません(threadId: $threadId)");
      }
      final currentCommentCount = threadSnap.get('commentCount') as int;
      final newCommentNumber = currentCommentCount + 1;
      final newCommentId = newCommentNumber.toString();
      final newCommentRef = commentsCollectionRef.doc(newCommentId);

      // 2. ユーザー情報取得（初回かどうか判定）

      final userSnap = await transaction.get(userDocRef);
      if (!userSnap.exists) {
        // **初回の書き込み** -> 初期フィールドを作成
        final deviceUuid = await _getDeviceUuid();
        transaction.set(userDocRef, {
          'uuid': deviceUuid,
          'ip': clientIp ?? '',
          'postHistory': [newCommentId],
          'threadNum': 0,
          'resNum': 1,
          'imageHistory': imageUrls != null ? imageUrls : [],
          // タイムスタンプは別フィールドで管理
          'lastImagePostTime':
              imageUrls != null && imageUrls.isNotEmpty
                  ? FieldValue.serverTimestamp()
                  : null,
        });
      } else {
        // **既存ユーザー** -> arrayUnion / increment で更新
        final userUpdates = <String, dynamic>{
          'postHistory': FieldValue.arrayUnion([newCommentId]),
          'resNum': FieldValue.increment(1),
        };
        if (imageUrls != null && imageUrls.isNotEmpty) {
          userUpdates['imageHistory'] = FieldValue.arrayUnion(imageUrls);
          // タイムスタンプは別フィールドでまとめて更新
          userUpdates['lastImagePostTime'] = FieldValue.serverTimestamp();
          // final imageEntries =
          //     imageUrls
          //         .map(
          //           (url) => {
          //             'imageUrl': url,
          //             'postTime': FieldValue.serverTimestamp(),
          //           },
          //         )
          //         .toList();
          // userUpdates['imageHistory'] = FieldValue.arrayUnion(imageEntries);
        }
        transaction.update(userDocRef, userUpdates);
      }

      // 3. コメントの追加
      transaction.set(newCommentRef, {
        'resNumber': newCommentNumber,
        'writerId': writerId,
        'writerName': writerName,
        'writerEmail': writerEmail,
        'content': content,
        'sendtime': FieldValue.serverTimestamp(),
        if (imageUrls != null && imageUrls.isNotEmpty) 'imageUrl': imageUrls,
      });

      // 4. スレッドの commentCount 更新
      transaction.update(threadDocRef, {
        'commentCount': FieldValue.increment(1),
        'lastCommentTime': FieldValue.serverTimestamp(),
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
    required String writerId,
    required int maxCommentCount,
    required String limitType, // 'count' または 'time'
    DateTime? commentDeadline,
    String? label,
    String? clientIp, // IPアドレスを渡せるなら引数に
  }) async {
    // コレクション参照を取得
    final colRef = _firestore.collection('threads');
    String docRefId = '';
    // ユーザー情報を取得
    final userDocRef =
        writerId.isEmpty
            ? _firestore.collection('users').doc('NoID')
            : _firestore.collection('users').doc(writerId);

    await _firestore.runTransaction((transaction) async {
      // ユーザー情報取得
      final userSnap = await transaction.get(userDocRef);
      if (!userSnap.exists) {
        // **初回のスレ立て** -> 初期フィールドを作成
        final deviceUuid = await _getDeviceUuid();
        transaction.set(userDocRef, {
          'uuid': deviceUuid,
          'ip': clientIp ?? '',
          'postHistory': [],
          'threadNum': 1,
          'resNum': 0,
          'imageHistory': [],
        });
      } else {
        // **既存ユーザー** -> arrayUnion / increment で更新
        final userUpdates = <String, dynamic>{
          'threadNum': FieldValue.increment(1),
        };
        transaction.update(userDocRef, userUpdates);
      }
    });

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
      'label': label ?? '',
    });

    // ドキュメントのIDを取得して、ドキュメントに保存
    await docRef.set({'id': docRef.id}, SetOptions(merge: true));

    // 自動生成IDを取得
    docRefId = docRef.id;

    // 自動生成IDを取得
    return docRefId;
  }
}

/// デバイスのUUID取得（例として device_info_plus パッケージ使用）
Future<String> _getDeviceUuid() async {
  final deviceInfo = DeviceInfoPlugin();
  final info = await deviceInfo.androidInfo; // Androidの場合
  // iOSの場合は iOS用の処理に切り替えてください
  return info.id ?? Uuid().v4();
}
