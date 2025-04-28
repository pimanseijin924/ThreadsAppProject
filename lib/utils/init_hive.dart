import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_app/typeadapter/favorite_board_model.dart';
import 'package:my_app/typeadapter/favorite_channel_model.dart';
import 'package:my_app/typeadapter/favorite_thread_model.dart';

class UtilsHive {
  static Future<void> initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(FavoriteChannelAdapter());
    Hive.registerAdapter(FavoriteBoardAdapter());
    Hive.registerAdapter(FavoriteThreadAdapter());
    await Hive.openBox<FavoriteChannel>('favorite_channels');
    await Hive.openBox<FavoriteBoard>('favorite_boards');
    await Hive.openBox<FavoriteThread>('favorite_threads');
  }
}
