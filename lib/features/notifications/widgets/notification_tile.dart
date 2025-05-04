import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/Home/viewModel/post_vm.dart';
import '../model/notification_model.dart';

class NotificationTile extends ConsumerWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context); // Get theme data

    return Container(
      color: notification.isRead
          ? theme.colorScheme.surface // White (light mode) / Dark (dark mode)
          : theme.colorScheme.secondary.withOpacity(0.3), // Light blue (light mode) / Dark blue (dark mode)
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(notification.profilePhoto),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User name on top
            Text(
              '${notification.firstName} ${notification.lastName}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            // Content below name
            Text(
              notification.content,
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            notification.createdAt,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        onTap: () async {
          onTap(); // This calls the original onTap callback

          // Navigation logic based on notification type - using if-else for correct flow
          if (notification.type == NotificationFilter.Posts) {
            final postMap = await ref.read(postProvider.notifier).getPost(notification.referenceId);
            final post = PostModel.fromJson(postMap); // Convert map to PostModel
            ref.read(postProvider.notifier).setPost(post);
            context.push('/postPage', extra: post);
          } else if (notification.type == NotificationFilter.CONNECTION_REQUEST) {
            context.push('/invitations');
          } else if (notification.type == NotificationFilter.CONNECTION_ACCEPTED) {
            context.push('/connections');
          } else if (notification.type == NotificationFilter.FOLLOW) {
            context.push('/profile', extra: notification.referenceId);
          }
        },
      ),
    );
  }
}
