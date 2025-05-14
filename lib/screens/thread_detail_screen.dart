import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/models/thread_model.dart';
import 'package:my_app/models/comment_model.dart';
import 'package:my_app/providers/thread_provider.dart';
import 'package:my_app/providers/ng_provider.dart';
import 'package:my_app/widgets/comment_image_grid.dart';

class ThreadDetailScreen extends ConsumerWidget {
  final String boardId;
  final String threadId;
  final bool showBackToTab; // スレッド一覧画面に戻るボタンを表示するかどうか
  OverlayEntry? _idOverlay;

  ThreadDetailScreen({
    Key? key,
    required this.boardId,
    required this.threadId,
    required this.showBackToTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadAsync = ref.watch(threadByIdProvider(threadId));

    // 画面表示時に直近閲覧板を更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(lastThreadProvider.notifier)
          .setLastThread(boardId: boardId, threadId: threadId);
    });

    return threadAsync.when(
      data: (thread) {
        final commentsAsync = ref.watch(threadCommentsProvider(threadId));

        return Scaffold(
          appBar: AppBar(
            title: Text(thread.title.isNotEmpty ? thread.title : '不明なスレッド'),
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
                                  final writerId = comment.userId;

                                  // NGリストを読み込んで、該当IDならここでスキップ
                                  final ngId = ref.watch(ngIdProvider);
                                  if (ngId.contains(writerId))
                                    return SizedBox.shrink();
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
                                                  : comment.userId == 'official'
                                                  ? '運営'
                                                  : 'ななしさん',
                                              style:
                                                  comment.userId == 'official'
                                                      ? TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.red,
                                                      )
                                                      : TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
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
                                        GestureDetector(
                                          onTap:
                                              () => _showIdOverlay(
                                                context,
                                                ref,
                                                writerId,
                                                comments,
                                              ),
                                          onLongPress:
                                              () => _showNgModal(
                                                context,
                                                ref,
                                                writerId,
                                              ),
                                          child: Text(
                                            'ID: ${comment.userId}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
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

  // 指定IDのコメント一覧をオーバーレイで表示
  void _showIdOverlay(
    BuildContext context,
    WidgetRef ref,
    String id,
    List<Comment> comments,
  ) {
    _removeIdOverlay();
    final filtered = comments.where((comment) => comment.userId == id).toList();

    _idOverlay = OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeIdOverlay,
                child: Container(color: Colors.transparent),
              ),
            ),
            Center(
              child: Container(
                width: 300,
                height: 400,
                padding: EdgeInsets.all(8),
                color: Colors.white,
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final comment = filtered[index];
                    final writerId = comment.userId;

                    // NGリストを読み込んで、該当IDならここでスキップ
                    final ngId = ref.watch(ngIdProvider);
                    if (ngId.contains(writerId)) return SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${comment.resNumber} ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                comment.name.isNotEmpty
                                    ? comment.name
                                    : 'ななしさん',
                                style: TextStyle(fontWeight: FontWeight.bold),
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
                          GestureDetector(
                            onTap:
                                () => _showIdOverlay(
                                  context,
                                  ref,
                                  writerId,
                                  comments,
                                ),
                            onLongPress:
                                () => _showNgModal(context, ref, writerId),
                            child: Text(
                              'ID: ${comment.userId}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Text(comment.content),
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
            ),
          ],
        );
      },
    );
    Overlay.of(context)!.insert(_idOverlay!);
  }

  void _removeIdOverlay() {
    _idOverlay?.remove();
    _idOverlay = null;
  }

  void _showNgModal(BuildContext context, WidgetRef ref, String id) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: Text('Id: $id')),
              ListTile(
                leading: Icon(Icons.block),
                title: Text('このIDをNGに登録'),
                onTap: () {
                  ref.read(ngIdProvider.notifier).add(id);
                  context.pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('キャンセル'),
                onTap: () => context.pop(),
              ),
            ],
          ),
        );
      },
    );
  }
}
