import 'package:hive/hive.dart';

part 'favorite_channel_model.g.dart';

@HiveType(typeId: 0)
class FavoriteChannel extends HiveObject {
  @HiveField(0)
  String channelId;
  @HiveField(1)
  int rating; // 1～5

  FavoriteChannel({required this.channelId, required this.rating});
}
