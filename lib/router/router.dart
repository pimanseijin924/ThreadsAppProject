import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/models/thread_model.dart';
import 'package:my_app/screens/post_thread_screen_dev.dart';
import 'package:my_app/widgets/base_shell.dart';
import 'package:my_app/screens/channel_list_screen.dart';
import 'package:my_app/screens/board_list_screen.dart';
import 'package:my_app/screens/thread_list_screen.dart';
import 'package:my_app/screens/create_thread_screen.dart';
import 'package:my_app/screens/create_thread_screen_dev.dart';
import 'package:my_app/screens/thread_detail_screen.dart';
import 'package:my_app/screens/post_thread_screen.dart';
import 'package:my_app/screens/setting_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _readThreadNavigatorKey = GlobalKey<NavigatorState>();
final _settingsNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/channels',
  routes: [
    ShellRoute(
      builder: (context, state, child) => BaseShell(child: child),
      routes: [
        // タブ1（チャンネル系）
        ShellRoute(
          navigatorKey: _readThreadNavigatorKey,
          builder: (context, state, child) => child,
          routes: [
            GoRoute(
              path: '/channels',
              builder: (context, state) => ChannelListScreen(),
            ),
            GoRoute(
              path: '/boards/:channelId',
              pageBuilder: (context, state) {
                final channelId = state.pathParameters['channelId']!;
                return CustomTransitionPage(
                  child: BoardListScreen(channelId: channelId),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                );
              },
            ),
            GoRoute(
              path: '/threads/:boardId',
              pageBuilder: (context, state) {
                final boardId = state.pathParameters['boardId']!;
                return CustomTransitionPage(
                  child: ThreadListScreen(boardId: boardId),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                );
              },
            ),
            GoRoute(
              path: '/thread/:boardId/:threadId',
              pageBuilder: (context, state) {
                final boardId = state.pathParameters['boardId']!;
                final threadId = state.pathParameters['threadId']!;
                return CustomTransitionPage(
                  child: ThreadDetailScreen(
                    boardId: boardId,
                    threadId: threadId,
                    showBackToTab: true,
                  ),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                );
              },
            ),
            GoRoute(
              path: '/thread/post',
              pageBuilder: (context, state) {
                final thread = state.extra as Thread;
                return CustomTransitionPage(
                  child: PostThreadScreen(thread: thread),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                );
              },
            ),
            GoRoute(
              path: '/thread/post_dev',
              pageBuilder: (context, state) {
                final thread = state.extra as Thread;
                return CustomTransitionPage(
                  child: PostThreadScreenDev(thread: thread),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                );
              },
            ),
            GoRoute(
              path: '/threads_create/:boardId',
              pageBuilder: (context, state) {
                final boardId = state.pathParameters['boardId']!;
                return CustomTransitionPage(
                  child: CreateThreadScreen(boardId: boardId),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                );
              },
            ),
            GoRoute(
              path: '/threads_create_dev/:boardId',
              pageBuilder: (context, state) {
                final boardId = state.pathParameters['boardId']!;
                return CustomTransitionPage(
                  child: CreateThreadScreenDev(boardId: boardId),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    );
                  },
                );
              },
            ),
          ],
        ),

        // タブ2（設定系）
        ShellRoute(
          //navigatorKey: _settingsNavigatorKey,
          builder: (context, state, child) => child,
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
