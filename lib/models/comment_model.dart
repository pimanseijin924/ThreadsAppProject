import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final int resNumber;
  final String name;
  final String email;
  final String content;
  final String userId;
  final DateTime sendTime;
  final List<String>? imageUrl; // 画像URL
  final List<String>? imagePath; // 画像パス（ローカル保存用）

  Comment({
    required this.resNumber,
    required this.name,
    required this.email,
    required this.content,
    required this.userId,
    required this.sendTime,
    this.imageUrl,
    this.imagePath,
  });

  factory Comment.fromFireStore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      resNumber: data['resNumber'] ?? 0,
      name: data['writerName'] ?? '',
      email: data['writerEmail'] ?? '',
      content: data['content'] ?? '',
      userId: data['writerId'] ?? '',
      sendTime: data['sendTime'] ?? DateTime.now(),
      imageUrl:
          data['imageUrl'] != null ? List<String>.from(data['imageUrl']) : null,
      imagePath: data['imagePath'],
    );
  }
}
