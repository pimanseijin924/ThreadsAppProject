class Comment {
  final int resNumber; // 通番（レス番号）
  final String name;
  final String email;
  final String content;
  final String userId;
  final String timestamp;

  Comment({
    required this.resNumber,
    required this.name,
    required this.email,
    required this.content,
    required this.userId,
    required this.timestamp,
  });
}
