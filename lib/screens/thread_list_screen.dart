import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/thread_provider.dart';
import 'base_screen.dart';
import 'create_thread_screen.dart';

class ThreadListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(threadListProvider);
    final threadViewCounts = ref.watch(threadViewCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('スレッド一覧'),
        automaticallyImplyLeading: false, // 戻るボタンを表示しない
      ),
      body: ListView.builder(
        itemCount: threads.length,
        itemBuilder: (context, index) {
          final threadTitle = threads[index];
          final viewCount = threadViewCounts[threadTitle] ?? 0;

          return ListTile(
            title: Text('$threadTitle ($viewCount views)'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          BaseScreen(initialIndex: 1, threadTitle: threadTitle),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateThreadScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
