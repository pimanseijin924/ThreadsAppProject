import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/providers/board_provider.dart';

class BoardListScreen extends ConsumerWidget {
  final String channelId;

  const BoardListScreen({Key? key, required this.channelId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardListAsync = ref.watch(boardListProvider(channelId));

    return Scaffold(
      appBar: AppBar(title: Text("板一覧")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: boardListAsync.when(
          data: (boardList) {
            return ListView.builder(
              itemCount: boardList.length,
              itemBuilder: (context, index) {
                final board = boardList[index];
                return ListTile(
                  title: Text(board.name, style: TextStyle(fontSize: 16)),
                  subtitle:
                      board.description != null
                          ? Text(
                            board.description!,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          )
                          : null,
                  onTap: () {
                    context.push('/threads/${board.id}');
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  trailing: Icon(Icons.chevron_right),
                );
              },
            );
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('エラーが発生しました: $error')),
        ),
      ),
    );
  }
}
