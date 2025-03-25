import 'package:flutter/material.dart';
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
    return Container(
      color: notification.isRead ? Colors.white : const Color.fromARGB(100, 166, 222, 243), // Unread = blue, Read = white
      child: ListTile(
        leading: const CircleAvatar(
          backgroundImage: AssetImage("assets/images/profile.png"),
        ),
        title: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black, fontSize: 16),
            children: [
              TextSpan(
                text: '${notification.name} ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: notification.message),
            ],
          ),
        ),
        subtitle: Text(notification.time, style: const TextStyle(color: Colors.grey)),
        onTap: onTap, //  Trigger read state change when tapped
      ),
    );
  }
}
