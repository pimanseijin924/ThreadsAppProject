import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/providers/thread_provider.dart';

class BaseShell extends ConsumerWidget {
  final Widget child;
  const BaseShell({super.key, required this.child});

  int _indexFromLocation(String location) {
    if (location.startsWith('/threads')) return 1;
    if (location.startsWith('/thread')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);
    // Provider から直近閲覧板を取得
    final lastBoardId = ref.watch(lastBoardProvider);
    // Provider から直近閲覧スレッドを取得
    final lastThread = ref.watch(lastThreadProvider);

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
              // 直近板ID があればそこへ、なければデフォルト板へ遷移
              // デフォルト板は運営チャンネル玄関板
              final targetBoardId = lastBoardId ?? '0001';
              context.push('/threads/$targetBoardId');
              break;
            case 2:
              // 直近に見たスレッドがあればそこへ、なければデフォルトスレッドへ遷移
              // デフォルトスレッドは玄関板初めての方向けスレッド
              final targetBoardId = lastThread?.boardId ?? '0001';
              final targetThreadId = lastThread?.threadId ?? 'default01';
              context.push('/thread/$targetBoardId/$targetThreadId');
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
