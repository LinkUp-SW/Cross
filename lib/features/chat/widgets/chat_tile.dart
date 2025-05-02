import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/chat_model.dart';

class ChatTile extends ConsumerWidget {
  final Chat chat;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onThreeDotPressed;

  const ChatTile({
    Key? key,
    required this.chat,
    required this.onTap,
    required this.onLongPress,
    required this.onThreeDotPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bool isUnread = chat.unreadCount > 0 || chat.conversationtype.contains("Unread");

    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(chat.senderprofilePictureUrl),
            backgroundColor: theme.colorScheme.surface,
          )
        ],
      ),
      title: Text(
        chat.sendername,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          color: theme.textTheme.titleMedium?.color,
        ),
      ),
      subtitle: Text(
        chat.lastMessage!= null ? chat.lastMessage! : " ",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          fontStyle: FontStyle.normal,
          color: theme.textTheme.bodySmall?.color,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Show unread count if present
          if (chat.unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Text(
                chat.unreadCount.toString(),
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else if (chat.conversationtype.contains("Unread"))
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