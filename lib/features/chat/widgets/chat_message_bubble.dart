import 'dart:io';
import 'package:flutter/material.dart';
import 'package:link_up/core/constants/endpoints.dart';

import '../model/message_model.dart';

import 'package:intl/intl.dart';

class ChatMessageBubble extends StatelessWidget {
  final Message message;
  final String currentUserName;
  final String? currentUserProfilePicUrl;
  final String? chatProfilePicUrl;
  final String? senderName;
  final bool isLastSeenMessage;

  final Function(Message)? onMediaTap;

  // Add a retry callback
  final Function(String)? onRetryTap;

  // Add a document download callback
  final Function(Message)? onDocumentDownloadTap;

  // Update constructor accordingly
  const ChatMessageBubble({
    Key? key,
    required this.message,
    required this.currentUserName,
    this.currentUserProfilePicUrl,
    this.chatProfilePicUrl,
    this.senderName,
    this.isLastSeenMessage = false,
    this.onMediaTap,
    this.onRetryTap,
    this.onDocumentDownloadTap, // Add this new parameter
  }) : super(key: key);

  // Fix the isCurrentUser check to use sender IDs rather than names
  bool get isCurrentUser => message.senderId == InternalEndPoints.userId;

  // Add this getter to the ChatMessageBubble class:
  String get mediaType {
    if (message.media.isEmpty) return "text";

    final mediaPath = message.media[0];

    if (_isImageFile(mediaPath)) return "image";
    if (_isVideoFile(mediaPath)) return "video";

    // Check if document based on message text or media extension
    if (_isDocumentFile(mediaPath) || message.message.contains('.')) {
      return "document";
    }

    return "unknown";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Update the displayName logic to always show a friendly name
    final displayName = isCurrentUser
        ? currentUserName
        : (message.senderName.contains('-')
            ? (senderName ?? "Unknown User")
            : message.senderName);

    final displayPic =
        isCurrentUser ? currentUserProfilePicUrl : chatProfilePicUrl;

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
                backgroundImage: _getImageProvider(chatProfilePicUrl),
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
      return AssetImage(InternalEndPoints.profileUrl);
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
          // Display media content
          GestureDetector(
            onTap: () {
              if (onMediaTap != null) {
                onMediaTap!(message);
              }
            },
            child: _buildMediaContent(theme),
          ),

          // Show message text if present
          if (message.message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message.message,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      );
    } else {
      // Text only message
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
                fontSize: 16,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildMediaContent(ThemeData theme) {
    // Check if it's a network URL or local path
    final mediaUrl = message.media[0];
    final isUrl = mediaUrl.startsWith('http');

    // Create a container for the media with a nice border and shadow
    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints(
            maxWidth: 250,
            maxHeight: 300,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: theme.colorScheme.surfaceVariant, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          margin: const EdgeInsets.only(bottom: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildMediaWidget(
                _isImageFile(mediaUrl),
                _isVideoFile(mediaUrl),
                !_isImageFile(mediaUrl) && !_isVideoFile(mediaUrl),
                mediaUrl,
                isUrl,
                theme),
          ),
        ),
        // Both loading and error indicators have been removed
      ],
    );
  }

  Widget _buildMediaWidget(bool isImage, bool isVideo, bool isDocument,
      String mediaUrl, bool isUrl, ThemeData theme) {
    if (isImage) {
      // Display image
      return Stack(
        alignment: Alignment.center,
        children: [
          // Show a placeholder while loading
          Container(color: theme.colorScheme.surfaceVariant),

          // Display the actual image
          isUrl
              ? Image.network(
                  mediaUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                      ),
                    );
                  },
                )
              : Image.file(
                  File(mediaUrl),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                      ),
                    );
                  },
                ),

          // Add a tap gesture recognizer for full screen view
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onMediaTap?.call(message),
                splashColor: theme.colorScheme.primary.withOpacity(0.2),
                highlightColor: Colors.transparent,
              ),
            ),
          ),
        ],
      );
    } else if (isVideo) {
      // Display video thumbnail with play button
      return Stack(
        alignment: Alignment.center,
        children: [
          // Video thumbnail or placeholder
          Container(
            width: double.infinity,
            height: 180,
            color: theme.colorScheme.surfaceVariant,
            child: Icon(
              Icons.video_file,
              size: 48,
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
          ),

          // Play button overlay
          Icon(
            Icons.play_circle_fill_rounded,
            size: 56,
            color: theme.colorScheme.onSurfaceVariant,
          ),

          // Add a tap gesture recognizer to play the video
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onMediaTap?.call(message),
                splashColor: theme.colorScheme.primary.withOpacity(0.2),
                highlightColor: Colors.transparent,
              ),
            ),
          ),
        ],
      );
    } else {
      // Display document icon and filename with download button and nice styling
      return InkWell(
        onTap: () => onMediaTap?.call(message),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surfaceVariant,
                theme.colorScheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: message.sendProgress == MessageProgress.failed
                  ? theme.colorScheme.primary
                      .withOpacity(0.3) // Don't show error border
                  : theme.colorScheme.primary.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              // Document icon with background
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getDocumentIcon(mediaUrl),
                  size: 36,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getFileName(mediaUrl),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to open',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Add download button - only show for successfully sent documents
              if (message.sendProgress != MessageProgress.uploading &&
                  message.sendProgress != MessageProgress.failed)
                IconButton(
                  icon: Icon(
                    Icons.download_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    // Call the same handler as tapping the document
                    onMediaTap?.call(message);
                  },
                  tooltip: 'Download',
                  constraints: BoxConstraints.tightFor(width: 36, height: 36),
                  padding: EdgeInsets.zero,
                  iconSize: 24,
                ),
            ],
          ),
        ),
      );
    }
  }

  bool _isImageFile(String path) {
    final lowercasePath = path.toLowerCase();
    return lowercasePath.endsWith('.jpg') ||
        lowercasePath.endsWith('.jpeg') ||
        lowercasePath.endsWith('.png') ||
        lowercasePath.endsWith('.gif') ||
        lowercasePath.endsWith('.webp') ||
        lowercasePath.contains('/image/');
  }

  bool _isVideoFile(String path) {
    final lowercasePath = path.toLowerCase();
    return lowercasePath.endsWith('.mp4') ||
        lowercasePath.endsWith('.mov') ||
        lowercasePath.endsWith('.avi') ||
        lowercasePath.endsWith('.mkv') ||
        lowercasePath.contains('/video/');
  }

  bool _isDocumentFile(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.pdf') ||
        ext.endsWith('.doc') ||
        ext.endsWith('.docx') ||
        ext.endsWith('.txt') ||
        ext.endsWith('.xlsx') ||
        ext.contains('/document/') || // For Android content URIs
        ext.contains('document'); // Fallback for messages with document in path
  }

  // Add this method to better detect document messages
  bool _isDocumentMessage(Message message) {
    // First check if media exists
    if (message.media.isEmpty) return false;

    final mediaPath = message.media[0].toLowerCase();

    // Check directly for PDF extension
    if (mediaPath.endsWith('.pdf')) return true;

    // Check other document extensions
    if (_isDocumentFile(mediaPath)) return true;

    // Check if message contains document filename
    if (message.message.isNotEmpty &&
        (message.message.contains('.pdf') ||
            message.message.contains('.doc') ||
            message.message.contains('.txt') ||
            message.message.contains('.xls'))) {
      return true;
    }

    // Check for document indicators in URL
    if (mediaPath.contains('document') ||
        mediaPath.contains('/pdf') ||
        mediaPath.contains('application/')) {
      return true;
    }

    return false;
  }

  String _getFileName(String path) {
    return path.split('/').last;
  }

  IconData _getDocumentIcon(String path) {
    final lowercasePath = path.toLowerCase();

    if (lowercasePath.endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (lowercasePath.endsWith('.doc') ||
        lowercasePath.endsWith('.docx')) {
      return Icons.description;
    } else if (lowercasePath.endsWith('.xls') ||
        lowercasePath.endsWith('.xlsx')) {
      return Icons.table_chart;
    } else if (lowercasePath.endsWith('.txt')) {
      return Icons.text_snippet;
    } else {
      return Icons.insert_drive_file;
    }
  }
}
