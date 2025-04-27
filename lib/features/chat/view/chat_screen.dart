/* import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/chat/widgets/typing_indicator.dart';
import 'package:link_up/features/chat/widgets/video_player_screen.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../viewModel/chat_viewmodel.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_field.dart';
import '../model/message_model.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int chatIndex;

  const ChatScreen({super.key, required this.chatIndex});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chats = ref.watch(chatViewModelProvider);
    final messages = chats[widget.chatIndex].messages;
    final chat = chats[widget.chatIndex];

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
        title: Text(
          chat.sendername,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Chat messages and typing indicator section
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: chat.messages.length,
                    itemBuilder: (context, index) {
                      final message = chat.messages[index];
                      final isLastMessage = index == messages.length - 1 && message.sender == InternalEndPoints.userId.split("-")[0].toString();
                      return GestureDetector(
                        onTap: () async {
                          await _handleMessageTap(message);
                        },
                        child: ChatMessageBubble(
                          message: message,
                          currentUserName: InternalEndPoints.userId.split("-")[0].toString(),
                          currentUserProfilePicUrl: "assets/images/profile.png",
                          chatProfilePicUrl: chat.senderprofilePictureUrl,
                          isLastMessage: isLastMessage,
                        ),
                      );
                    },
                  ),
                ),

                // Typing indicator UI (appears inside chat screen above the input field)
               
              ],
            ),
          ),
            if (chat.isTyping && chat.typingUser != InternalEndPoints.userId.split("-")[0].toString())
                  TypingIndicator(
                    isTyping: chat.isTyping,
                    typingUser: chat.typingUser ?? '',
                    currentUser: InternalEndPoints.userId.split("-")[0].toString(), // Or dynamically get the current user's name
                    theme: theme, 
                  ),
          // Chat input field (Message sending section)
          ChatInputField(
            messageController: messageController,
            onSendPressed: () {
              if (messageController.text.isNotEmpty) {
                ref.read(chatViewModelProvider.notifier).sendMessage(
                      widget.chatIndex,
                      messageController.text,
                      MessageType.text,
                    );
                messageController.clear();

                // Scroll to the bottom after sending a message
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
              }
            },
            onAttachmentPressed: () {
              _showAttachmentOptions(context, ref, widget.chatIndex);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleMessageTap(Message message) async {
    if (message.type == MessageType.video) {
      await _handleVideoMessage(message);
    } else if (message.type == MessageType.document) {
      await _openDocument(message);
    } else if (message.type == MessageType.image) {
      await _openImage(message);
    }
  }

  Future<void> _handleVideoMessage(Message message) async {
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

  void _showAttachmentOptions(BuildContext context, WidgetRef ref, int chatIndex) {
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
  }

  void _scrollToBottom() {
    // Ensure the scroll happens to the bottom after the new message
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }
}
 */