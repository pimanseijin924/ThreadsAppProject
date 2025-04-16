import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../models/thread_model.dart';
import '../providers/thread_provider.dart';
import '../widgets/comment_image_grid.dart';
import 'post_thread_screen.dart';

class ThreadDetailScreen extends ConsumerWidget {
  final String boardId;
  final String threadId;
  final bool showBackToTab; // スレッド一覧画面に戻るボタンを表示するかどうか

  const ThreadDetailScreen({
    Key? key,
    required this.boardId,
    required this.threadId,
    required this.showBackToTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadAsync = ref.watch(threadByIdProvider(threadId));
    final commentsAsync = ref.watch(threadCommentsProvider(threadId));

    return threadAsync.when(
      data: (thread) {
        final commentsAsync = ref.watch(threadCommentsProvider(threadId));

        return Scaffold(
          appBar: AppBar(
            // leading:
            //     showBackToTab
            //         ? IconButton(
            //           icon: Icon(Icons.arrow_back),
            //           onPressed: () {
            //             context.push('/threads/$boardId');
            //           },
            //         )
            //         : null,
            title: Text(thread.title.isNotEmpty ? thread.title : 'スレッド'),
          ),
          body: commentsAsync.when(
            data:
                (comments) => Column(
                  children: [
                    // スレッド情報
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            thread.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
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
                    // コメントリスト
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '${comment.resNumber} ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              comment.name.isNotEmpty
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
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                ),
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
                                        Text(
                                          'ID: ${comment.userId}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(comment.content),
                                        if (comment.imageUrl != null &&
                                            comment.imageUrl!.isNotEmpty)
                                          CommentImageGrid(
                                            imageUrls: comment.imageUrl!,
                                          ),
                                        Divider(),
                                      ],
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
            loading: () => Center(child: CircularProgressIndicator()),
            error:
                (error, stack) =>
                    Center(child: Text('コメントの読み込み中にエラーが発生しました: $error')),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.push('/thread/post', extra: thread);
            },
            child: Icon(Icons.edit),
          ),
        );
      },
      loading:
          () => Scaffold(
            appBar: AppBar(title: Text('読み込み中...')),
            body: Center(child: CircularProgressIndicator()),
          ),
      error:
          (error, stack) => Scaffold(
            appBar: AppBar(title: Text('エラー')),
            body: Center(child: Text('スレッドの読み込み中にエラーが発生しました: $error')),
          ),
    );
  }

  Widget _buildThreadInfo(Thread thread) {
    return Padding(
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
    );
  }
}
