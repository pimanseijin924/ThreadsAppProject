import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_app/providers/channel_provider.dart';
import 'package:my_app/providers/favorite_provider.dart';
import 'package:my_app/widgets/overlay_list_tile.dart';

class ChannelListScreen extends ConsumerWidget {
  const ChannelListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelList = ref.watch(channelListProvider);
    final favorites = ref.watch(favProvider);

    return Scaffold(
      appBar: AppBar(title: Text("チャンネル一覧"), automaticallyImplyLeading: false),
      body: channelList.when(
        data: (channels) {
          // 1. お気に入り済みを先頭に、評価降順でソート :contentReference[oaicite:0]{index=0}
          final sorted = [
            ...channels.where((ch) => (favorites[ch.id] ?? 0) > 0).toList()
              ..sort((a, b) => favorites[b.id]!.compareTo(favorites[a.id]!)),
            ...channels.where((ch) => (favorites[ch.id] ?? 0) == 0),
          ];

          return ListView.builder(
            itemCount: sorted.length,
            itemBuilder: (context, i) {
              final ch = sorted[i];
              final rating = favorites[ch.id] ?? 0;

              return ListTileComponent(
                contentId: ch.id,
                contentName: ch.name,
                contentDescription: ch.description ?? '',
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
      ),
    );
  }

  Future<void> _showRatingModal(
    BuildContext context,
    WidgetRef ref,
    String channelId,
    int currentRating,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // 全画面的に操作を受け付ける :contentReference[oaicite:5]{index=5}
      enableDrag:
          false, // 下方向スワイプで閉じないように制御 :contentReference[oaicite:6]{index=6}
      builder: (_) {
        double startDx = 0;
        return StatefulBuilder(
          builder: (ctx, setState) {
            int rating = currentRating;
            return GestureDetector(
              // ドラッグ開始時に始点を記録 :contentReference[oaicite:7]{index=7}
              onHorizontalDragStart: (details) {
                startDx = details.globalPosition.dx;
              },
              // ドラッグ中の移動量で評価を計算・更新 :contentReference[oaicite:8]{index=8}
              onHorizontalDragUpdate: (details) {
                final dx = details.globalPosition.dx - startDx;
                final newRating =
                    (dx / MediaQuery.of(context).size.width * 5)
                        .clamp(1, 5)
                        .round();
                if (newRating != rating) {
                  setState(() => rating = newRating);
                  ref.read(favProvider.notifier).update(channelId, newRating);
                }
              },
              onLongPressMoveUpdate: (details) {
                final dx = details.globalPosition.dx - startDx;
                final newRating =
                    (dx / MediaQuery.of(context).size.width * 5)
                        .clamp(1, 5)
                        .round();
                if (newRating != rating) {
                  setState(() => rating = newRating);
                  ref.read(favProvider.notifier).update(channelId, newRating);
                }
              },
              child: Container(
                padding: EdgeInsets.all(16),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("チャンネルを評価"),
                    SizedBox(height: 12),
                    // 星評価を表示 :contentReference[oaicite:9]{index=9}
                    RatingBar.builder(
                      initialRating: currentRating.toDouble(),
                      minRating: 1,
                      direction: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder:
                          (context, index) =>
                              Icon(Icons.star, color: Colors.amber),
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      onRatingUpdate:
                          (r) => ref
                              .read(favProvider.notifier)
                              .update(channelId, r.toInt()),
                    ),
                    SizedBox(height: 8),
                    Text("左右にスワイプして評価を調整"),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _borderColor(int rating) {
    switch (rating) {
      case 5:
        return Colors.red;
      case 4:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 2:
        return Colors.green;
      case 1:
        return Colors.blue;
      default:
        return Colors.transparent;
    }
  }
}
