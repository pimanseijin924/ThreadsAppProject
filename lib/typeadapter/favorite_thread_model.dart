import 'package:hive/hive.dart';

part 'favorite_thread_model.g.dart';

@HiveType(typeId: 2)
class FavoriteThread extends HiveObject {
  @HiveField(0)
  String threadId;
  @HiveField(1)
  int rating; // 1～5

  FavoriteThread({required this.threadId, required this.rating});
}
