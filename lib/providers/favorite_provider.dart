import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/typeadapter/favorite_channel_model.dart';
import 'package:my_app/typeadapter/favorite_board_model.dart';
import 'package:my_app/typeadapter/favorite_thread_model.dart';

class FavoriteNotifier extends StateNotifier<Map<String, int>> {
  FavoriteNotifier() : super({}) {
    _loadFavChannels();
    _loadFavBoards();
    _loadFavThreads();
  }

  Future<void> _loadFavChannels() async {
    final box = Hive.box<FavoriteChannel>('favorite_channels');
    final map = {for (var fc in box.values) fc.channelId: fc.rating};
    state = map;
  }

  Future<void> _loadFavBoards() async {
    final box = Hive.box<FavoriteBoard>('favorite_boards');
    final map = {for (var fc in box.values) fc.boardId: fc.rating};
    state = map;
  }

  Future<void> _loadFavThreads() async {
    final box = Hive.box<FavoriteThread>('favorite_threads');
    final map = {for (var fc in box.values) fc.threadId: fc.rating};
    state = map;
  }

  Future<void> updateFavChannel(String id, int rating) async {
    state = {...state, id: rating};
    final box = Hive.box<FavoriteChannel>('favorite_channels');
    await box.put(id, FavoriteChannel(channelId: id, rating: rating));
  }

  Future<void> updateFavBoard(String id, int rating) async {
    state = {...state, id: rating};
    final box = Hive.box<FavoriteBoard>('favorite_boards');
    await box.put(id, FavoriteBoard(boardId: id, rating: rating));
  }

  Future<void> updateFavThread(String id, int rating) async {
    state = {...state, id: rating};
    final box = Hive.box<FavoriteThread>('favorite_threads');
    await box.put(id, FavoriteThread(threadId: id, rating: rating));
  }
}

final favProvider = StateNotifierProvider<FavoriteNotifier, Map<String, int>>(
  (_) => FavoriteNotifier(),
);
