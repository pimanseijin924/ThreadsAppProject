import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_app/constants/Colors.dart';
import 'package:my_app/models/thread_model.dart';
import 'package:my_app/providers/thread_provider.dart';
import 'package:my_app/providers/favorite_provider.dart';
import 'package:my_app/widgets/corner_clipper.dart';
import 'package:my_app/widgets/rating_modal.dart';

class ListTileComponent extends ConsumerStatefulWidget {
  final String contentId;
  final String contentName;
  final String contentDescription;
  final String type;
  final String? channelId;
  final String? boardId;
  final String? threadId;
  final Thread? thread;
  // 外部からオンロングプレスイベントを受け取るコールバック
  final GestureLongPressStartCallback? onLongPressStart;
  final GestureLongPressEndCallback? onLongPressEnd;

  const ListTileComponent({
    Key? key,
    required this.contentId,
    required this.contentName,
    required this.contentDescription,
    required this.type,
    this.channelId,
    this.boardId,
    this.threadId,
    this.thread,
    this.onLongPressStart,
    this.onLongPressEnd,
  }) : super(key: key);

  @override
  ConsumerState<ListTileComponent> createState() => _ListTileComponentState();
}

class _ListTileComponentState extends ConsumerState<ListTileComponent> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final rating = ref.watch(
      favProvider.select((m) => m[widget.contentId] ?? 0),
    );
    final label = widget.thread?.label;
    final labelColor = _getLabelColor(label ?? '');

    final updateActions = <String, void Function(int)>{
      'channel':
          (r) => ref
              .read(favProvider.notifier)
              .updateFavChannel(widget.contentId, r),
      'board':
          (r) => ref
              .read(favProvider.notifier)
              .updateFavBoard(widget.contentId, r),
      'thread':
          (r) => ref
              .read(favProvider.notifier)
              .updateFavThread(widget.contentId, r),
    };

    return GestureDetector(
      onLongPressStart: (d) {
        _isDragging = false;
        widget.onLongPressStart?.call(d);
      },
      onLongPressMoveUpdate: (details) {
        _isDragging = true;
        final dx = details.localOffsetFromOrigin.dx * 3;
        final newRating =
            (dx / MediaQuery.of(context).size.width * 5).clamp(0, 5).round();
        updateActions[widget.type]?.call(newRating);
      },
      onLongPressEnd: (d) {
        if (!_isDragging) {
          showRatingModal(context, ref, widget.contentId, rating, widget.type);
        }
        widget.onLongPressEnd!.call(d);
      },
      child: ClipPath(
        clipper: CornerClipper(triangleSize: 28.0),
        child: Stack(
          children: [
            // ベースのListTile背景
            Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: borderColor(rating), width: 4.0),
                ),
              ),
              child: ListTile(
                title: Text(widget.contentName, style: TextStyle(fontSize: 16)),
                subtitle: switch (widget.type) {
                  'thread' => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '閲覧数: ${widget.thread!.viewCount}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          SizedBox(width: 16),
                          Text(
                            '書き込み数: ${widget.thread!.commentCount}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      if (widget.thread!.createdAt != null)
                        Text(
                          '作成日時: ${DateFormat('yy/MM/dd HH:mm:ss.SS').format(widget.thread!.createdAt!)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                  'board' =>
                    widget.contentDescription.isNotEmpty
                        ? Text(
                          widget.contentDescription,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )
                        : null,
                  'channel' =>
                    widget.contentDescription.isNotEmpty
                        ? Text(
                          widget.contentDescription,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )
                        : null,
                  _ => null,
                },
                onTap: () {
                  switch (widget.type) {
                    case 'channel':
                      context.push('/boards/${widget.contentId}');
                      break;
                    case 'board':
                      context.push('/threads/${widget.contentId}');
                      break;
                    case 'thread':
                      context.push(
                        '/thread/${widget.boardId}/${widget.threadId}',
                      );
                      ref.read(
                        incrementThreadViewCountProvider(widget.threadId!),
                      );
                      break;
                    default:
                      break;
                  }
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RatingBarIndicator(
                      rating: rating.toDouble(),
                      itemBuilder:
                          (context, _) => Icon(Icons.star, color: Colors.amber),
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
            // 右上三角形の色付け
            Positioned(
              top: 0,
              right: 0,
              child: ClipPath(
                clipper: CornerClipper(triangleSize: 28.0),
                child: Container(width: 28.0, height: 28.0, color: labelColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color borderColor(int rating) {
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

  Color _getLabelColor(String label) {
    switch (label) {
      case 'official':
        return Colors.grey;
      case 'honsure':
        return Colors.orange;
      case 'jikkyou':
        return Colors.green;
      default:
        return Colors.transparent;
    }
  }
}
