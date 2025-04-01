import 'package:flutter/material.dart';
import '../widgets/chat_tile.dart'; // Import the ChatTile widget
import '../model/chat_model.dart'; // Import the Chat model
import '../viewModel/chat_viewmodel.dart';

class ChatListScreen extends StatelessWidget {
  final ChatViewModel _viewModel = ChatViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Open search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              // Navigate to new message screen
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Chat>>(
        future: _viewModel.getChats(), // Fetch chat data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No chats available.'));
          }

          final chats = snapshot.data!; // Safely access the data as a List<Chat>

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              return ChatTile(chat: chats[index]); // Use ChatTile for each chat item
            },
          );
        },
      ),
    );
  }
}
