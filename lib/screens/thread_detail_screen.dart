import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/screens/post_thread_screen.dart';
import '../providers/thread_provider.dart';

class ThreadDetailScreen extends ConsumerWidget {
  final String threadTitle;

  ThreadDetailScreen({required this.threadTitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comments = ref.watch(threadCommentsProvider(threadTitle));

    return Scaffold(
      appBar: AppBar(
        title: Text(threadTitle),
        automaticallyImplyLeading: true, // 👈 これで「← ボタン」を表示
      ),
      body: ListView.builder(
        itemCount: comments.length,
        itemBuilder: (context, index) {
          final comment = comments[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1段目（レス番号、名前、メール、時間）
                Row(
                  children: [
                    Text(
                      '${comment.resNumber} ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      comment.name ?? 'ななしさん',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (comment.email != null && comment.email!.isNotEmpty)
                      Text(
                        ' <${comment.email}>',
                        style: TextStyle(color: Colors.blue),
                      ),
                    Spacer(),
                    Text(comment.timestamp, style: TextStyle(fontSize: 12)),
                  ],
                ),
                // 2段目（ユーザーID）
                Text(
                  'ID: ${comment.userId}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                // 3段目（コメント本文）
                Text(comment.content),
                Divider(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostThreadScreen(threadTitle: threadTitle),
            ),
          );
        },
        child: Icon(Icons.edit),
      ),
    );
  }
}
