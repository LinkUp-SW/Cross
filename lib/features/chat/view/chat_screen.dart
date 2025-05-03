import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:link_up/features/chat/model/message_model.dart';
import 'package:link_up/features/chat/utils/media_helper.dart' as media; // Use prefix instead of hide
import 'package:link_up/features/chat/utils/document_handler.dart';
import 'package:link_up/features/chat/widgets/typing_indicator.dart';
import 'package:link_up/features/chat/widgets/video_player_screen.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../viewModel/chat_viewmodel.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/chat/viewModel/messages_viewmodel.dart';
import 'dart:developer';
import 'package:path/path.dart' as path;

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String senderName;
  final String senderProfilePicUrl;
  final String otheruserid;

  const ChatScreen({
    Key? key,
    required this.otheruserid,
    required this.conversationId,
    required this.senderName,
    required this.senderProfilePicUrl,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();
  late final String otheruser;

  bool _isAtBottom = false;
  bool _hasMarkedAsRead = false;

  @override
  void initState() {
    super.initState();
    otheruser = widget.otheruserid;

    // Add app lifecycle listener
    WidgetsBinding.instance.addObserver(this);

    // Set this conversation as actively being viewed
    Future.microtask(() {
      ref.read(messagesViewModelProvider(widget.conversationId).notifier).setActiveViewStatus(true);

      log('Initializing chat screen for conversation: ${widget.conversationId}');
      ref.read(messagesViewModelProvider(widget.conversationId).notifier).loadMessages().then((_) {
        // Scroll to bottom after messages are loaded
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      });
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mark messages as read when screen gets focus
    _checkIfAtBottom();
  }

  @override
  void dispose() {
    // Set chat as no longer active when leaving the screen
    if (mounted) {
      ref.read(messagesViewModelProvider(widget.conversationId).notifier).setActiveViewStatus(false);
    }

    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    messageController.dispose();

    // Properly close the socket connection before invalidating the provider
    try {
      log('[CHAT] Disposing chat screen for conversation: ${widget.conversationId}');

      // Get socket service reference before invalidating the provider
      final socketProvider = ref.read(messagesViewModelProvider(widget.conversationId).notifier);

      // Signal to the socket service that this conversation is ending
      socketProvider.cleanupSocketConnection();

      // Use a more controlled approach to invalidate the provider after cleanup
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          // Only invalidate if still mounted to avoid errors
          ref.invalidate(messagesViewModelProvider(widget.conversationId));
          log('[CHAT] Successfully invalidated message provider for: ${widget.conversationId}');
        }
      });
    } catch (e) {
      log('[CHAT] Error during chat screen disposal: $e');
    }

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (!mounted) return;

    switch (state) {
      case AppLifecycleState.resumed:
        // App is visible and active - set active status and check if at bottom
        ref.read(messagesViewModelProvider(widget.conversationId).notifier).setActiveViewStatus(true);
        // Only check if at bottom after making active
        _checkIfAtBottom();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App is not visible - user cannot see messages
        ref.read(messagesViewModelProvider(widget.conversationId).notifier).setActiveViewStatus(false);
        _hasMarkedAsRead = false; // Reset this flag when app goes to background
        break;
    }
  }

  void _onScroll() {
    // Check if we're at bottom to mark messages as read
    _checkIfAtBottom();

    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // Load more messages when reaching the bottom
      // ref.read(messagesViewModelProvider(widget.conversationId).notifier).loadMoreMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messagesState = ref.watch(messagesViewModelProvider(widget.conversationId));

    log('Building chat screen. Messages count: ${messagesState.messages?.length ?? 0}');
    log('Other user typing: ${messagesState.isOtherUserTyping}');

    // Scroll to bottom whenever messages update and loading completes
    if (!messagesState.isLoading && messagesState.messages != null && messagesState.messages!.isNotEmpty) {
      // Use post frame callback to ensure the list view is built before scrolling
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await ref.read(chatViewModelProvider.notifier).fetchChats(); // Fetch updated chat list
            if (context.mounted) {
              Navigator.of(context).pop(); // Return to chat list screen
            }
          },
        ),
        title: Text(
          widget.senderName,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesState.isLoading && (messagesState.messages?.isEmpty ?? true)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Chat bubble loading animation
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (int i = 0; i < 3; i++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: Duration(milliseconds: 600 + (i * 200)),
                                    builder: (context, value, _) {
                                      return Transform.scale(
                                        scale: 0.6 + (0.4 * value),
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary.withOpacity(0.4 + (0.6 * value)),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      );
                                    },
                                    // Repeat the animation continuously
                                    onEnd: () {
                                      setState(() {});
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading conversation...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: messagesState.messages?.length ?? 0,
                    itemBuilder: (context, index) {
                      final message = messagesState.messages![index];

                      // Find the last seen message (newest one)
                      bool isLastSeenMessage = false;
                      if (message.isSeen && message.isOwnMessage == true) {
                        // Check if this is the last seen message by looking ahead
                        bool isLast = true;
                        for (int i = index + 1; i < messagesState.messages!.length; i++) {
                          if (messagesState.messages![i].isSeen && messagesState.messages![i].isOwnMessage == true) {
                            isLast = false;
                            break;
                          }
                        }
                        isLastSeenMessage = isLast;
                      }

                      // If we're at the bottom of the list and haven't marked messages as read yet
                      if (index == messagesState.messages!.length - 1) {
                        // Use post frame callback to check if user is at bottom
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _checkIfAtBottom();
                        });
                      }

                      return ChatMessageBubble(
                        key: ValueKey(message.messageId),
                        message: message,
                        currentUserName: "You",
                        currentUserProfilePicUrl: "assets/images/profile.png",
                        chatProfilePicUrl: widget.senderProfilePicUrl,
                        senderName: widget.senderName,
                        isLastSeenMessage: isLastSeenMessage,
                        // Use single callback for all media types
                        onMediaTap: _openMedia,
                      );
                    },
                  ),
          ),

          // Show typing indicator when the other user is typing
          if (messagesState.isOtherUserTyping)
            TypingIndicator(
              isTyping: messagesState.isOtherUserTyping, // Always true here since we're inside the conditional
              typingUser: widget.senderName,
              currentUser: "You",
              theme: theme,
            ),

          // Show error indicator when there's an error
          if (messagesState.isError)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.errorContainer,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    // Animated error icon
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, value, _) {
                        return Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer.withOpacity(value * 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
                              size: 24,
                            ),
                          ),
                        );
                      },
                      onEnd: () {
                        // Restart animation for pulsing effect
                        if (mounted) setState(() {});
                      },
                    ),
                    const SizedBox(width: 12),
                    // Error message
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connection Issue',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            messagesState.errorMessage ?? 'Error loading messages',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Retry button
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () {
                        // Retry loading messages
                        ref.read(messagesViewModelProvider(widget.conversationId).notifier).loadMessages();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ChatInputField(
            Controller: messageController,
            onSendPressed: _handleSendMessage,
            onTyping: _handleTypingStarted, // Use the new method
            onAttachmentPressed: () {
              _showAttachmentOptions(context, ref, widget.conversationId.hashCode);
            },
          )
        ],
      ),
    );
  }

  void _checkIfAtBottom() {
    if (!_scrollController.hasClients) return;

    // Make the threshold stricter and add time-based verification
    final isAtVeryBottom =
        _scrollController.position.pixels > (_scrollController.position.maxScrollExtent - 5); // Reduced to 5px

    // Add additional check - must be at bottom AND have been there for a bit
    if (isAtVeryBottom && !_hasMarkedAsRead) {
      // Use delayed execution to confirm user is intentionally at bottom
      Future.delayed(Duration(milliseconds: 500), () {
        // Check again if still at bottom and view is still active
        if (!mounted) return;

        final stillAtBottom = _scrollController.hasClients &&
            _scrollController.position.pixels > (_scrollController.position.maxScrollExtent - 5);

        if (stillAtBottom) {
          ref.read(messagesViewModelProvider(widget.conversationId).notifier).markConversationAsRead();
          _hasMarkedAsRead = true;
          log('[CHAT] Marked messages as read - user confirmed at bottom');
        }
      });
    } else if (!isAtVeryBottom && _hasMarkedAsRead) {
      // Reset flag if user scrolls away from bottom
      _hasMarkedAsRead = false;
    }
  }

  void _handleSendMessage() {
    if (messageController.text.isEmpty) return;

    final messageText = messageController.text.trim();

    // Debug logging
    print('Sending message: "$messageText"');

    final newMessage = Message(
      messageId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      senderId: InternalEndPoints.userId,
      receiverId: otheruser,
      senderName: 'You', // Simplified display name for current user
      message: messageText, // Make sure this is not empty
      media: [],
      timestamp: DateTime.now(),
      isOwnMessage: true,
      isSeen: false,
      reacted: '',
      isEdited: false,
    );

    // Clear input field immediately
    messageController.clear();

    // Send message
    ref.read(messagesViewModelProvider(widget.conversationId).notifier).sendMessage(newMessage);

    // Scroll to bottom immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _sendMediaMessage(String filePath, String mediaType) async {
    if (!mounted) return;

    final file = File(filePath);
    if (!await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selected file doesn't exist or was deleted")),
      );
      return;
    }

    final fileSize = await file.length();
    final fileName = path.basename(filePath);

    // Generate a unique ID for the message
    final messageId = 'temp_media_${DateTime.now().millisecondsSinceEpoch}';

    try {
      // Show loading indicator with progress updates
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(mediaType == "video"
                    ? "Processing video...\nCompressing if needed."
                    : "Processing media...\nThis may take a moment."),
              ],
            ),
          ),
        );
      }

      // Create a temporary message to show immediately in UI
      final tempMessage = Message(
        messageId: messageId,
        senderId: InternalEndPoints.userId,
        receiverId: otheruser,
        senderName: 'You',
        message: mediaType == "document" ? fileName : "",
        media: [filePath], // Local path for preview
        timestamp: DateTime.now(),
        isOwnMessage: true,
        isSeen: false,
        reacted: '',
        isEdited: false,
        sendProgress: MessageProgress.uploading,
        localMediaPath: filePath,
      );

      // Add temporary message to UI
      ref.read(messagesViewModelProvider(widget.conversationId).notifier).addLocalMessage(tempMessage);

      // Mark document messages as sent immediately
      if (mediaType == "document") {
        ref
            .read(messagesViewModelProvider(widget.conversationId).notifier)
            .updateMessageProgress(messageId, MessageProgress.sent);
      }

      // Scroll to bottom immediately
      _scrollToBottom();

      // Process media in background with one unified method
      final base64Data = await media.MediaHelper.prepareMediaForUpload(filePath);

      // Close loading dialog
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Send the media message
      await ref
          .read(messagesViewModelProvider(widget.conversationId).notifier)
          .sendMediaMessage(messageId, [base64Data]);

      // Mark as successfully sent
      ref
          .read(messagesViewModelProvider(widget.conversationId).notifier)
          .updateMessageProgress(messageId, MessageProgress.sent);
    } catch (e) {
      // Close loading dialog if still showing
      if (context.mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Update message status to failed
      ref
          .read(messagesViewModelProvider(widget.conversationId).notifier)
          .updateMessageProgress(messageId, MessageProgress.failed);

      // Show error with retry option
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_formatErrorMessage(e.toString())),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _sendMediaMessage(filePath, mediaType),
            ),
            duration: const Duration(seconds: 8),
          ),
        );
      }
      log('[CHAT] Error sending media: $e');
    }
  }

  // Helper to format user-friendly error messages
  String _formatErrorMessage(String error) {
    if (error.contains("too large")) {
      return "File is too large. Please choose a smaller file.";
    } else if (error.contains("timeout") || error.contains("Timeout")) {
      return "Upload timed out. Try a smaller file or check your connection.";
    }
    return "Failed to send: $error";
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      try {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        log('[CHAT] Scrolled to bottom');
      } catch (e) {
        log('[CHAT] Error scrolling to bottom: $e');
      }
    } else {
      log('[CHAT] Scroll controller has no clients yet');
    }
  }

  Future<void> _handleVideoMessage(Message message) async {
    try {
      final videoUrl = message.media[0];
      log('[CHAT] Opening video: $videoUrl');

      _logMediaDetails(videoUrl, "video");

      if (videoUrl.startsWith('http')) {
        // For network videos, open directly
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(videoPath: videoUrl),
          ),
        );
      } else {
        // For local videos, check if file exists
        final file = File(videoUrl);
        if (await file.exists()) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(videoPath: videoUrl),
            ),
          );
        } else {
          // Show error
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Video file not found")),
            );
          }
        }
      }
    } catch (e) {
      log('[CHAT] Error handling video: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to open video: $e")),
        );
      }
    }
  }

  Future<void> _openDocument(Message message) async {
    try {
      final filePath = message.media.isNotEmpty ? message.media[0] : message.message;
      final isUrl = filePath.startsWith('http');
      final fileName = path.basename(filePath);

      log('[CHAT] Opening document: $filePath');

      // Always update status to sent
      ref
          .read(messagesViewModelProvider(widget.conversationId).notifier)
          .updateMessageProgress(message.messageId, MessageProgress.sent);

      if (isUrl) {
        final uri = Uri.parse(filePath);
        final directory = await getApplicationDocumentsDirectory();
        final localPath = '${directory.path}/$fileName';
        final localFile = File(localPath);

        try {
          if (await localFile.exists()) {
            await OpenFilex.open(localPath);
          } else {
            // Download silently without dialog
            final response = await http.get(uri);
            if (response.statusCode == 200) {
              await localFile.writeAsBytes(response.bodyBytes);
              await OpenFilex.open(localPath);
            }
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Download error: $e")),
            );
          }
        }
      } else {
        // Handle local files...
      }
    } catch (e) {
      // Error handling...
    }
  }

  Future<void> _openImage(Message message) async {
    // Check if media exists in the message
    if (message.media.isEmpty) {
      log('[CHAT] No media found in message');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No image to display")),
        );
      }
      return;
    }

    // Use media[0] instead of message.message for image path
    final imagePath = message.media[0];
    final isUrl = imagePath.startsWith('http');

    // Log image details for debugging
    _logMediaDetails(imagePath, "image");

    if (isUrl) {
      _showImageInFullScreen(imagePath: imagePath);
    } else {
      final file = File(imagePath);
      if (await file.exists()) {
        _showImageInFullScreen(imagePath: file.path);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Image not found")),
          );
        }
      }
    }
  }

  Future<void> _openMedia(Message message) async {
    if (message.media.isEmpty) {
      log('[CHAT] No media found in message');
      return;
    }

    final mediaPath = message.media[0];
    final fileExt = path.extension(mediaPath).toLowerCase();

    // Force document messages to always show as sent
    if (!media.MediaHelper.isImageFile(fileExt) && !media.MediaHelper.isVideoFile(fileExt)) {
      // This is a document - force status to sent
      ref
          .read(messagesViewModelProvider(widget.conversationId).notifier)
          .updateMessageProgress(message.messageId, MessageProgress.sent);
    }

    try {
      // Handle media based on type
      if (media.MediaHelper.isImageFile(fileExt)) {
        _logMediaDetails(mediaPath, "image");
        _openImage(message);
      } else if (media.MediaHelper.isVideoFile(fileExt)) {
        _logMediaDetails(mediaPath, "video");
        _handleVideoMessage(message);
      } else {
        _logMediaDetails(mediaPath, "document");
        _openDocument(message);
      }
    } catch (e) {
      log('[CHAT] Error opening media: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error opening media: $e")),
        );
      }
    }
  }

  void _logMediaDetails(String mediaPath, String mediaType) {
    try {
      if (mediaPath.startsWith('http')) {
        log('[CHAT] $mediaType is a network URL: $mediaPath');
      } else {
        final file = File(mediaPath);
        file.exists().then((exists) {
          if (exists) {
            file.length().then((size) {
              log('[CHAT] Local $mediaType exists. Size: ${(size / 1024).toStringAsFixed(2)}KB, Path: $mediaPath');
            });
          } else {
            log('[CHAT] Local $mediaType does not exist: $mediaPath');
          }
        });
      }
    } catch (e) {
      log('[CHAT] Error checking $mediaType: $e');
    }
  }

  void _showImageInFullScreen({required String imagePath}) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Center(
          child: imagePath.isEmpty
              ? Text(
                  "No image available",
                  style: const TextStyle(color: Colors.white),
                )
              : imagePath.startsWith('http')
                  ? Image.network(
                      imagePath,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        log('[CHAT] Error loading network image: $error');
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 16),
                              const Text(
                                "Failed to load image",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : Image.file(
                      File(imagePath),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        log('[CHAT] Error loading local image: $error');
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 16),
                              const Text(
                                "Failed to load image",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context, WidgetRef ref, int chatIndex) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: theme.colorScheme.primary),
                title: Text("Take Photo", style: theme.textTheme.bodyLarge),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.camera);

                  if (pickedFile != null && context.mounted) {
                    _sendMediaMessage(pickedFile.path, "image");
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam, color: theme.colorScheme.primary),
                title: Text("Record Video", style: theme.textTheme.bodyLarge),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickVideo(source: ImageSource.camera);

                  if (pickedFile != null && context.mounted) {
                    _sendMediaMessage(pickedFile.path, "video");
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: theme.colorScheme.primary),
                title: Text("Photo Library", style: theme.textTheme.bodyLarge),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

                  if (pickedFile != null && context.mounted) {
                    _sendMediaMessage(pickedFile.path, "image");
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.video_library, color: theme.colorScheme.primary),
                title: Text("Video Library", style: theme.textTheme.bodyLarge),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

                  if (pickedFile != null && context.mounted) {
                    _sendMediaMessage(pickedFile.path, "video");
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.insert_drive_file, color: theme.colorScheme.primary),
                title: Text("Document", style: theme.textTheme.bodyLarge),
                onTap: () async {
                  Navigator.pop(context);

                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xlsx'],
                  );

                  if (result != null &&
                      result.files.isNotEmpty &&
                      result.files.single.path != null &&
                      context.mounted) {
                    _sendMediaMessage(result.files.single.path!, "document");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTypingStarted() {
    // Only send the typing notification to the other user
    // Don't trigger any local UI update for our own typing
    if (mounted) {
      // Just notify the other user that we're typing
      ref.read(messagesViewModelProvider(widget.conversationId).notifier).startTyping();
    }
  }
}
