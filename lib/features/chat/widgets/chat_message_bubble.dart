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

  bool get isCurrentUser => message.sender == currentUserName;

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
                _buildTimestamp(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build the profile picture based on user data
  Widget _buildProfilePicture(String name, String? url) {
    final imageProvider = _getImageProvider(url);
    return CircleAvatar(
      radius: 20,
      backgroundImage: imageProvider,
      backgroundColor: Colors.transparent,
    );
  }

  // Determine which image provider to use based on the URL or fallback
  ImageProvider _getImageProvider(String? url) {
    if (url == null) {
      return const AssetImage("assets/images/profile.png");
    } else if (url.startsWith('http')) {
      return NetworkImage(url);
    } else {
      return AssetImage(url);
    }
  }

  // Build the message content based on the message type
  Widget _buildMessageContent() {
    switch (message.type) {
      case MessageType.text:
        return Text(message.content);

      case MessageType.image:
        return _buildImageMessage();

      case MessageType.video:
        return _buildVideoMessage();

      case MessageType.document:
        return DocumentMessageWidget(message: message);

      default:
        return const SizedBox.shrink();
    }
  }

  // Helper method to handle image loading
  Widget _buildImageMessage() {
    final isNetworkImage = message.content.startsWith('http');
    return isNetworkImage
        ? Image.network(
            message.content,
            errorBuilder: (context, error, stackTrace) => _errorWidget("Failed to load image"),
          )
        : Image.file(
            File(message.content),
            errorBuilder: (context, error, stackTrace) => _errorWidget("Failed to load image"),
          );
  }
    Widget _buildVideoMessage() {
    bool isNetworkVideo = message.content.startsWith('http'); // Check if the video path is a URL
    return VideoPlayerWidget(
      mediaPath: message.content,
      isNetwork: isNetworkVideo,
    );
  }
  // Display the timestamp of the message
  Widget _buildTimestamp() {
    final timestamp = message.timestamp;
    return Text(
      "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}",
      style: const TextStyle(fontSize: 12, color: Colors.grey),
    );
  }

  // Error widget for when an image or content fails to load
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
