// unread_message_counter.dart
import 'package:flutter/material.dart';

class UnreadMessageCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.blue,  // Blue color for unread
        shape: BoxShape.circle,
      ),
    );
  }
}
