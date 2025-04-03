import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/thread_provider.dart';
import '../providers/user_id_provider.dart';
import 'base_screen.dart';

class PostThreadScreen extends ConsumerStatefulWidget {
  final String threadTitle;

  PostThreadScreen({required this.threadTitle});

  @override
  _PostThreadScreenState createState() => _PostThreadScreenState();
}

class _PostThreadScreenState extends ConsumerState<PostThreadScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userIdFuture = ref.watch(userIdProvider);

    return BaseScreen(
      initialIndex: 0, // スレッド一覧のタブを維持
      child: Scaffold(
        appBar: AppBar(title: Text('書き込み')),
        body: userIdFuture.when(
          data: (userId) => _buildForm(context, ref, userId),
          loading: () => Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('エラーが発生しました: $e')),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, WidgetRef ref, String userId) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: '名前'),
          ),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'メールアドレス (任意)'),
          ),
          TextField(
            controller: _contentController,
            decoration: InputDecoration(labelText: '書き込み内容'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _postComment(context, ref, userId),
            child: Text('投稿'),
          ),
        ],
      ),
    );
  }

  void _postComment(BuildContext context, WidgetRef ref, String userId) {
    if (_contentController.text.isEmpty) return;

    final now = DateFormat('yy/MM/dd HH:mm:ss.SS').format(DateTime.now());
    final threadNotifier = ref.read(threadProvider.notifier);
    final commentNotifier = ref.read(
      threadCommentsProvider(widget.threadTitle).notifier,
    );
    final commentCount = threadNotifier.getCommentCount(widget.threadTitle) + 1;

    // 書き込みを追加
    commentNotifier.addComment(
      resNumber: commentCount,
      name: _nameController.text,
      email: _emailController.text,
      content: _contentController.text,
      userId: userId,
      timestamp: now,
    );

    // スレッドの書き込み数を更新
    threadNotifier.incrementCommentCount(widget.threadTitle);

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
