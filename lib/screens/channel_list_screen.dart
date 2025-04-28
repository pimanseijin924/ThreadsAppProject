import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_app/models/channel_model.dart';
import 'package:my_app/providers/channel_provider.dart';
import 'package:my_app/providers/favorite_provider.dart';
import 'package:my_app/widgets/overlay_list_tile.dart';

/// 現在表示中のチャンネルIDを管理するProvider
final activeChannelOverlayProvider = StateProvider<String?>((ref) => null);

class ChannelListScreen extends ConsumerStatefulWidget {
  const ChannelListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChannelListScreen> createState() => _ChannelListScreenState();
}

class _ChannelListScreenState extends ConsumerState<ChannelListScreen> {
  OverlayEntry? _overlayEntry;
  List<Channel>? _stableSorted;

  @override
  void initState() {
    super.initState();
    // Overlay表示トリガーを一度だけ監視
    ref.listenManual<String?>(
      activeChannelOverlayProvider,
      (prev, channelId) => _toggleOverlay(channelId),
      fireImmediately: false,
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleOverlay(String? channelId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 重複防止で前回のOverlayを確実に消す
      _removeOverlay();
      if (channelId == null) return;

      // 新規OverlayEntryを作成
      _overlayEntry = OverlayEntry(
        builder: (context) {
          final rating = ref.watch(favProvider)[channelId] ?? 0;
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    ref.read(activeChannelOverlayProvider.notifier).state =
                        null;
                  },
                  child: Container(color: Colors.black.withOpacity(0.1)),
                ),
              ),
              Center(
                child: Consumer(
                  builder: (ctx, ref, _) {
                    final rating = ref.watch(favProvider)[channelId] ?? 0;
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
            ],
          );
        },
      );
      Overlay.of(context)!.insert(_overlayEntry!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncChannels = ref.watch(channelListProvider);
    final favorites = ref.watch(favProvider);
    final activeOverlayId = ref.watch(activeChannelOverlayProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('チャンネル一覧'),
        automaticallyImplyLeading: false,
      ),
      body: asyncChannels.when(
        data: (channels) {
          // お気に入りを先頭に評価降順でソート
          final sorted = [
            ...channels.where((ch) => (favorites[ch.id] ?? 0) > 0).toList()
              ..sort((a, b) => favorites[b.id]!.compareTo(favorites[a.id]!)),
            ...channels.where((ch) => (favorites[ch.id] ?? 0) == 0),
          ];

          // ドラッグ中はソートリストを固定
          final displayList =
              (activeOverlayId != null && _stableSorted != null)
                  ? _stableSorted!
                  : sorted;

          return ListView.builder(
            itemCount: displayList.length,
            itemBuilder: (context, index) {
              final ch = displayList[index];
              return ListTileComponent(
                key: ValueKey(ch.id),
                contentId: ch.id,
                contentName: ch.name,
                contentDescription: ch.description ?? '',
                type: 'channel',
                channelId: ch.id,
                onLongPressStart: (_) {
                  // ドラッグ開始時にソート順を固定
                  _stableSorted = sorted;
                  // Overlayトリガーをリセット→セット
                  ref.read(activeChannelOverlayProvider.notifier).state = null;
                  Future.microtask(() {
                    ref.read(activeChannelOverlayProvider.notifier).state =
                        ch.id;
                  });
                },
                onLongPressEnd: (_) {
                  // ドラッグ終了時にOverlay閉じる & ソート順クリア
                  ref.read(activeChannelOverlayProvider.notifier).state = null;
                  _stableSorted = null;
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: \$e')),
      ),
    );
  }
}
