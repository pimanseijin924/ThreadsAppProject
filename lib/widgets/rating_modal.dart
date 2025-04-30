import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_app/providers/favorite_provider.dart';

Future<void> showRatingModal(
  BuildContext context,
  WidgetRef ref,
  String id,
  int currentRating,
  String type,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true, // 全画面的に操作を受け付ける
    enableDrag: false, // 下方向スワイプで閉じないように制御
    builder: (_) {
      return ProviderScope(
        child: Consumer(
          builder: (ctx, ref, setState) {
            final updateActions = <String, void Function(int)>{
              'channel':
                  (rating) => ref
                      .read(favProvider.notifier)
                      .updateFavChannel(id, rating),
              'board':
                  (rating) =>
                      ref.read(favProvider.notifier).updateFavBoard(id, rating),
              'thread':
                  (rating) => ref
                      .read(favProvider.notifier)
                      .updateFavThread(id, rating),
            };
            int rating = currentRating;
            return GestureDetector(
              child: Container(
                padding: EdgeInsets.all(16),
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("チャンネルを評価"),
                    SizedBox(height: 12),
                    // 星評価を表示
                    RatingBar.builder(
                      initialRating: currentRating.toDouble(),
                      minRating: 0,
                      maxRating: 5,
                      direction: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder:
                          (context, index) =>
                              Icon(Icons.star, color: Colors.amber),
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      onRatingUpdate: (r) {
                        final rating = r.toInt();
                        // マップから取り出してコール。キーが無ければ no-op
                        updateActions[type]?.call(rating);
                      },
                    ),
                    SizedBox(height: 8),
                    Text("左右にスワイプして評価を調整"),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
