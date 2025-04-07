import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewModel/chat_viewmodel.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_field.dart';
import '../model/chat_model.dart';

class ChatScreen extends ConsumerWidget {
  final int chatIndex;

  const ChatScreen({Key? key, required this.chatIndex}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatViewModelProvider);
    final chat = chats[chatIndex];
    final messageController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(chat.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chat.messages.length,
              itemBuilder: (context, index) {
                return ChatMessageBubble(
                  message: chat.messages[index],
                  currentUserName: "jumana", // from mock profile feature
                  currentUserProfilePicUrl: "assets/images/profile.png", // or mocked URL
                  chatProfilePicUrl: chat.profilePictureUrl,
                );
              },
            ),
          ),
          ChatInputField(
            messageController: messageController,
            onSendPressed: () {
              if (messageController.text.isNotEmpty) {
                ref.read(chatViewModelProvider.notifier).sendMessage(
                      chatIndex,
                      messageController.text,
                      MessageType.text,
                    );
                messageController.clear();
              }
            },
            onAttachmentPressed: () {
              _showAttachmentOptions(context, ref, chatIndex);
            },
          ),
        ],
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
            onTap: () {
              ref.read(chatViewModelProvider.notifier).sendMediaAttachment(
                    chatIndex,
                    "https://example.com/docs/sample-document.pdf",
                    MessageType.document,
                  );
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text("Send Media from Library"),
            onTap: () {
              ref.read(chatViewModelProvider.notifier).sendMediaAttachment(
                    chatIndex,
                    "https://www.w3schools.com/w3images/avatar5.png",
                    MessageType.image,
                  );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
