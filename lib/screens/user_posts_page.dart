import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/navigation_service.dart';
import '../routes/app_route.dart';

class UserPostsPage extends ConsumerWidget {
  final String userId;

  const UserPostsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.read(navigationServiceProvider);

    // Dummy posts data
    final posts = List.generate(
      10,
      (index) => {
        'id': '${index + 1}',
        'title': 'Post ${index + 1} by User $userId',
        'preview': 'This is the preview text for post ${index + 1}...',
        'date': '2024-01-${(index + 1).toString().padLeft(2, '0')}',
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Posts - User $userId'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(post['title']!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(post['preview']!),
                  const SizedBox(height: 4),
                  Text(
                    post['date']!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                nav.go(PostDetail(
                  userId: userId,
                  postId: post['id']!,
                  showComments: false,
                ));
              },
            ),
          );
        },
      ),
    );
  }
}