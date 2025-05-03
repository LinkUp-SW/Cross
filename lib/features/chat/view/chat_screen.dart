import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:link_up/features/chat/model/message_model.dart';
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
                        isLastSeenMessage: isLastSeenMessage, // Pass the new property
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

  void _sendMediaMessage(String filePath, String mediaType) {
    // Generate a unique ID for the message
    final messageId = 'temp_media_${DateTime.now().millisecondsSinceEpoch}';

    // Create media list to store file path
    final mediaList = [filePath];

    // Create a new message with the media
    final newMessage = Message(
      messageId: messageId,
      senderId: InternalEndPoints.userId,
      receiverId: otheruser,
      senderName: 'You',
      message: mediaType == "document" ? filePath : "", // For documents, store path in message
      media: mediaList,
      timestamp: DateTime.now(),
      isOwnMessage: true,
      isSeen: false,
      reacted: '',
      isEdited: false,
    );

    // Send the message through MessagesViewModel
    ref.read(messagesViewModelProvider(widget.conversationId).notifier).sendMessage(newMessage);

    // Scroll to bottom immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
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
    final theme = Theme.of(context);
    if (message.senderName != "You") {
      // Navigate to VideoPlayerScreen for videos sent by other users
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            videoPath: message.message, // Pass the video file path or URL
          ),
        ),
      );
    } else {
      // Open video directly using OpenFilex for videos sent by the current user
      try {
        await OpenFilex.open(message.message); // mediaPath
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: theme.colorScheme.error,
            content: Text(
              "Failed to open video: $e",
              style: TextStyle(color: theme.colorScheme.onError),
            ),
          ),
        );
      }
    }
  }

  Future<void> _openDocument(Message message) async {
    final filePath = message.message;
    final isUrl = filePath.startsWith('http');
    final fileName = filePath.split('/').last;

    if (isUrl) {
      final uri = Uri.parse(filePath);
      final directory = await getApplicationDocumentsDirectory();
      final localPath = '${directory.path}/$fileName';
      final localFile = File(localPath);

      if (await localFile.exists()) {
        OpenFilex.open(localPath);
      } else {
        try {
          final response = await http.get(uri);
          await localFile.writeAsBytes(response.bodyBytes);
          OpenFilex.open(localPath);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Download error: $e")),
          );
        }
      }
    } else {
      final file = File(filePath);
      if (await file.exists()) {
        OpenFilex.open(file.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("File not found")),
        );
      }
    }
  }

  Future<void> _openImage(Message message) async {
    final imagePath = message.message;
    final isUrl = imagePath.startsWith('http');

    if (isUrl) {
      _showImageInFullScreen(imagePath: imagePath);
    } else {
      final file = File(imagePath);
      if (await file.exists()) {
        _showImageInFullScreen(imagePath: file.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image not found")),
        );
      }
    }
  }

  void _showImageInFullScreen({required String imagePath}) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) => Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Center(
          child: imagePath.isEmpty
              ? Text(
                  "No image available",
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onBackground),
                )
              : imagePath.startsWith('http')
                  ? Image.network(imagePath, fit: BoxFit.contain)
                  : Image.file(File(imagePath), fit: BoxFit.contain),
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
                  final result = await FilePicker.platform.pickFiles();

                  if (result != null && result.files.single.path != null && context.mounted) {
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
