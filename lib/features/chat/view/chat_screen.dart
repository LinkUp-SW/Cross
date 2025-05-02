/* import 'dart:io';
import 'package:file_picker/file_picker.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; 
immport 'package:link_up/features/chat/widgets/typing_indicator.dart';
import 'package:link_up/features/chat/widgets/video_player_screen.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart'; */
import 'package:link_up/features/chat/model/message_model.dart';
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
      ref.read(messagesViewModelProvider(widget.conversationId).notifier).loadMessages();
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
                      return ChatMessageBubble(
                        key: ValueKey(message.messageId), // Add key for better list updates
                        message: message,
                        currentUserName:
                            '${InternalEndPoints.userId.split('-')[0][0].toUpperCase()}${InternalEndPoints.userId.split('-')[0].substring(1)}',
                        currentUserProfilePicUrl: "assets/images/profile.png",
                        chatProfilePicUrl: widget.senderProfilePicUrl,
                      );
                    },
                  ),
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
          ),
        ],
      ),
    );
  }

  void _handleSendMessage() {
    if (messageController.text.isEmpty) return;

    final newMessage = Message(
      messageId: DateTime.now().toString(),
      senderId: InternalEndPoints.userId,
      receiverId: otheruser,
      senderName:
          '${InternalEndPoints.userId.split('-')[0][0].toUpperCase()}${InternalEndPoints.userId.split('-')[0].substring(1)}',
      message: messageController.text,
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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }
}


/* 
  Future<void> _handleMessageTap(Message message) async {
    if (message.type == MessageType.video) {
      await _handleVideoMessage(message);
    } else if (message.type == MessageType.document) {
      await _openDocument(message);
    } else if (message.type == MessageType.image) {
      await _openImage(message);
    }
  }
 */
  /* Future<void> _handleVideoMessage(Message message) async {
    final theme = Theme.of(context);
    if (message.sender != InternalEndPoints.userId.split("-")[0].toString()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            videoPath: message.content,
          ),
        ),
      );
    } else {
      try {
        await OpenFilex.open(message.content);
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
    final filePath = message.content;
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
    final imagePath = message.content;
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
 */
  /* void _showAttachmentOptions(BuildContext context, WidgetRef ref, int chatIndex) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.insert_drive_file),
            title: const Text("Send Document"),
            onTap: () async {
              final result = await FilePicker.platform.pickFiles();
              if (result != null && result.files.single.path != null) {
                final filePath = result.files.single.path!;
                ref.read(chatViewModelProvider.notifier).sendMediaAttachment(
                      chatIndex,
                      filePath,
                      MessageType.document,
                    );
                // Scroll to bottom after sending document
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
              }
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text("Send Media from Library"),
            onTap: () async {
              final picker = ImagePicker();
              final pickedFile = await picker.pickMedia();

              if (pickedFile != null) {
                final isVideo = pickedFile.path.toLowerCase().endsWith(".mp4") ||
                    pickedFile.path.toLowerCase().endsWith(".mov") ||
                    pickedFile.path.toLowerCase().endsWith(".avi");

                final messageType = isVideo ? MessageType.video : MessageType.image;

                ref.read(chatViewModelProvider.notifier).sendMediaAttachment(
                      chatIndex,
                      pickedFile.path,
                      messageType,
                    );
                // Scroll to bottom after sending media
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  } */
  /* void _handleSendMessage() {
    if (messageController.text.isEmpty) return;

    /* ref.read(messagesViewModelProvider(widget.conversationId).notifier)
       .sendMessage(messageController.text, []);
        */
    messageController.clear();
    _scrollToBottom();
  } */

 /*  */