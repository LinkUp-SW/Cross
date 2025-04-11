import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:link_up/features/chat/widgets/video_player_screen.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../model/chat_model.dart';
import '../viewModel/chat_viewmodel.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_field.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final int chatIndex;

  const ChatScreen({Key? key, required this.chatIndex}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final chats = ref.watch(chatViewModelProvider);
    final chat = chats[widget.chatIndex];
    final messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          chat.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chat.messages.length,
              itemBuilder: (context, index) {
                final message = chat.messages[index];
                return GestureDetector(
                  onTap: () async {
                    await _handleMessageTap(message);
                  },
                  child: ChatMessageBubble(
                    message: message,
                    currentUserName: "jumana",
                    currentUserProfilePicUrl: "assets/images/profile.png",
                    chatProfilePicUrl: chat.profilePictureUrl,
                  ),
                );
              },
            ),
          ),
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
    if (message.sender != "jumana") {
      // Navigate to VideoPlayerScreen for videos sent by other users
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            videoPath: message.content, // Pass the video file path or URL
          ),
        ),
      );
    } else {
      // Open video directly using OpenFilex for videos sent by the current user
      try {
        await OpenFilex.open(message.content); // mediaPath
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to open video: $e")),
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
  showDialog(
    context: context,
    builder: (BuildContext context) => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // Close the image and return to chat
          },
        ),
      ),
      body: Center(
        child: imagePath.isEmpty
            ? const Text(
                "No image available",
                style: TextStyle(color: Colors.white),
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
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
