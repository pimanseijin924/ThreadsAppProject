import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// NGユーザーのIDのリストを管理するStateNotifier
class NgIdNotifier extends StateNotifier<Set<String>> {
  NgIdNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('ng_id') ?? [];
    state = list.toSet();
  }

  Future<void> add(String id) async {
    final newSet = {...state, id};
    state = newSet;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('ng_id', newSet.toList());
  }

  Future<void> remove(String id) async {
    final newSet = {...state}..remove(id);
    state = newSet;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('ng_id', newSet.toList());
  }
}

final ngIdProvider = StateNotifierProvider<NgIdNotifier, Set<String>>(
  (_) => NgIdNotifier(),
);
