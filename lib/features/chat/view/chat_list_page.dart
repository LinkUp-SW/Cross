import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/chat/view/chat_screen.dart'; // Import the ChatScreen
import '../viewModel/chat_viewmodel.dart';
import '../widgets/chat_tile.dart';

class ChatListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {},
          ),
        ],
      ),
      body: chats.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Color.fromRGBO(16, 131, 224, 0.925)))
          : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                return ChatTile(
                  chat: chats[index],
                  onTap: () {
                    // Mark as read if it is unread
                    ref.read(chatViewModelProvider.notifier).toggleReadUnreadStatus(index);

                    // Navigate to the ChatScreen when tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(chatIndex: index),
                      ),
                    );
                  },
                  onLongPress: () {
                    // Show read/unread options on long press
                    _showReadUnreadOption(context, ref, index, chats[index].isUnread);
                  },
                );
              },
            ),
    );
  }

  void _showReadUnreadOption(BuildContext context, WidgetRef ref, int index, bool isUnread) {
    // Display a bottom sheet with options to mark as read/unread
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(isUnread ? Icons.mark_chat_read : Icons.mark_chat_unread),
              title: Text(isUnread ? "Mark as Read" : "Mark as Unread"),
              onTap: () {
                // Toggle the read/unread status when the option is selected
                ref.read(chatViewModelProvider.notifier).markReadUnread(index);
                Navigator.pop(context); // Close the bottom sheet after selecting
              },
            ),
          ],
        );
      },
    );
  }
}
