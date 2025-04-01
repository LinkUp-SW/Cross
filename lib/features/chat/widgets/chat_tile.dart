import 'package:flutter/material.dart';
import '../model/chat_model.dart';
import 'unread_message_counter.dart'; // Import the widget for the blue dot

class ChatTile extends StatelessWidget {
  final Chat chat;

  ChatTile({required this.chat});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(chat.profilePictureUrl),
      ),
      title: Text(chat.name),
      subtitle: Text(chat.lastMessage),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(chat.timestamp),
          if (chat.isUnread)
            UnreadMessageCounter(), // Show blue dot for unread messages
        ],
      ),
    );
  }
}
