import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/models/channel_model.dart';
import '../providers/channel_provider.dart';
import 'base_screen.dart';
import 'board_list_screen.dart';
import '../models/channel_model.dart';

class ChannelListScreen extends ConsumerWidget {
  const ChannelListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelList = ref.watch(channelListProvider);

    final String channelId = '1'; // 例としてチャンネルIDを指定
    // final channelList = [
    //   Channel(
    //     id: '1',
    //     name: '教育',
    //     description: '教育に関するチャンネル',
    //     createdAt: DateTime.now(),
    //   ),
    //   Channel(
    //     id: '2',
    //     name: '科学',
    //     description: '科学に関するチャンネル',
    //     createdAt: DateTime.now(),
    //   ),
    // ];

    return Scaffold(
      appBar: AppBar(
        title: Text("チャンネル一覧"),
        automaticallyImplyLeading: false, // ← これで「← ボタン」を非表示にする
      ),
      body: channelList.when(
        data: (channelList) {
          return ListView.builder(
            itemCount: channelList.length,
            itemBuilder: (context, index) {
              final channel = channelList[index];
              return ListTile(
                //leading: Icon(Icons.category, color: Colors.blueAccent),
                title: Text(channel.name, style: TextStyle(fontSize: 16)),
                subtitle:
                    channel.description != null
                        ? Text(
                          channel.description!,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )
                        : null,
                onTap: () {
                  // BaseScreen 内のネストされた Navigator に対して BoardListScreen を push
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BoardListScreen(channelId: channel.id),
                    ),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                //tileColor: Colors.white,
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
    );

    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text("チャンネル一覧"),
    //     automaticallyImplyLeading: false, // ← これで「← ボタン」を非表示にする
    //   ),
    //   body: ListView.builder(
    //     itemCount: channelList.length,
    //     itemBuilder: (context, index) {
    //       final channel = channelList[index];
    //       return ListTile(
    //         //leading: Icon(Icons.category, color: Colors.blueAccent),
    //         title: Text(channel.name, style: TextStyle(fontSize: 16)),
    //         subtitle:
    //             channel.description != null
    //                 ? Text(
    //                   channel.description!,
    //                   style: TextStyle(fontSize: 12, color: Colors.grey),
    //                 )
    //                 : null,
    //         onTap: () {
    //           // BaseScreen 内のネストされた Navigator に対して BoardListScreen を push
    //           Navigator.of(context).push(
    //             MaterialPageRoute(
    //               builder: (_) => BoardListScreen(channelId: channel.id),
    //             ),
    //           );
    //         },
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(12),
    //         ),
    //         //tileColor: Colors.white,
    //         contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    //         trailing: Icon(Icons.chevron_right),
    //       );
    //     },
    //   ),
    // );
  }
}
