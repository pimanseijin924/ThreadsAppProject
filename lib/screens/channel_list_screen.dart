import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/providers/channel_provider.dart';

class ChannelListScreen extends ConsumerWidget {
  const ChannelListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelList = ref.watch(channelListProvider);

    return Scaffold(
      appBar: AppBar(title: Text("チャンネル一覧"), automaticallyImplyLeading: false),
      body: channelList.when(
        data: (channelList) {
          return ListView.builder(
            itemCount: channelList.length,
            itemBuilder: (context, index) {
              final channel = channelList[index];
              return ListTile(
                title: Text(channel.name, style: TextStyle(fontSize: 16)),
                subtitle:
                    channel.description != null
                        ? Text(
                          channel.description!,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )
                        : null,
                onTap: () {
                  context.push('/boards/${channel.id}');
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
    );
  }
}
