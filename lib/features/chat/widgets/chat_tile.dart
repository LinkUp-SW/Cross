import 'package:flutter/material.dart';
import '../model/chat_model.dart';

class ChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onThreeDotPressed;

  const ChatTile({
    super.key,
    required this.chat,
    required this.onTap,
    required this.onLongPress,
    required this.onThreeDotPressed,
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
          color: chat.isBlocked ? Colors.grey : Colors.black, // Grey out blocked users
        ),
      ),
      subtitle: Text(
        chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: chat.isBlocked ? Colors.grey : Colors.black, // Blocked users show grey text
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (chat.unreadMessageCount > 0) // Show unread counter normally
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
          else if (chat.isUnread) // Show blue dot when marked unread via long press
            const Icon(Icons.circle, color: Colors.blue, size: 20),
          const SizedBox(width: 8), // Add spacing
          IconButton(
            icon: const Icon(Icons.more_vert), // 3-dot menu icon
            onPressed: onThreeDotPressed, // Trigger the 3-dot pressed callback
          ),
        ],
      ),
    );
  }
}
