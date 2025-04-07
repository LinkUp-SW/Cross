import 'package:flutter/material.dart';
import '../model/chat_model.dart';

class ChatMessageBubble extends StatelessWidget {
  final Message message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(message.sender),
      subtitle: message.type == MessageType.text
          ? Text(message.content)
          : message.type == MessageType.image
              ? Image.network(
                  message.content,
                  errorBuilder: (context, error, stackTrace) {
                    return const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        Text('Failed to load image', style: TextStyle(color: Colors.red)),
                      ],
                    );
                  },
                )
              : message.type == MessageType.video
                  ? const Icon(Icons.videocam, color: Colors.blue)
                  : message.type == MessageType.document
                      ? const Icon(Icons.insert_drive_file, color: Colors.green)
                      : message.type == MessageType.sticker
                          ? Image.network(
                              message.content,
                              errorBuilder: (context, error, stackTrace) {
                                return const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.error, color: Colors.red),
                                    Text('Failed to load sticker', style: TextStyle(color: Colors.red)),
                                  ],
                                );
                              },
                            )
                          : const SizedBox.shrink(),
      trailing: Text(
        "${message.timestamp.hour}:${message.timestamp.minute}",
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
