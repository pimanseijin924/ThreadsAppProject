import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/models/favorite_channel_model.dart';

class FavoriteNotifier extends StateNotifier<Map<String, int>> {
  FavoriteNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final box = Hive.box<FavoriteChannel>('favorites');
    final map = {for (var fc in box.values) fc.channelId: fc.rating};
    state = map;
  }

  Future<void> update(String id, int rating) async {
    state = {...state, id: rating};
    final box = Hive.box<FavoriteChannel>('favorites');
    await box.put(id, FavoriteChannel(channelId: id, rating: rating));
  }
}

final favProvider = StateNotifierProvider<FavoriteNotifier, Map<String, int>>(
  (_) => FavoriteNotifier(),
);
