import 'package:flutter/material.dart';
import 'package:link_up/features/chat/widgets/document_message.dart';
import '../model/chat_model.dart';
import 'dart:io'; 
import '../widgets/video_player.dart';

class ChatMessageBubble extends StatelessWidget {
  final Message message;
  final String currentUserName;
  final String? currentUserProfilePicUrl;
  final String? chatProfilePicUrl;

  const ChatMessageBubble({
    Key? key,
    required this.message,
    required this.currentUserName,
    this.currentUserProfilePicUrl,
    this.chatProfilePicUrl,
  }) : super(key: key);

  bool get isCurrentUser {
    print("Checking sender: ${message.sender}, currentUser: $currentUserName");
    return message.sender == currentUserName;
  }

  Widget build(BuildContext context) {
    final displayName = isCurrentUser ? currentUserName : message.sender;
    final displayPic = isCurrentUser ? currentUserProfilePicUrl : chatProfilePicUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfilePicture(displayName, displayPic),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                _buildMessageContent(),
                const SizedBox(height: 4),
                Text(
                  "${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(String name, String? url) {
    ImageProvider imageProvider;

    if (url == null) {
      imageProvider = const AssetImage("assets/images/profile.png");
    } else if (url.startsWith('http')) {
      imageProvider = NetworkImage(url);
    } else {
      imageProvider = AssetImage(url);
    }

    return CircleAvatar(
      radius: 20,
      backgroundImage: imageProvider,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildMessageContent() {
  switch (message.type) {
    case MessageType.text:
      return Text(message.content);

    case MessageType.image:
      if (message.content.startsWith('http')) {
        return Image.network(
          message.content,
          errorBuilder: (context, error, stackTrace) => _errorWidget("Failed to load image"),
        );
      } else {
        return Image.file(
          File(message.content),
          errorBuilder: (context, error, stackTrace) => _errorWidget("Failed to load image"),
        );
      }

    case MessageType.video:
      return CustomVideoPlayer(videoPath: message.content); 

    case MessageType.document:
       return DocumentMessageWidget(message: message);
      

    default:
      return const SizedBox.shrink();
  }
}
 



  Widget _errorWidget(String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error, color: Colors.red),
        Text(message, style: const TextStyle(color: Colors.red)),
      ],
    );
  }
}


