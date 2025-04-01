import 'package:flutter/material.dart';
import '../model/chat_model.dart';

class ChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  ChatTile({required this.chat, required this.onTap});

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
            Container(
              margin: EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
      onTap: onTap, // Call the function when tapped
    );
  }
}
