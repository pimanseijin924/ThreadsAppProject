import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final boardListProvider = StreamProvider.family<List<Board>, String>((
  ref,
  channelId,
) {
  return FirebaseFirestore.instance
      .collection('channelBoardRelations')
      .where('channelId', isEqualTo: channelId) // channelId に一致するリレーションを検索
      .snapshots()
      .asyncMap((snapshot) async {
        // リレーションの boardId を取得し、それに基づいて boards コレクションを検索
        final boardIds =
            snapshot.docs.map((doc) => doc['boardId'] as String).toList();

        // boardId のリストに基づいて boards コレクションを取得
        final boardSnapshots =
            await FirebaseFirestore.instance
                .collection('boards')
                .where(FieldPath.documentId, whereIn: boardIds)
                .get();

        // boardSnapshots から Board オブジェクトのリストを作成
        return boardSnapshots.docs
            .map((doc) => Board.fromFirestore(doc))
            .toList();
      });
});

class Board {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final int maxThreadCount;

  Board({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.maxThreadCount,
  });

  factory Board.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Board(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      maxThreadCount: data['maxThreadCount'] ?? 0,
    );
  }
}
