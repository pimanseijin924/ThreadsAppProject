import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/board_model.dart';
import 'base_screen.dart'; // BaseScreenをインポート
import 'thread_list_screen.dart';

// boardListProviderをインポート
import '../providers/board_provider.dart';

class BoardListScreen extends ConsumerWidget {
  final String channelId;

  const BoardListScreen({Key? key, required this.channelId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Firestore から取得した boards を使用
    final boardListAsync = ref.watch(boardListProvider(channelId));

    return Scaffold(
      appBar: AppBar(title: Text("板一覧")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: boardListAsync.when(
          data: (boardList) {
            // boardList はFirestoreから取得したデータ
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
                    // タブを切り替えて、スレッド一覧画面に遷移
                    BaseScreen.pushThreadListTab(context, board.id);
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

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../models/board_model.dart';
// import 'base_screen.dart'; // BaseScreenをインポート
// import 'thread_list_screen.dart';

// class BoardListScreen extends ConsumerWidget {
//   final String channelId;

//   const BoardListScreen({Key? key, required this.channelId}) : super(key: key);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final boardList = [
//       Board(
//         id: '1',
//         name: '教育板',
//         description: '教育に関する情報を共有する板です。',
//         createdAt: DateTime.now(),
//       ),
//       Board(
//         id: '2',
//         name: '科学板',
//         description: '科学に関する情報を共有する板です。',
//         createdAt: DateTime.now(),
//       ),
//     ];

//     return Scaffold(
//       appBar: AppBar(title: Text("板一覧")),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: ListView.builder(
//           itemCount: boardList.length,
//           itemBuilder: (context, index) {
//             final board = boardList[index];
//             return ListTile(
//               title: Text(board.name, style: TextStyle(fontSize: 16)),
//               subtitle:
//                   board.description != null
//                       ? Text(
//                         board.description!,
//                         style: TextStyle(fontSize: 12, color: Colors.grey),
//                       )
//                       : null,
//               onTap: () {
//                 // タブを切り替えて、スレッド一覧画面に遷移
//                 BaseScreen.pushThreadListTab(context, board.id);
//               },
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               trailing: Icon(Icons.chevron_right),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
