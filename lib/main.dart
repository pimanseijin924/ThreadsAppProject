import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_app/router/router.dart';

// テーマプロバイダ（明るい・暗いテーマを切り替え）
final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// ロケール（言語設定）プロバイダ
final localeProvider = StateProvider<Locale>((ref) => Locale('ja', 'JP'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: AnonymousBoardApp()));
}

class AnonymousBoardApp extends ConsumerWidget {
  const AnonymousBoardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: '匿名掲示板',
      themeMode: themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      locale: locale,
      supportedLocales: [Locale('ja', 'JP'), Locale('en', 'US')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
