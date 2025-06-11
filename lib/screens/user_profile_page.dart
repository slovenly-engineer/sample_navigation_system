import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/navigation_service.dart';

class UserProfilePage extends ConsumerWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.read(navigationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile - User $userId'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                userId,
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('User ID', userId),
                    _buildInfoRow('Name', 'User $userId'),
                    _buildInfoRow('Email', 'user$userId@example.com'),
                    _buildInfoRow('Joined', '2024-01-01'),
                    _buildInfoRow('Status', 'Active'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final confirmed = await nav.showConfirmDialog(
                  title: 'Edit Profile',
                  message: 'Would you like to edit this profile?',
                  confirmText: 'Edit',
                );
                
                if (confirmed == true) {
                  nav.showSnackBar(message: 'Edit feature coming soon!');
                }
              },
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}