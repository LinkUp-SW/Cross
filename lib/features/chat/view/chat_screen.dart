import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewModel/chat_viewmodel.dart';
import '../model/chat_model.dart';

class ChatScreen extends ConsumerWidget {
  final int chatIndex; // The index of the selected chat

  const ChatScreen({Key? key, required this.chatIndex}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatViewModelProvider);
    final chat = chats[chatIndex]; // Get the selected chat

    // Text controller for the message input field
    final messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(chat.name),
      ),
      body: Column(
        children: [
          // Chat messages display
          Expanded(
            child: ListView.builder(
              itemCount: chat.messages.length,
              itemBuilder: (context, index) {
                final message = chat.messages[index];
                return ListTile(
                  title: Text(message.sender),
                  subtitle: Text(message.content),
                  trailing: Text(
                    "${message.timestamp.hour}:${message.timestamp.minute}",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          
          // Message input field and send button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      // Send the message
                      ref.read(chatViewModelProvider.notifier).sendMessage(chatIndex, messageController.text);
                      messageController.clear(); // Clear the text field after sending
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
