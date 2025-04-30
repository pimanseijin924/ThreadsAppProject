import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/models/thread_model.dart';
import 'package:my_app/providers/thread_provider.dart';
import 'package:my_app/providers/favorite_provider.dart';
import 'package:my_app/widgets/overlay_list_tile.dart';

// 現在オーバーレイ表示中のスレッドIDを管理するProvider
final activeThreadOverlayProvider = StateProvider<String?>((ref) => null);

class ThreadListScreen extends ConsumerStatefulWidget {
  final String boardId;

  const ThreadListScreen({Key? key, required this.boardId}) : super(key: key);

  @override
  ConsumerState<ThreadListScreen> createState() => _ThreadListScreenState();
}

class _ThreadListScreenState extends ConsumerState<ThreadListScreen> {
  OverlayEntry? _overlayEntry;
  List<Thread>? _stableSorted;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Overlay表示トリガーを一度だけ監視
    ref.listenManual<String?>(
      activeThreadOverlayProvider,
      (prev, threadId) => _toggleOverlay(threadId),
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

  void _toggleOverlay(String? threadId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 重複防止で前回のOverlayを確実に消す
      _removeOverlay();
      if (threadId == null) return;

      // 新規OverlayEntryを作成
      _overlayEntry = OverlayEntry(
        builder: (context) {
          final rating = ref.watch(favProvider)[threadId] ?? 0;
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    ref.read(activeThreadOverlayProvider.notifier).state = null;
                  },
                  child: Container(color: Colors.black.withOpacity(0.1)),
                ),
              ),
              Center(
                child: Consumer(
                  builder: (ctx, ref, _) {
                    final rating = ref.watch(favProvider)[threadId] ?? 0;
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
    final threadListAsync = ref.watch(boardThreadsProvider(widget.boardId));
    final favorites = ref.watch(favProvider);
    final activeOverlayId = ref.watch(activeThreadOverlayProvider);
    final query = _searchController.text.trim().toLowerCase();

    // 画面表示時に直近閲覧板を更新
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lastBoardProvider.notifier).setBoardId(widget.boardId);
    });

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
                : const Text('スレッド一覧'),
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
      body: threadListAsync.when(
        data: (threadList) {
          // お気に入り済みを先頭に、評価降順でソート
          final sorted = [
            ...threadList
                .where((thread) => (favorites[thread.id] ?? 0) > 0)
                .toList()
              ..sort((a, b) => favorites[b.id]!.compareTo(favorites[a.id]!)),
            ...threadList.where((thread) => (favorites[thread.id] ?? 0) == 0),
          ];
          // フィルタ：検索クエリと一致するもののみ
          final filtered =
              query.isEmpty
                  ? sorted
                  : sorted
                      .where(
                        (thread) => thread.title.toLowerCase().contains(query),
                      )
                      .toList();
          // ドラッグ中はソートリストを固定
          final displayList =
              (activeOverlayId != null && _stableSorted != null)
                  ? _stableSorted!
                  : filtered;
          return threadList.isEmpty
              ? Center(child: Text('スレッドがありません'))
              : ListView.builder(
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final thread = displayList[index];
                  return ListTileComponent(
                    key: ValueKey(thread.id),
                    contentId: thread.id,
                    contentName: thread.title,
                    contentDescription: '',
                    type: 'thread',
                    boardId: widget.boardId,
                    threadId: thread.id,
                    thread: thread,
                    onLongPressStart: (_) {
                      // ドラッグ開始時にソート順を固定
                      _stableSorted = sorted;
                      // Overlayトリガーをリセット→セット
                      ref.read(activeThreadOverlayProvider.notifier).state =
                          null;
                      Future.microtask(() {
                        ref.read(activeThreadOverlayProvider.notifier).state =
                            thread.id;
                      });
                    },
                    onLongPressEnd: (_) {
                      // ドラッグ終了時にOverlay閉じる & ソート順クリア
                      ref.read(activeThreadOverlayProvider.notifier).state =
                          null;
                      _stableSorted = null;
                    },
                  );
                },
              );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('エラーが発生しました: $e')),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/threads_create/${widget.boardId}');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
