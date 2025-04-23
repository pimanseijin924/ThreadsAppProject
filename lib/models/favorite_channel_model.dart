class FavoriteChannel {
  final String channelId;
  int rating; // 1～5

  FavoriteChannel({required this.channelId, required this.rating});
  // toJson/fromJson を実装
}
