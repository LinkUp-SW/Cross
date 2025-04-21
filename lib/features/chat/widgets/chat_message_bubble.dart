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
  final bool isLastMessage; // Flag to determine if this is the last message sent by the current user

  const ChatMessageBubble({
    Key? key,
    required this.message,
    required this.currentUserName,
    this.currentUserProfilePicUrl,
    this.chatProfilePicUrl,
    required this.isLastMessage, // Receive the flag
  }) : super(key: key);

  bool get isCurrentUser => message.sender == currentUserName;

  @override
  Widget build(BuildContext context) {
    final displayName = isCurrentUser ? currentUserName : message.sender;
    final displayPic = isCurrentUser ? currentUserProfilePicUrl : chatProfilePicUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfilePicture(displayName, displayPic), // Profile picture of the sender
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align message content to the left
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
          if (isCurrentUser && isLastMessage) _buildReadReceipt(), // Show read receipt for the last message
        ],
      ),
    );
  }

  Widget _buildProfilePicture(String name, String? url) {
    final imageProvider = _getImageProvider(url);
    return CircleAvatar(
      radius: 20,
      backgroundImage: imageProvider,
      backgroundColor: Colors.transparent,
    );
  }

  ImageProvider _getImageProvider(String? url) {
    if (url == null) {
      return const AssetImage("assets/images/profile.png");
    } else if (url.startsWith('http')) {
      return NetworkImage(url);
    } else {
      return AssetImage(url);
    }
  }

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
    bool isNetworkVideo = message.content.startsWith('http');
    return VideoPlayerWidget(
      mediaPath: message.content,
      isNetwork: isNetworkVideo,
    );
  }

  Widget _buildTimestamp() {
    final timestamp = message.timestamp;
    return Text(
      "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}",
      style: const TextStyle(fontSize: 12, color: Colors.grey),
    );
  }

  Widget _buildReadReceipt() {
    return Align(
      alignment: Alignment.centerRight, // Align the read receipt to the extreme right
      child: _getReadReceiptIcon(message.deliveryStatus),
    );
  }

  Widget _getReadReceiptIcon(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.sent:
        return const Icon(Icons.check, size: 16, color: Colors.grey);
      case DeliveryStatus.delivered:
        return Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          child: const Icon(Icons.check, size: 12, color: Colors.white),
        );
      case DeliveryStatus.read:
        // Display the profile picture of the other user for "read" status
        return CircleAvatar(
          radius: 8,
          backgroundImage: _getImageProvider(chatProfilePicUrl),
        );
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
