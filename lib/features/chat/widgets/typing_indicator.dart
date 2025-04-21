import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  final bool isTyping;
  final String typingUser;
  final String currentUser;
  final ThemeData theme;

  const TypingIndicator({
    Key? key,
    required this.isTyping,
    required this.typingUser,
    required this.currentUser,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isTyping || typingUser == currentUser) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: Container(
          height: 30, // Initial space for the typing indicator
          width: double.infinity,
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                size: 18,
                color: theme.colorScheme.onBackground.withOpacity(0.5),
              ),
              SizedBox(width: 8),
              Text(
                '$typingUser is typing...',
                style: TextStyle(
                  color: theme.colorScheme.onBackground.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
