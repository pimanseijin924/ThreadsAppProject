import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'channnel_list_screen.dart';
import 'thread_list_screen.dart';
import 'thread_detail_screen.dart';
import 'setting_screen.dart';

class BaseScreen extends ConsumerStatefulWidget {
  final int initialIndex; // 初期表示のインデックス
  final String? channelId; // チャンネルID（板一覧画面用）
  final String? boardId; // 板ID（スレッド一覧画面用）
  final String? threadTitle; // スレッド詳細のタイトル（スレッド詳細画面用）

  const BaseScreen({
    Key? key,
    this.initialIndex = 0,
    this.channelId,
    this.boardId,
    this.threadTitle,
  }) : super(key: key);

  // 各画面から画面遷移するときに、NavigatorStateを取得するためのメソッド
  // タブ間遷移でNavigatorを手動で管理することで、より滑らかな画面スタック管理を実現
  // NavigatorからRouteに変更予定なので、削除予定
  // TODO Routeに変更、これを削除
  static List<GlobalKey<NavigatorState>> getNavigatorStateList(
    BuildContext context,
  ) {
    final _BaseScreenState? state =
        context.findAncestorStateOfType<_BaseScreenState>();
    if (state != null) {
      return state._navigatorKeys;
    }
    return [];
  }

  // 各画面からタブを選択するだけの単純なメソッド
  // 手動でNavigator管理しながら画面遷移するときにほかのメソッドと合わせて使う
  // Routeに変更予定なので、削除予定
  // TODO Routeに変更、これを削除
  static void setTab(BuildContext context, int index) {
    final _BaseScreenState? state =
        context.findAncestorStateOfType<_BaseScreenState>();
    if (state != null) {
      state.setTab(index);
    }
  }

  // タブ間遷移するときに、元のNavigatorの状態を保持しつつタブ移動するメソッド
  // Routeに変更予定なので、削除予定
  // TODO Routeに変更、これを削除
  static void setTabAndPush(
    BuildContext context,
    int tabToPushFrom,
    int tabToSelect,
    Widget page,
  ) {
    final _BaseScreenState? state =
        context.findAncestorStateOfType<_BaseScreenState>();
    if (state != null) {
      state._navigatorKeys[tabToPushFrom].currentState?.push(
        MaterialPageRoute(builder: (_) => page),
      );
      state.setTab(tabToSelect);
    }
  }

  // 外部から「板選択 → スレッド一覧表示」する用
  // TODO Routeに変更、これを削除
  static void pushThreadListTab(BuildContext context, String boardId) {
    final _BaseScreenState? state =
        context.findAncestorStateOfType<_BaseScreenState>();
    state?.setTabAndPushBoard(boardId);
  }

  // 外部から「スレッド選択 → スレッド詳細表示」する用
  // TODO Routeに変更、これを削除
  static void pushThreadDetailTab(BuildContext context, String threadTitle) {
    final _BaseScreenState? state =
        context.findAncestorStateOfType<_BaseScreenState>();
    state?.setTabAndPushDetail(threadTitle);
  }

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends ConsumerState<BaseScreen> {
  late int _selectedIndex;
  // TODO Routeに変更、これを削除
  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    4,
    (_) => GlobalKey<NavigatorState>(),
  );

  String? _sharedBoardId; // タブをまたいで共有するboardId
  String? _sharedThreadId; // タブをまたいで共有するthreadId
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _sharedBoardId = widget.boardId;
    _sharedThreadId = widget.threadTitle;
  }

  // タブを選択するメソッド
  // TODO Routeに変更、これを削除
  void setTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 外部から「板選択 → スレッド一覧表示」する用メソッドの中身
  // TODO Routeに変更、これを削除
  void setTabAndPushBoard(String boardId) {
    setState(() {
      _sharedBoardId = boardId;
      _selectedIndex = 1; // スレッド一覧タブへ
    });
  }

  // 外部から「スレッド選択 → スレッド詳細表示」する用メソッドの中身
  // TODO Routeに変更、これを削除
  void setTabAndPushDetail(String threadTitle) {
    setState(() {
      _sharedThreadId = threadTitle;
      _selectedIndex = 2; // スレッド詳細タブへ
    });
  }

  // 各タブのルート画面を定義
  // TODO Routeに変更、これを削除
  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (RouteSettings settings) {
          Widget page;
          switch (index) {
            case 0:
              page = ChannelListScreen();
              break;
            case 1:
              page = ThreadListScreen(
                boardId: widget.boardId ?? '', // 板IDを渡す
                showBackToTab0: true,
              );
              break;
            case 2:
              page = ThreadDetailScreen(
                threadTitle: widget.threadTitle ?? '', // スレッドタイトルを渡す
                showBackToTab: true,
              );
              break;
            case 3:
              page = SettingsScreen();
              break;
            default:
              page = Center(child: Text('Unknown page'));
          }
          return MaterialPageRoute(builder: (_) => page, settings: settings);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScopeを使って、戻るキーを押したときの、タブ間のページタックの管理
    // TODO Routeに変更するので設計見直し
    return WillPopScope(
      onWillPop: () async {
        final currentNavigator = _navigatorKeys[_selectedIndex].currentState!;
        if (currentNavigator.canPop()) {
          return true;
        } else if (_selectedIndex != 0) {
          setTab(0); // 戻るキーでチャンネル・板に戻す
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: List.generate(4, (index) => _buildOffstageNavigator(index)),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            // 同じタブを再選択した場合、内部の Navigator をポップする
            if (_selectedIndex == index) {
              _navigatorKeys[index].currentState?.popUntil(
                (route) => route.isFirst,
              );
            } else {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'チャンネル・板',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'スレッド一覧'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'スレッド詳細'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
          ],
        ),
      ),
    );
  }
}
