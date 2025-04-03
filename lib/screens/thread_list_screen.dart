import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/thread_provider.dart';
import 'thread_detail_screen.dart';
import 'create_thread_screen.dart';

class ThreadListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(threadProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('スレッド一覧'),
        automaticallyImplyLeading: false, // ← これで「← ボタン」を非表示にする
      ),
      body:
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
                        Text(
                          '閲覧数: ${thread.viewCount} | 書き込み数: ${thread.commentCount}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          '作成日時: ${DateFormat('yy/MM/dd HH:mm:ss.SS').format(thread.createdAt)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    onTap: () {
                      // ビュー数を増やす
                      ref
                          .read(threadProvider.notifier)
                          .incrementViewCount(thread.title);

                      // スレッド詳細画面へ遷移
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  ThreadDetailScreen(threadTitle: thread.title),
                        ),
                      );
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // スレッド作成画面へ遷移
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateThreadScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  /// **日付フォーマット関数**
  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '不明';
    return '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}';
  }
}
