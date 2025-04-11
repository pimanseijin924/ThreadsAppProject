// models/board.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Board {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;

  Board({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory Board.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Board(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
