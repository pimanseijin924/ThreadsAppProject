import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/thread_model.dart';
import '../providers/thread_provider.dart';
import '../widgets/comment_image_grid.dart';
import 'base_screen.dart';
import 'post_thread_screen.dart';

class ThreadDetailScreen extends ConsumerWidget {
  final String threadTitle;
  final bool showBackToTab;

  const ThreadDetailScreen({
    Key? key,
    required this.threadTitle,
    this.showBackToTab = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thread = ref
        .watch(threadProvider)
        .firstWhere(
          (t) => t.title == threadTitle,
          orElse: () => Thread(title: '不明'),
        );
    final comments = ref.watch(threadCommentsProvider(threadTitle));

    return Scaffold(
      appBar: AppBar(
        leading:
            showBackToTab
                ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    BaseScreen.setTab(context, 1); // スレッド一覧画面に戻る
                  },
                )
                : null,
        title: Text(thread.title),
      ),
      body: Column(
        children: [
          // スレッド情報
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  thread.title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  '閲覧数: ${thread.viewCount} | 書き込み数: ${thread.commentCount}',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  '作成日時: ${DateFormat('yy/MM/dd HH:mm:ss.SS').format(thread.createdAt)}',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Divider(),

          // 書き込みリスト
          Expanded(
            child:
                comments.isEmpty
                    ? Center(child: Text('まだ書き込みがありません'))
                    : ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1段目（レス番号、名前、メール、時間）
                              Row(
                                children: [
                                  Text(
                                    '${comment.resNumber} ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    comment.name.isNotEmpty == true
                                        ? comment.name
                                        : 'ななしさん',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (comment.email != null &&
                                      comment.email.isNotEmpty)
                                    Text(
                                      ' <${comment.email}>',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  Spacer(),
                                  Text(
                                    DateFormat(
                                      'yy/MM/dd HH:mm:ss.SS',
                                    ).format(comment.sendTime),
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              // 2段目（ユーザーID）
                              Text(
                                'ID: ${comment.userId}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              // 3段目（コメント本文）
                              Text(comment.content),
                              // 画像があれば表示
                              if (comment.imageUrl != null &&
                                  comment.imageUrl!.isNotEmpty)
                                CommentImageGrid(imageUrls: comment.imageUrl!),
                              Divider(),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // PostThreadScreen を同じ Navigator 上で push
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PostThreadScreen(threadTitle: threadTitle),
            ),
          );
        },
        child: Icon(Icons.edit),
      ),
    );
  }

  /// **日付フォーマット関数**
  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '不明';
    return '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}';
  }
}
