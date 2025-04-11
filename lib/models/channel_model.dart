// models/channel.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Channel {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;

  Channel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });

  factory Channel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Channel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
