import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/chat/view/chat_screen.dart';
import '../viewModel/chat_viewmodel.dart';
import '../widgets/chat_tile.dart';

class ChatListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2), // Default LinkedIn-like background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            context.go('/');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.message, color: Colors.black),
            onPressed: () {
              // Add new message feature later
            },
          ),
        ],
      ),
      body: chats.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(16, 131, 224, 0.925),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.only(top: 8),
              itemCount: chats.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 0.6,
                color: Colors.grey,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.white, // Chat tile background white
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
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(isUnread ? Icons.mark_chat_read : Icons.mark_chat_unread),
              title: Text(isUnread ? "Mark as Read" : "Mark as Unread"),
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
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Delete Chat"),
              onTap: () {
                ref.read(chatViewModelProvider.notifier).deleteChat(index);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text("Block this Person"),
              onTap: () {
                ref.read(chatViewModelProvider.notifier).blockUser(index);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
