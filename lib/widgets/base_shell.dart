import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/providers/thread_provider.dart';

class BaseShell extends ConsumerStatefulWidget {
  final Widget child;
  const BaseShell({super.key, required this.child});

  @override
  ConsumerState<BaseShell> createState() => _BaseShellState();
}

class _BaseShellState extends ConsumerState<BaseShell> {
  //late BannerAd _bannerAd;
  bool _isAdLoaded = false;
  int _indexFromLocation(String location) {
    if (location.startsWith('/threads')) return 1;
    if (location.startsWith('/thread')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  void initState() {
    super.initState();
    // SDK 初期化
    // MobileAds.instance.initialize(); // 必須ではないが推奨
    // // BannerAd 設定
    // _bannerAd = BannerAd(
    //   adUnitId: 'ca-app-pub-3940256099942544/2934735716',
    //   size: AdSize.banner,
    //   request: AdRequest(),
    //   listener: BannerAdListener(
    //     onAdLoaded: (_) => setState(() => _isAdLoaded = true),
    //     onAdFailedToLoad: (_, err) => debugPrint('Ad load failed: $err'),
    //   ),
    // );
    // _bannerAd.load();
  }

  @override
  void dispose() {
    //_bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);
    // Provider から直近閲覧板を取得
    final lastBoardId = ref.watch(lastBoardProvider);
    // Provider から直近閲覧スレッドを取得
    final lastThread = ref.watch(lastThreadProvider);

    // final BannerAd _bannerAd = BannerAd(
    //   adUnitId: 'ca-app-pub-3940256099942544/2934735716', // テストユニットID
    //   size: AdSize.banner,
    //   request: AdRequest(),
    //   listener: BannerAdListener(
    //     onAdLoaded: (_) => setState(() => _isAdLoaded = true),
    //     onAdFailedToLoad: (_, err) {
    //       debugPrint('BannerAd failed to load: $err');
    //       _isAdLoaded = false;
    //     },
    //   ),
    // );
    // _bannerAd.load();

    return Scaffold(
      body: widget.child,
      // persistentFooterButtons:
      //     _isAdLoaded
      //         ? [
      //           SizedBox(
      //             width: _bannerAd.size.width.toDouble(),
      //             height: _bannerAd.size.height.toDouble(),
      //             child: AdWidget(ad: _bannerAd),
      //           ),
      //         ]
      //         : null,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.push('/channels');
              break;
            case 1:
              // 直近板ID があればそこへ、なければデフォルト板へ遷移
              // デフォルト板は運営チャンネル玄関板
              final targetBoardId = lastBoardId ?? '0101';
              context.push('/threads/$targetBoardId');
              break;
            case 2:
              // 直近に見たスレッドがあればそこへ、なければデフォルトスレッドへ遷移
              // デフォルトスレッドは玄関板初めての方向けスレッド
              final targetBoardId = lastThread?.boardId ?? '0101';
              final targetThreadId = lastThread?.threadId ?? 'preDefault01';
              context.push('/thread/$targetBoardId/$targetThreadId');
              break;
            case 3:
              context.go('/settings');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'チャンネル'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'スレッド'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '詳細'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}
