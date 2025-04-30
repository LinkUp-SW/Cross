import 'package:flutter/material.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController Controller;
  final VoidCallback onSendPressed;
/*   final VoidCallback onAttachmentPressed; */

  const ChatInputField({
    super.key,
    required this.Controller,
    required this.onSendPressed,
   /*  required this.onAttachmentPressed, */
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attachment_rounded),
            onPressed: () {}, // Placeholder callback function
          ),
          Expanded(
            child: TextField(
              controller: Controller,
              decoration: InputDecoration(
                hintText: "Write a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: onSendPressed,
          ),
        ],
      ),
    );
  }
}
