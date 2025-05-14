import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/widgets/post_form.dart';
import 'package:my_app/providers/user_id_provider.dart';

class CreateThreadScreenDev extends ConsumerStatefulWidget {
  final String boardId;

  const CreateThreadScreenDev({Key? key, required this.boardId})
    : super(key: key);

  @override
  CreateThreadScreenState createState() => CreateThreadScreenState();
}

class CreateThreadScreenState extends ConsumerState<CreateThreadScreenDev> {
  @override
  Widget build(BuildContext context) {
    final userIdFuture = ref.watch(userIdProvider);

    return Scaffold(
      appBar: AppBar(title: Text('スレッド作成(開発者モード)')),
      body: userIdFuture.when(
        data:
            (userId) => PostForm(
              userId: userId,
              formType: 'thread',
              boardId: widget.boardId,
              isDevelopper: true,
            ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラーが発生しました: $e')),
      ),
    );
  }
}
