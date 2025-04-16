import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/thread_provider.dart';

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

    return Scaffold(
      appBar: AppBar(
        // leading:
        //     showBackToTab0
        //         ? IconButton(
        //           icon: Icon(Icons.arrow_back),
        //           onPressed: () {
        //             context.go('/channels');
        //           },
        //         )
        //         : null,
        title: Text('スレッド一覧'),
      ),
      body: threadListAsync.when(
        data:
            (threads) =>
                threads.isEmpty
                    ? Center(child: Text('スレッドがありません'))
                    : ListView.builder(
                      itemCount: threads.length,
                      itemBuilder: (context, index) {
                        final thread = threads[index];
                        return ListTile(
                          title: Text(
                            thread.title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '閲覧数: ${thread.viewCount}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    '書き込み数: ${thread.commentCount}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              if (thread.createdAt != null)
                                Text(
                                  '作成日時: ${DateFormat('yy/MM/dd HH:mm:ss.SS').format(thread.createdAt)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                          onTap: () {
                            context.push('/thread/$boardId/${thread.id}');
                            ref.read(
                              incrementThreadViewCountProvider(thread.id),
                            );
                          },
                        );
                      },
                    ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('エラーが発生しました: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/boards/$boardId/create-thread');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
