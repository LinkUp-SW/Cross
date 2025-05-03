import 'package:flutter/material.dart';
import 'package:link_up/core/constants/endpoints.dart';
//import 'package:link_up/features/chat/widgets/document_message.dart';
import '../model/message_model.dart';
//import '../widgets/video_player.dart';
import 'package:intl/intl.dart';

class ChatMessageBubble extends StatelessWidget {
  final Message message;
  final String currentUserName;
  final String? currentUserProfilePicUrl;
  final String? chatProfilePicUrl;
  final String? senderName;
  final bool isLastSeenMessage; // Add this new property

  const ChatMessageBubble({
    Key? key,
    required this.message,
    required this.currentUserName,
    this.currentUserProfilePicUrl,
    this.chatProfilePicUrl,
    this.senderName,
    this.isLastSeenMessage = false, // Default to false
  }) : super(key: key);

  // Fix the isCurrentUser check to use sender IDs rather than names
  bool get isCurrentUser => message.senderId == InternalEndPoints.userId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Update the displayName logic to always show a friendly name
    final displayName = isCurrentUser
        ? currentUserName
        : (message.senderName.contains('-') ? (senderName ?? "Unknown User") : message.senderName);

    final displayPic = isCurrentUser ? currentUserProfilePicUrl : chatProfilePicUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Stack(
        children: [
          // Main bubble content
          Row(
            // Set all messages to start from the left
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfilePicture(displayName, displayPic),
              const SizedBox(width: 10),
              Flexible(
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
              ),
            ],
          ),

          // Seen indicator avatar - positioned on the far right
          if (isCurrentUser && message.isSeen && isLastSeenMessage)
            Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                radius: 8,
                backgroundImage: _getImageProvider("assets/images/profile.png"),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimestamp() {
    final localTime = message.timestamp.toLocal();
    final formattedTime = DateFormat('hh:mm a').format(localTime);
    return Text(
      formattedTime,
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
    // Debug the message content
    print('Message content: "${message.message}"');

    if (message.media.isNotEmpty) {
      // Handle media messages
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media content would go here

          if (message.message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  // Use the same style for all messages
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message.message,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 16, // Make text more visible
                  ),
                ),
              ),
            ),
          // Remove the old seen indicator text here
        ],
      );
    } else {
      // Text only message - remove seen indicator text here too
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.message,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 16, // Make text more visible
              ),
            ),
          ),
          // Remove the old seen indicator text here
        ],
      );
    }
  }
}
