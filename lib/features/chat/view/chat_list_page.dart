import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "../viewModel/chat_viewmodel.dart";
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
          ? const Center(child: Text('No chats available.'))
          : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                return ChatTile(
                  chat: chats[index],
                  onTap: () {
                    ref
                        .read(chatViewModelProvider.notifier)
                        .toggleReadUnreadStatus(index);
                  },
                );
              },
            ),
    );
  }
}
