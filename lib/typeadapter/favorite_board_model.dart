import 'package:hive/hive.dart';

part 'favorite_board_model.g.dart';

@HiveType(typeId: 1)
class FavoriteBoard extends HiveObject {
  @HiveField(0)
  String boardId;
  @HiveField(1)
  int rating; // 1～5

  FavoriteBoard({required this.boardId, required this.rating});
}
