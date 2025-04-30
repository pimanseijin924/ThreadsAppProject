import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_app/providers/board_provider.dart';
import 'package:my_app/providers/favorite_provider.dart';
import 'package:my_app/widgets/overlay_list_tile.dart';

// 現在表示中の板IDを管理するProvider
final activeBoardOverlayProvider = StateProvider<String?>((ref) => null);

class BoardListScreen extends ConsumerStatefulWidget {
  final String channelId;

  const BoardListScreen({Key? key, required this.channelId}) : super(key: key);

  @override
  ConsumerState<BoardListScreen> createState() => _BoardListScreenState();
}

class _BoardListScreenState extends ConsumerState<BoardListScreen> {
  OverlayEntry? _overlayEntry;
  List<Board>? _stableSorted;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Overlay表示トリガーを一度だけ監視
    ref.listenManual<String?>(
      activeBoardOverlayProvider,
      (prev, boardId) => _toggleOverlay(boardId),
      fireImmediately: false,
    );
    // 検索キーの変更を監視
    _searchController.addListener(() => setState(() {}));
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

  void _toggleOverlay(String? boardId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 重複防止で前回のOverlayを確実に消す
      _removeOverlay();
      if (boardId == null) return;

      // 新規OverlayEntryを作成
      _overlayEntry = OverlayEntry(
        builder: (context) {
          final rating = ref.watch(favProvider)[boardId] ?? 0;
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    ref.read(activeBoardOverlayProvider.notifier).state = null;
                  },
                  child: Container(color: Colors.black.withOpacity(0.1)),
                ),
              ),
              Center(
                child: Consumer(
                  builder: (ctx, ref, _) {
                    final rating = ref.watch(favProvider)[boardId] ?? 0;
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
    final boardListAsync = ref.watch(boardListProvider(widget.channelId));
    final favorites = ref.watch(favProvider);
    final activeOverlayId = ref.watch(activeBoardOverlayProvider);
    final query = _searchController.text.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'チャンネルを検索',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                )
                : const Text("板一覧"),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                }
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: boardListAsync.when(
          data: (boardList) {
            // お気に入り済みを先頭に、評価降順でソート :contentReference[oaicite:0]{index=0}
            final sorted = [
              ...boardList
                  .where((board) => (favorites[board.id] ?? 0) > 0)
                  .toList()
                ..sort((a, b) => favorites[b.id]!.compareTo(favorites[a.id]!)),
              ...boardList.where((board) => (favorites[board.id] ?? 0) == 0),
            ];
            // フィルタ：検索クエリと一致するもののみ
            final filtered =
                query.isEmpty
                    ? sorted
                    : sorted
                        .where(
                          (board) => board.name.toLowerCase().contains(query),
                        )
                        .toList();
            // ドラッグ中はソートリストを固定
            final displayList =
                (activeOverlayId != null && _stableSorted != null)
                    ? _stableSorted!
                    : filtered;
            return ListView.builder(
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final board = displayList[index];
                return ListTileComponent(
                  key: ValueKey(board.id),
                  contentId: board.id,
                  contentName: board.name,
                  contentDescription: board.description ?? '',
                  type: 'board',
                  onLongPressStart: (_) {
                    // ドラッグ開始時にソート順を固定
                    _stableSorted = sorted;
                    // Overlayトリガーをリセット→セット
                    ref.read(activeBoardOverlayProvider.notifier).state = null;
                    Future.microtask(() {
                      ref.read(activeBoardOverlayProvider.notifier).state =
                          board.id;
                    });
                  },
                  onLongPressEnd: (_) {
                    // ドラッグ終了時にOverlay閉じる & ソート順クリア
                    ref.read(activeBoardOverlayProvider.notifier).state = null;
                    _stableSorted = null;
                  },
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
