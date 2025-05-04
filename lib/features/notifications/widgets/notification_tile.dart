
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
          : theme.colorScheme.secondary.withValues(alpha: 0.3), // Light blue (light mode) / Dark blue (dark 
      child: ListTile(

        leading:  CircleAvatar(
          backgroundImage: NetworkImage(notification.profilePhoto),

        ),
        title: RichText(
          text: TextSpan(
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
            children: [
              TextSpan(
                text: '${notification.firstName} ${notification.lastName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: notification.content),
            ],
          ),
        ),
        subtitle: Text(notification.createdAt,
            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
        onTap: () async{
  onTap(); // This calls the original onTap callback
  
  // Navigation logic based on notification type
  if (notification.type == NotificationFilter.Posts ) {
  final postMap = await ref.read(postProvider.notifier).getPost(notification.referenceId);  
  final post = PostModel.fromJson(postMap); // Convert map to PostModel
  ref.read(postProvider.notifier).setPost(post);
    context.push('/postPage', extra: post);
    
  } 
   if (notification.type == NotificationFilter.CONNECTION_REQUEST ) {
    context.push('/invitations');}

  if (notification.type== NotificationFilter.CONNECTION_ACCEPTED) {
    context.push('/connections');
  }
  if (notification.type == NotificationFilter.FOLLOW) {
    context.push('/profile',extra: notification.referenceId);
  }
} // Trigger read state change when tapped
      ),
    );
  }
}
