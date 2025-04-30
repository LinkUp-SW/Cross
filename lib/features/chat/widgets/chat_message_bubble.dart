import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:link_up/features/chat/widgets/document_message.dart';
import '../model/message_model.dart';
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

  bool get isCurrentUser => message.senderName == currentUserName;

 

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
        final displayName = message.isOwnMessage ? currentUserName : message.senderName;
    final displayPic = message.isOwnMessage ? currentUserProfilePicUrl : chatProfilePicUrl;

    

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
                _buildMessageContent(theme),
                const SizedBox(height: 4),
                _buildTimestamp()
              ],
              
             
            ),
          
          
            /* if (message.isSeen)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _buildTimestamp(),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.done_all,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ), */)
         ],
    )
    ); 
  }
      
  

 Widget _buildTimestamp() {
    final timestamp = message.timestamp;
    return Text(
      "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}",
      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
    if (url == null || url.isEmpty) {
      return const AssetImage("assets/images/profile.png");
    } else if (url.startsWith('http')) {
      return NetworkImage(url);
    } else {
      return AssetImage(url);
    }
  }
  Widget _buildMessageContent(ThemeData theme) {
    if (message.media.isNotEmpty) {
      // Handle media messages
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* _buildMediaContent(message.media.first), */
          if (message.message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                message.message,
                style: TextStyle(
                  color: isCurrentUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                ),
              ),
            ),
        ],
      );
    } else {
      // Text only message
      return Text(
        message.message,
        style: TextStyle(
          color: isCurrentUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
        ),
      );
    }
  }

  /* 
/* 
  Widget _buildMediaContent(String mediaUrl) {
    if (mediaUrl.endsWith('.jpg') || mediaUrl.endsWith('.png')) {
      return _buildImageMessage(mediaUrl);
    } else if (mediaUrl.endsWith('.mp4')) {
      return _buildVideoMessage(mediaUrl);
    } else {
      return DocumentMessageWidget(message: message);
    }
  }
 */
  Widget _buildImageMessage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        height: 200,
        width: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _errorWidget("Failed to load image"),
      ),
    );
  }

  Widget _buildVideoMessage(String videoUrl) {
    return VideoPlayerWidget(
      mediaPath: videoUrl,
      isNetwork: true,
    );
  }

  Widget _buildProfilePicture(String name, String? url) {
    return CircleAvatar(
      radius: 16,
      backgroundImage: _getImageProvider(url),
      backgroundColor: Colors.grey[300],
      child: url == null ? Text(name[0]) : null,
    );
  }

  ImageProvider _getImageProvider(String? url) {
    if (url == null || url.isEmpty) {
      return const AssetImage("assets/images/profile.png");
    } else if (url.startsWith('http')) {
      return NetworkImage(url);
    } else {
      return AssetImage(url);
    }
  }

  Widget _buildTimestamp() {
    return Text(
      "${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}",
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildSeenIndicator() {
    return CircleAvatar(
      radius: 8,
      backgroundImage: _getImageProvider(chatProfilePicUrl),
      backgroundColor: Colors.grey[300],
    );
  }

  Widget _errorWidget(String message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error, color: Colors.red, size: 24),
        Text(
          message,
          style: const TextStyle(color: Colors.red),
        ),
      ],
    );
  } */
}
