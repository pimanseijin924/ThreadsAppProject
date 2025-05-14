import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/models/thread_model.dart';
import 'package:my_app/widgets/post_form.dart';
import 'package:my_app/providers/user_id_provider.dart';

class PostThreadScreenDev extends ConsumerStatefulWidget {
  final Thread thread;

  const PostThreadScreenDev({Key? key, required this.thread}) : super(key: key);

  @override
  PostThreadScreenDevState createState() => PostThreadScreenDevState();
}

class PostThreadScreenDevState extends ConsumerState<PostThreadScreenDev> {
  @override
  Widget build(BuildContext context) {
    final userIdFuture = ref.watch(userIdProvider);

    return Scaffold(
      appBar: AppBar(title: Text('書き込み(開発者モード)')),
      body: userIdFuture.when(
        data:
            (userId) => PostForm(
              userId: userId,
              formType: 'response',
              thread: widget.thread,
              isDevelopper: true,
            ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラーが発生しました: $e')),
      ),
    );
  }
}
