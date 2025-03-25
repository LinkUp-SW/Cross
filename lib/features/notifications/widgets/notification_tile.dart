import 'package:flutter/material.dart';
import '../model/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationTile({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get theme data

    return Container(
      color: notification.isRead
          ? theme.colorScheme.surface // White (light mode) / Dark (dark mode)
          : theme.colorScheme.secondary
              .withOpacity(0.3), // Light blue (light mode) / Dark blue (dark
      child: ListTile(
        leading: const CircleAvatar(
          backgroundImage: AssetImage("assets/images/profile.png"),
        ),
        title: RichText(
          text: TextSpan(
            style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
            children: [
              TextSpan(
                text: '${notification.name} ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: notification.message),
            ],
          ),
        ),
        subtitle: Text(notification.time,
            style:
                TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6))),
        onTap: onTap, // Trigger read state change when tapped
      ),
    );
  }
}
