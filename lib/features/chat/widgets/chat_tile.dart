import 'package:flutter/material.dart';
import '../model/chat_model.dart';

class ChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ChatTile({
    required this.chat,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(chat.profilePictureUrl),
      ),
      title: Text(
        chat.name,
        style: TextStyle(
          fontWeight: chat.isUnread ? FontWeight.bold : FontWeight.normal, // Bold if unread
        ),
      ),
      subtitle: Text(chat.lastMessage),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (chat.unreadMessageCount > 0) // Show unread count normally
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Text(
                chat.unreadMessageCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else if (chat.unreadMessageCount == -1) // Show blue dot only if marked unread via long press
            const Icon(Icons.circle, color: Colors.blue, size: 12),
          const Icon(Icons.more_vert),
        ],
      ),
    );
  }
}
