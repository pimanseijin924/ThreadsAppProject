import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'thread_list_screen.dart';
import '../screens/setting_screen.dart';
import 'thread_detail_screen.dart';

class BaseScreen extends ConsumerStatefulWidget {
  final int initialIndex; // 初期表示のインデックス
  final String? threadTitle; // スレッド詳細のタイトル（スレッド詳細画面用）

  BaseScreen({this.initialIndex = 0, this.threadTitle});

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends ConsumerState<BaseScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      ThreadListScreen(),
      widget.threadTitle != null
          ? ThreadDetailScreen(threadTitle: widget.threadTitle!)
          : Container(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'スレッド一覧'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'スレッド詳細'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}
