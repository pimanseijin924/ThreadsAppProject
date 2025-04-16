import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BaseShell extends StatelessWidget {
  final Widget child;
  const BaseShell({super.key, required this.child});

  int _indexFromLocation(String location) {
    if (location.startsWith('/threads')) return 1;
    if (location.startsWith('/thread')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.push('/channels');
              break;
            case 1:
              context.push('/threads/sampleBoardId');
              break;
            case 2:
              context.push('/thread/sampleThreadId');
              break;
            case 3:
              context.go('/settings');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'チャンネル'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'スレッド'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '詳細'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}
