import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';

class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('設定'),
        automaticallyImplyLeading: false, // ← これで「← ボタン」を非表示にする
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // テーマ設定
            Text(
              'テーマ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<ThemeMode>(
              value: themeMode,
              onChanged: (ThemeMode? newTheme) {
                if (newTheme != null) {
                  ref.read(themeProvider.notifier).state = newTheme;
                }
              },
              items: [
                DropdownMenuItem(value: ThemeMode.light, child: Text('ライト')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('ダーク')),
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('システム設定'),
                ),
              ],
            ),
            SizedBox(height: 20),

            // 言語設定
            Text(
              '言語',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButton<Locale>(
              value: locale,
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  ref.read(localeProvider.notifier).state = newLocale;
                }
              },
              items: [
                DropdownMenuItem(value: Locale('ja', 'JP'), child: Text('日本語')),
                DropdownMenuItem(
                  value: Locale('en', 'US'),
                  child: Text('English'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
