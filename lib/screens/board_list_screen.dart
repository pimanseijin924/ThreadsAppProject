import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/providers/board_provider.dart';
import 'package:my_app/providers/favorite_provider.dart';
import 'package:my_app/widgets/overlay_list_tile.dart';

class BoardListScreen extends ConsumerWidget {
  final String channelId;

  const BoardListScreen({Key? key, required this.channelId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardListAsync = ref.watch(boardListProvider(channelId));
    final favorites = ref.watch(favProvider);

    return Scaffold(
      appBar: AppBar(title: Text("板一覧")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: boardListAsync.when(
          data: (boardList) {
            // 1. お気に入り済みを先頭に、評価降順でソート :contentReference[oaicite:0]{index=0}
            final sorted = [
              ...boardList
                  .where((board) => (favorites[board.id] ?? 0) > 0)
                  .toList()
                ..sort((a, b) => favorites[b.id]!.compareTo(favorites[a.id]!)),
              ...boardList.where((board) => (favorites[board.id] ?? 0) == 0),
            ];
            return ListView.builder(
              itemCount: boardList.length,
              itemBuilder: (context, index) {
                final board = boardList[index];
                final rating = favorites[board.id] ?? 0;

                return ListTileComponent(
                  contentId: board.id,
                  contentName: board.name,
                  contentDescription: board.description ?? '',
                  type: 'board',
                );
                // return ListTile(
                //   title: Text(board.name, style: TextStyle(fontSize: 16)),
                //   subtitle:
                //       board.description != null
                //           ? Text(
                //             board.description!,
                //             style: TextStyle(fontSize: 12, color: Colors.grey),
                //           )
                //           : null,
                //   onTap: () {
                //     context.push('/threads/${board.id}');
                //   },
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   contentPadding: EdgeInsets.symmetric(
                //     horizontal: 16,
                //     vertical: 8,
                //   ),
                //   trailing: Icon(Icons.chevron_right),
                // );
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
