import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/router_provider.dart';
import '../routes/app_routes.dart';

class UserPage extends ConsumerWidget {
  final String userId;

  const UserPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.read(navigationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('User $userId'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 階層ナビゲーションではホームに戻る
            nav.go(HomeRoute());
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'User ID: $userId',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => nav.go(UserProfileRoute(userId: userId)),
              icon: const Icon(Icons.person),
              label: const Text('View Profile'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => nav.go(UserPostsRoute(userId: userId)),
              icon: const Icon(Icons.article),
              label: const Text('View Posts'),
            ),
          ],
        ),
      ),
    );
  }
}