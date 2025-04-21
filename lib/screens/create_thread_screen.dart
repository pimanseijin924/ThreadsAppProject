import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/widgets/post_form.dart';
import 'package:my_app/providers/user_id_provider.dart';

class CreateThreadScreen extends ConsumerStatefulWidget {
  final String boardId;

  const CreateThreadScreen({Key? key, required this.boardId}) : super(key: key);

  @override
  CreateThreadScreenState createState() => CreateThreadScreenState();
}

class CreateThreadScreenState extends ConsumerState<CreateThreadScreen> {
  @override
  Widget build(BuildContext context) {
    final userIdFuture = ref.watch(userIdProvider);

    return Scaffold(
      appBar: AppBar(title: Text('スレッド作成')),
      body: userIdFuture.when(
        data:
            (userId) => PostForm(
              userId: userId,
              formType: 'thread',
              boardId: widget.boardId,
            ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラーが発生しました: $e')),
      ),
    );
  }
}
