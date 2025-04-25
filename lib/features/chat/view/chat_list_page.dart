import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/chat/view/chat_screen.dart';
import 'package:link_up/features/chat/view/new_chat_screen.dart';
import '../viewModel/chat_viewmodel.dart';
import '../widgets/chat_tile.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final chats = ref.watch(chatViewModelProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () {
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.message, color: theme.iconTheme.color),
             onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewChatScreen()),
    );
  },
          ),
        ],
      ),
      body: chats.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.only(top: 8),
              itemCount: chats.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 0.6,
                color: theme.dividerColor,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                return Container(
                  color: theme.cardColor,
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: ChatTile(
                    chat: chats[index],
                    onTap: () {
                      ref.read(chatViewModelProvider.notifier).toggleReadUnreadStatus(index);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(chatIndex: index),
                        ),
                      );
                    },
                    onLongPress: () {
                      _showReadUnreadOption(context, ref, index, chats[index].isUnread);
                    },
                    onThreeDotPressed: () {
                      _showChatOptions(context, ref, index);
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showReadUnreadOption(BuildContext context, WidgetRef ref, int index, bool isUnread) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(
                isUnread ? Icons.mark_chat_read : Icons.mark_chat_unread,
                color: theme.iconTheme.color,
              ),
              title: Text(
                isUnread ? "Mark as Read" : "Mark as Unread",
                style: theme.textTheme.bodyMedium,
              ),
              onTap: () {
                ref.read(chatViewModelProvider.notifier).markReadUnread(index);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showChatOptions(BuildContext context, WidgetRef ref, int index) {
    final chat = ref.read(chatViewModelProvider)[index];
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.delete, color: theme.iconTheme.color),
              title: Text("Delete Chat", style: theme.textTheme.bodyMedium),
              onTap: () {
                ref.read(chatViewModelProvider.notifier).deleteChat(index);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                chat.isBlocked ? Icons.lock_open : Icons.block,
                color: theme.iconTheme.color,
              ),
              title: Text(
                chat.isBlocked ? "Unblock this Person" : "Block this Person",
                style: theme.textTheme.bodyMedium,
              ),
              onTap: () {
                if (chat.isBlocked) {
                  ref.read(chatViewModelProvider.notifier).unblockUser(index);
                } else {
                  ref.read(chatViewModelProvider.notifier).blockUser(index);
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
