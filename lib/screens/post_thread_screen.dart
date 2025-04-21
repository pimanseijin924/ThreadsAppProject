import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/models/thread_model.dart';
import 'package:my_app/widgets/post_form.dart';
import 'package:my_app/providers/user_id_provider.dart';

class PostThreadScreen extends ConsumerStatefulWidget {
  final Thread thread;

  const PostThreadScreen({Key? key, required this.thread}) : super(key: key);

  @override
  PostThreadScreenState createState() => PostThreadScreenState();
}

class PostThreadScreenState extends ConsumerState<PostThreadScreen> {
  @override
  Widget build(BuildContext context) {
    final userIdFuture = ref.watch(userIdProvider);

    return Scaffold(
      appBar: AppBar(title: Text('書き込み')),
      body: userIdFuture.when(
        data:
            (userId) => PostForm(
              userId: userId,
              formType: 'response',
              thread: widget.thread,
            ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラーが発生しました: $e')),
      ),
    );
  }
}
