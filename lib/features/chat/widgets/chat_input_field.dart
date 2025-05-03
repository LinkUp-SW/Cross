import 'package:flutter/material.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController Controller;
  final VoidCallback onSendPressed;
  final VoidCallback? onTyping;
  final VoidCallback onAttachmentPressed;

  const ChatInputField({
    Key? key,
    required this.Controller,
    required this.onSendPressed,
    required this.onAttachmentPressed,
    this.onTyping,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attachment_rounded),
            onPressed: onAttachmentPressed, // Placeholder callback function
          ),
          Expanded(
            child: TextField(
              controller: Controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSendPressed(),
              onChanged: (value) {
                // Always call onTyping when the user types anything
                if (onTyping != null && value.isNotEmpty) {
                  onTyping!();
                }
              },
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            onPressed: onSendPressed,
            mini: true,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
