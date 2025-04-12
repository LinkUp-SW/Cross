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
    final theme = Theme.of(context);
    final isBlocked = chat.isBlocked;

    return ListTile(
      onTap: isBlocked ? null : onTap,
      onLongPress: isBlocked ? null : onLongPress,
      leading: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(chat.profilePictureUrl),
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: isBlocked ? theme.colorScheme.onSurface.withOpacity(0.3) : null,
          ),
          if (isBlocked)
            const Icon(Icons.block, color: Colors.redAccent, size: 45),
        ],
      ),
      title: Text(
        chat.name,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: chat.isUnread ? FontWeight.bold : FontWeight.normal,
          color: isBlocked
              ? theme.disabledColor
              : theme.textTheme.titleMedium?.color,
        ),
      ),
      subtitle: Text(
        isBlocked ? "This user is blocked" : chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          fontStyle: isBlocked ? FontStyle.italic : FontStyle.normal,
          color: isBlocked
              ? theme.disabledColor
              : theme.textTheme.bodySmall?.color,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isBlocked && chat.unreadMessageCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Text(
                chat.unreadMessageCount.toString(),
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else if (!isBlocked && chat.isUnread)
            Icon(Icons.circle, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
            onPressed: onThreeDotPressed,
          ),
        ],
      ),
    );
  }
}
