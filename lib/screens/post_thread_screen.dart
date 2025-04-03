import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/thread_provider.dart';
import '../providers/user_id_provider.dart';

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
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getUserId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final userId = snapshot.data!; // 取得したユーザーID

        final comments = ref.watch(
          threadCommentsProvider(widget.threadTitle),
        ); // ここでコメントリストを取得

        return Scaffold(
          appBar: AppBar(title: Text('書き込み')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      if (_contentController.text.isEmpty) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('書き込みは必須です')));
                        return;
                      }

                      final name =
                          _nameController.text.isNotEmpty
                              ? _nameController.text
                              : 'ななしさん';
                      final email = _emailController.text;
                      final content = _contentController.text;
                      final resNumber = comments.length + 1; // ここでレス番号を計算

                      ref
                          .read(
                            threadCommentsProvider(widget.threadTitle).notifier,
                          )
                          .addComment(
                            name: name,
                            email: email,
                            content: content,
                            userId: userId,
                            timestamp: getFormattedDate(),
                            resNumber: resNumber,
                          );

                      Navigator.pop(context);
                    },
                    child: Text('書き込む'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 日本時間のフォーマットされた日時を取得
  String getFormattedDate() {
    final now = DateTime.now().toUtc().add(Duration(hours: 9));
    return '${now.year % 100}/${now.month}/${now.day} ${now.hour}:${now.minute}:${now.second}.${now.millisecond ~/ 10}';
  }
}
