import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/navigation_service.dart';

class PostDetailPage extends ConsumerWidget {
  final String userId;
  final String postId;
  final bool showComments;

  const PostDetailPage({
    super.key,
    required this.userId,
    required this.postId,
    this.showComments = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.read(navigationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Post $postId'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(showComments ? Icons.comment : Icons.comment_outlined),
            onPressed: () async {
              await nav.showSnackBar(
                message: showComments 
                  ? 'Comments are already visible'
                  : 'Toggle comments feature',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          child: Text(userId),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'User $userId',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Posted on 2024-01-01',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Post $postId Title',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This is the detailed content of post $postId. '
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                      'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
                      'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => nav.showSnackBar(message: 'Liked!'),
                  icon: const Icon(Icons.thumb_up_outlined),
                  label: const Text('Like'),
                ),
                TextButton.icon(
                  onPressed: () => nav.showSnackBar(message: 'Shared!'),
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
                TextButton.icon(
                  onPressed: () => nav.showSnackBar(message: 'Saved!'),
                  icon: const Icon(Icons.bookmark_outline),
                  label: const Text('Save'),
                ),
              ],
            ),
            if (showComments) ...[
              const Divider(height: 32),
              Text(
                'Comments',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...List.generate(
                3,
                (index) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              child: Text('${index + 1}'),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Commenter ${index + 1}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('This is comment ${index + 1} on the post.'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}