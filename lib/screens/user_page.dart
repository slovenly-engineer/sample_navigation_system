import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/navigation_service.dart';
import '../routes/app_route.dart';

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
              onPressed: () => nav.go(UserProfile(userId: userId)),
              icon: const Icon(Icons.person),
              label: const Text('View Profile'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => nav.go(UserPosts(userId: userId)),
              icon: const Icon(Icons.article),
              label: const Text('View Posts'),
            ),
          ],
        ),
      ),
    );
  }
}