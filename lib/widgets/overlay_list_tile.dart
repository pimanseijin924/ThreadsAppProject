import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_app/constants/Colors.dart';
import 'package:my_app/providers/favorite_provider.dart';
import 'package:my_app/widgets/rating_modal.dart';

class ListTileComponent extends ConsumerStatefulWidget {
  final String contentId;
  final String contentName;
  final String contentDescription;

  ListTileComponent({
    Key? key,
    required this.contentId,
    required this.contentName,
    required this.contentDescription,
  }) : super(key: key);

  @override
  ConsumerState<ListTileComponent> createState() => _ListTileComponentState();
}

class _ListTileComponentState extends ConsumerState<ListTileComponent> {
  OverlayEntry? _overlayEntry;
  bool _isDragging = false;

  @override
  void dispose() {
    // 画面を離れるタイミングで必ずオーバーレイを削除
    _overlayEntry?.remove();
    super.dispose();
  }

  // オーバーレイ挿入
  void _insertOverlay() {
    _overlayEntry?.remove();
    // OverlayEntryを新規作成。builderで評価UIを定義。maintainState=trueで状態を保持
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: Material(
            color: Colors.black.withOpacity(0.1),
            child: Center(
              child: Consumer(
                builder: (ctx, ref, _) {
                  final rating = ref.watch(favProvider)[widget.contentId] ?? 0;
                  return RatingBarIndicator(
                    rating: rating.toDouble(),
                    itemBuilder:
                        (ctx, _) => Icon(Icons.star, color: Colors.amber),
                    itemCount: 5,
                    itemSize: 32,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
    // 現在のOverlayにエントリを挿入
    Overlay.of(context)!.insert(_overlayEntry!);
  }

  @override
  void initState() {
    super.initState();
    // プロバイダ更新を監視してリビルド
    ref.listen<Map<String, int>>(favProvider, (_, __) {
      _overlayEntry?.markNeedsBuild();
    });
  }

  // オーバーレイ削除
  void _removeOverlay() {
    // remove()を呼ぶとOverlayEntryがOverlayから外れる
    _overlayEntry?.remove();
    _overlayEntry = null; // 参照をクリアしてGCを促進
  }

  @override
  Widget build(BuildContext context) {
    final rating = ref.watch(
      favProvider.select((m) => m[widget.contentId] ?? 0),
    );
    return GestureDetector(
      // 長押し開始でオーバーレイを表示
      onLongPressStart: (details) {
        _isDragging = false;
        _insertOverlay();
      },
      // 長押し中の横スワイプで評価更新
      onLongPressMoveUpdate: (details) {
        _isDragging = true;
        final dx = details.localOffsetFromOrigin.dx * 3;
        final newRating =
            (dx / MediaQuery.of(context).size.width * 5).clamp(1, 5).round();
        ref.read(favProvider.notifier).update(widget.contentId, newRating);
      },
      // 長押し終了時に分岐
      onLongPressEnd: (details) {
        _removeOverlay();
        if (!_isDragging) {
          // ドラッグなし → 通常モーダル
          showRatingModal(context, ref, widget.contentId, rating);
        }
      },
      child: Container(
        // 4. 左端縦線（評価値に応じ色分け)
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: borderColor(rating), width: 4.0),
          ),
        ),
        child: ListTile(
          title: Text(widget.contentName, style: TextStyle(fontSize: 16)),
          subtitle:
              widget.contentDescription != null
                  ? Text(
                    widget.contentDescription!,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  )
                  : null,
          onTap: () => context.push('/boards/${widget.contentId}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 5. 星評価インジケータ
              RatingBarIndicator(
                rating: rating.toDouble(),
                itemBuilder:
                    (context, index) => Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 20.0,
                direction: Axis.horizontal,
                unratedColor: Colors.grey.shade300,
              ),
              Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  // ドラッグアップデートによる評価変更処理
  void _handleDragUpdate(LongPressMoveUpdateDetails details) {
    final dx = details.localOffsetFromOrigin.dx;
    final newRating =
        (dx / MediaQuery.of(context).size.width * 5).clamp(1, 5).round();
    ref.read(favProvider.notifier).update(widget.contentId, newRating);
  }
}
