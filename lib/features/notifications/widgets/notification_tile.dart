
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme data
  

    return Container(
      color: notification.isRead
          ? theme.colorScheme.surface // White (light mode) / Dark (dark mode)
          : theme.colorScheme.secondary.withValues(alpha: 0.3), // Light blue (light mode) / Dark blue (dark 
      child: ListTile(

        leading: const CircleAvatar(
          backgroundImage: AssetImage("assets/images/profile.png"),

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
        onTap: () {
  onTap(); // This calls the original onTap callback
  
  // Navigation logic based on notification type
  if (notification.type == NotificationFilter.Posts && notification.referenceId != null) {
    context.push('/testpost', extra: notification.referenceId);
    
  } else if (notification.type == NotificationFilter.Connections && notification.referenceId != null) {
    context.push('/testprofile', extra: notification.referenceId);
  }
} // Trigger read state change when tapped
      ),
    );
  }
}
