import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/thread_provider.dart';
import '../providers/user_id_provider.dart';
import 'base_screen.dart';

class CreateThreadScreen extends ConsumerStatefulWidget {
  const CreateThreadScreen({Key? key}) : super(key: key);

  @override
  _CreateThreadScreenState createState() => _CreateThreadScreenState();
}

class _CreateThreadScreenState extends ConsumerState<CreateThreadScreen> {
  final _titleController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userIdAsync = ref.watch(userIdProvider);

    return BaseScreen(
      // BaseScreen を適用
      child: Scaffold(
        appBar: AppBar(title: Text('スレッド作成')),
        body: userIdAsync.when(
          data: (userId) => _buildForm(context, userId),
          loading: () => Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('エラーが発生しました')),
        ),
      ),
    );
  }

  /// **フォームUI**
  Widget _buildForm(BuildContext context, String userId) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'スレッドタイトル'),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: '名前（任意）'),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'メールアドレス（任意）'),
          ),
          SizedBox(height: 8),
          TextField(
            controller: _contentController,
            decoration: InputDecoration(
              labelText: 'スレッドの最初の書き込み',
              hintText: '最初の書き込みを入力',
            ),
            maxLines: 3,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _createThread(context, userId),
            child: Text('スレッド作成'),
          ),
        ],
      ),
    );
  }

  /// **スレッド作成処理**
  void _createThread(BuildContext context, String userId) {
    final title = _titleController.text.trim();
    final name =
        _nameController.text.trim().isEmpty
            ? '名無しさん'
            : _nameController.text.trim();
    final email = _emailController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('タイトルと最初の書き込みは必須です')));
      return;
    }

    final threadNotifier = ref.read(threadProvider.notifier);
    final commentNotifier = ref.read(threadCommentsProvider(title).notifier);

    // スレッドを作成
    threadNotifier.addThread(title);

    // 最初の書き込み（レス番号1）
    commentNotifier.addComment(
      resNumber: 1,
      name: name,
      email: email,
      content: content,
      userId: userId,
      timestamp: DateFormat('yy/MM/dd HH:mm:ss.SS').format(DateTime.now()),
    );

    // 一覧画面に戻る
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
