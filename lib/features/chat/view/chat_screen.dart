/* import 'dart:io';
import 'package:file_picker/file_picker.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; 
immport 'package:link_up/features/chat/widgets/typing_indicator.dart';
import 'package:link_up/features/chat/widgets/video_player_screen.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart'; */
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

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();
  late final String otheruser;

  @override
  void initState() {
    super.initState();
    otheruser = widget.otheruserid;

    // Load messages initially
    Future.microtask(() {
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

  void _onScroll() {
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
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: messagesState.messages?.length ?? 0,
                    itemBuilder: (context, index) {
                      final message = messagesState.messages![index];

                      // Debug the message at render time
                      print('Rendering message: ID=${message.messageId}, content="${message.message}"');

                      return ChatMessageBubble(
                        key: ValueKey(message.messageId),
                        message: message,
                        currentUserName: "You",
                        currentUserProfilePicUrl: "assets/images/profile.png",
                        chatProfilePicUrl: widget.senderProfilePicUrl,
                        senderName: widget.senderName, // Pass the sender name from the ChatScreen
                      );
                    },
                  ),
          ),

          // Show typing indicator when the other user is typing
          if (messagesState.isOtherUserTyping)
            TypingIndicator(
              isTyping: true, // Always true here since we're inside the conditional
              typingUser: widget.senderName,
              currentUser: "You",
              theme: theme,
            ),

          if (messagesState.isError)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                messagesState.errorMessage ?? 'Error sending message',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ChatInputField(
            Controller: messageController,
            onSendPressed: _handleSendMessage,
            onTyping: () {
              ref.read(messagesViewModelProvider(widget.conversationId).notifier).startTyping();
            },
            onAttachmentPressed: () {
              _showAttachmentOptions(context, ref, widget.conversationId.hashCode); // Pass the chat index
            },
          )
        ],
      ),
    );
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

  @override
  void dispose() {
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
}
