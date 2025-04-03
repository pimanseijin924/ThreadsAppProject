import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/thread_provider.dart';
import '../providers/user_id_provider.dart';
//import '../providers/comment_provider.dart';
import 'thread_detail_screen.dart';

class CreateThreadScreen extends ConsumerStatefulWidget {
  @override
  _CreateThreadScreenState createState() => _CreateThreadScreenState();
}

class _CreateThreadScreenState extends ConsumerState<CreateThreadScreen> {
  final _titleController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userIdAsync = ref.watch(userIdProvider);

    return userIdAsync.when(
      data:
          (userId) => Scaffold(
            appBar: AppBar(title: Text('スレッドを作成')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'スレッドタイトル'),
                  ),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: '名前 (省略可, デフォルト: ななしさん)',
                    ),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'メールアドレス (省略可)'),
                  ),
                  TextField(
                    controller: _contentController,
                    decoration: InputDecoration(labelText: '書き込み'),
                    maxLines: 5,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_titleController.text.isEmpty ||
                            _contentController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('タイトルと書き込みは必須です')),
                          );
                          return;
                        }

                        final threadTitle = _titleController.text;
                        final name =
                            _nameController.text.isNotEmpty
                                ? _nameController.text
                                : 'ななしさん';
                        final email = _emailController.text;
                        final content = _contentController.text;

                        // スレッドを追加
                        ref
                            .read(threadListProvider.notifier)
                            .addThread(threadTitle);

                        // レス番号 1 の書き込みを追加
                        ref
                            .read(threadCommentsProvider(threadTitle).notifier)
                            .addComment(
                              resNumber: 1,
                              name: name,
                              email: email,
                              content: content,
                              userId: userId,
                              timestamp: getFormattedDate(), // 日本時間の時刻を取得
                            );

                        // スレッド詳細画面に遷移
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ThreadDetailScreen(
                                  threadTitle: threadTitle,
                                ),
                          ),
                        );
                      },
                      child: Text('作成'),
                    ),
                  ),
                ],
              ),
            ),
          ),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (err, stack) {
        print("Error loading User ID: $err"); //エラーログ
        return Center(child: Text('ユーザーIDの取得に失敗しました。'));
      },
    );
  }
}

// ユーザーIDを生成する関数（サンプル）
String generateUserId() {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+*-/!';
  return List.generate(
    13,
    (index) =>
        chars[(DateTime.now().millisecondsSinceEpoch + index) % chars.length],
  ).join();
}

// 日本時間のフォーマットされた日時を取得
String getFormattedDate() {
  final now = DateTime.now().toUtc().add(Duration(hours: 9)); // 日本時間に変換
  return '${now.year % 100}/${now.month}/${now.day} ${now.hour}:${now.minute}:${now.second}.${now.millisecond ~/ 10}';
}
