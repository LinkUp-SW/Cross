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
    final isBlocked = chat.isBlocked;

    return ListTile(
      onTap: isBlocked ? null : onTap,
      onLongPress: isBlocked ? null : onLongPress,
      leading: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(chat.profilePictureUrl),
            foregroundColor: isBlocked ? Colors.black.withOpacity(0.3) : null,
            backgroundColor: Colors.grey.shade200,
          ),
          if (isBlocked)
            const Icon(Icons.block, color: Colors.redAccent, size:45),
        ],
      ),
      title: Text(
        chat.name,
        style: TextStyle(
          fontWeight: chat.isUnread ? FontWeight.bold : FontWeight.normal,
          color: isBlocked ? Colors.grey : Colors.black,
        ),
      ),
      subtitle: Text(
        isBlocked ? "This user is blocked" : chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontStyle: isBlocked ? FontStyle.italic : FontStyle.normal,
          color: isBlocked ? Colors.grey : Colors.black,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isBlocked && chat.unreadMessageCount > 0)
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
          else if (!isBlocked && chat.isUnread)
            const Icon(Icons.circle, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: onThreeDotPressed,
          ),
        ],
      ),
    );
  }
}
