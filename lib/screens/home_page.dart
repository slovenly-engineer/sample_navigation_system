import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/router_provider.dart';
import '../routes/app_routes.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.read(navigationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ホーム'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.home,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Flutter GoRouter + Riverpod\nナビゲーションシステム',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                '🎉 README.md仕様通りの型安全なナビゲーション実装完了！',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),

              // メイン画面ナビゲーション（階層遷移）
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => nav.go(ProfileRoute()),
                  icon: const Icon(Icons.person),
                  label: const Text('プロフィールへ'),
                ),
              ),
              const SizedBox(height: 12),

              // パラメータ付きナビゲーション（階層遷移）
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => nav.go(UserRoute(userId: '123')),
                  icon: const Icon(Icons.info),
                  label: const Text('ユーザー詳細へ'),
                ),
              ),
              const SizedBox(height: 12),

              // 設定画面（階層遷移）
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => nav.go(SettingsRoute()),
                  icon: const Icon(Icons.settings),
                  label: const Text('設定へ'),
                ),
              ),
              const SizedBox(height: 12),

              // モーダル的なナビゲーション（プッシュ）
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => nav.push(ProfileRoute()),
                  icon: const Icon(Icons.add),
                  label: const Text('プロフィール（モーダル）'),
                ),
              ),
              const SizedBox(height: 12),

              // 戻り値を受け取るナビゲーション
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await nav.push<String>(
                      ProductRoute(productId: 'sample-123')
                    );
                    if (result != null) {
                      nav.showSnackBar('結果: $result');
                    }
                  },
                  icon: const Icon(Icons.input),
                  label: const Text('結果を待つ'),
                ),
              ),
              const SizedBox(height: 24),

              // ダイアログ系
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // アラートダイアログ
                  ElevatedButton(
                    onPressed: () async {
                      await nav.showAlert(
                        title: 'お知らせ',
                        message: 'README.md仕様通りの実装が完了しました！',
                        okButtonText: '了解',
                      );
                    },
                    child: const Text('アラート'),
                  ),

                  // 確認ダイアログ
                  ElevatedButton(
                    onPressed: () async {
                      final confirmed = await nav.showConfirmDialog(
                        title: '確認',
                        message: '実行しますか？',
                      );
                      
                      if (confirmed == true) {
                        nav.showSnackBar('実行しました');
                      }
                    },
                    child: const Text('確認'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ボトムシート
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await nav.showBottomSheet<String>(
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'NavigationService メソッド',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            leading: const Icon(Icons.navigation),
                            title: const Text('go()'),
                            subtitle: const Text('画面遷移（スタック置き換え）'),
                            onTap: () => Navigator.of(context).pop('go'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.add),
                            title: const Text('push()'),
                            subtitle: const Text('画面プッシュ（スタック追加）'),
                            onTap: () => Navigator.of(context).pop('push'),
                          ),
                          ListTile(
                            leading: const Icon(Icons.swap_horiz),
                            title: const Text('replace()'),
                            subtitle: const Text('画面置き換え'),
                            onTap: () => Navigator.of(context).pop('replace'),
                          ),
                        ],
                      ),
                    ),
                  );

                  if (result != null) {
                    nav.showSnackBar('選択: $result');
                  }
                },
                icon: const Icon(Icons.more_vert),
                label: const Text('メソッド一覧'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}