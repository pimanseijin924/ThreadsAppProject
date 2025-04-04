class Comment {
  final int resNumber; // 通番（レス番号）
  final String name;
  final String email;
  final String content;
  final String userId;
  final String timestamp;
  final String imageUrl; // 画像URL
  final String? imagePath; // 画像パス（ローカル保存用）

  Comment({
    required this.resNumber,
    required this.name,
    required this.email,
    required this.content,
    required this.userId,
    required this.timestamp,
    required this.imageUrl,
    this.imagePath,
  });
}
