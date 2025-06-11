import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../routes/app_route.dart';
import '../providers/router_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.read(navigationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (nav.canPop()) {
              nav.pop();
            } else {
              nav.go(const Home());
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'ユーザー名',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'user@example.com',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: const Text('メールアドレス'),
                      subtitle: const Text('user@example.com'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          nav.showSnackBar(
                            message: 'メールアドレスの編集',
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: const Text('電話番号'),
                      subtitle: const Text('+81 90-1234-5678'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          nav.showSnackBar(
                            message: '電話番号の編集',
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text('住所'),
                      subtitle: const Text('東京都渋谷区'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          nav.showSnackBar(
                            message: '住所の編集',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => nav.go(const Home()),
                    icon: const Icon(Icons.home),
                    label: const Text('ホームへ'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => nav.push(const Settings()),
                    icon: const Icon(Icons.settings),
                    label: const Text('設定'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () async {
                  final confirmed = await nav.showDialogWidget<bool>(
                    dialog: AlertDialog(
                      title: const Text('ログアウト'),
                      content: const Text('ログアウトしますか？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('ログアウト'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && context.mounted) {
                    nav.showSnackBar(
                      message: 'ログアウトしました',
                    );
                    nav.go(const Home());
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'ログアウト',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
