import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/providers/thread_provider.dart';
import 'package:my_app/providers/favorite_provider.dart';
import 'package:my_app/widgets/overlay_list_tile.dart';

class ThreadListScreen extends ConsumerWidget {
  final String boardId;
  final bool showBackToTab0;

  const ThreadListScreen({
    Key? key,
    required this.boardId,
    this.showBackToTab0 = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadListAsync = ref.watch(boardThreadsProvider(boardId));
    final favorites = ref.watch(favProvider);

    // 画面表示時に直近閲覧板を更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lastBoardProvider.notifier).setBoardId(boardId);
    });

    return Scaffold(
      appBar: AppBar(title: Text('スレッド一覧')),
      body: threadListAsync.when(
        data: (threads) {
          // お気に入り済みを先頭に、評価降順でソート
          final sorted = [
            ...threads
                .where((thread) => (favorites[thread.id] ?? 0) > 0)
                .toList()
              ..sort((a, b) => favorites[b.id]!.compareTo(favorites[a.id]!)),
            ...threads.where((thread) => (favorites[thread.id] ?? 0) == 0),
          ];
          return threads.isEmpty
              ? Center(child: Text('スレッドがありません'))
              : ListView.builder(
                itemCount: sorted.length,
                itemBuilder: (context, index) {
                  final thread = sorted[index];
                  final rating = favorites[thread.id] ?? 0;

                  return ListTileComponent(
                    contentId: thread.id,
                    contentName: thread.title,
                    contentDescription: '',
                    type: 'thread',
                    boardId: boardId,
                    threadId: thread.id,
                    thread: thread,
                  );

                  // return ListTile(
                  //   title: Text(
                  //     thread.title,
                  //     style: TextStyle(fontWeight: FontWeight.bold),
                  //   ),
                  //   subtitle: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       SizedBox(height: 4),
                  //       Row(
                  //         children: [
                  //           Text(
                  //             '閲覧数: ${thread.viewCount}',
                  //             style: TextStyle(
                  //               fontSize: 12,
                  //               color: Colors.grey,
                  //             ),
                  //           ),
                  //           SizedBox(width: 16),
                  //           Text(
                  //             '書き込み数: ${thread.commentCount}',
                  //             style: TextStyle(
                  //               fontSize: 12,
                  //               color: Colors.grey,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       if (thread.createdAt != null)
                  //         Text(
                  //           '作成日時: ${DateFormat('yy/MM/dd HH:mm:ss.SS').format(thread.createdAt)}',
                  //           style: TextStyle(fontSize: 12, color: Colors.grey),
                  //         ),
                  //     ],
                  //   ),
                  //   onTap: () {
                  //     context.push('/thread/$boardId/${thread.id}');
                  //     ref.read(incrementThreadViewCountProvider(thread.id));
                  //   },
                  // );
                },
              );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('エラーが発生しました: $e')),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/threads_create/${boardId}');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
