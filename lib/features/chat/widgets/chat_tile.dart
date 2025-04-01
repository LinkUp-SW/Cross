import 'package:flutter/material.dart';
import '../model/chat_model.dart';

class ChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;
  final VoidCallback onLongPress; // Added onLongPress

  ChatTile({
    required this.chat,
    required this.onTap,
    required this.onLongPress, // Added onLongPress parameter
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(chat.profilePictureUrl),
      ),
      title: Text(
        chat.name,
        style: TextStyle(
          fontWeight: chat.isUnread ? FontWeight.bold : FontWeight.normal, // Apply bold style if unread
        ),
      ),
        subtitle: Text(chat.lastMessage),
        trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(chat.timestamp),
          if (chat.isUnread)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      onTap: onTap, // Marks as read when tapped
      onLongPress: onLongPress, // Shows long-press menu to mark as read/unread
    );
  }
}
