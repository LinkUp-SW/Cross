import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
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
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with TickerProviderStateMixin {
  // Create separate animation controllers for each dot
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    // Create three animation controllers with staggered durations
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400),
      ),
    );

    // Create animations with different curves to create wave effect
    _animations = List.generate(
      3,
      (index) => CurvedAnimation(
        parent: _controllers[index],
        curve: Curves.easeInOut,
      ),
    );

    // Start animations with staggered delays
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container if not typing, or if it's the current user typing
    if (!widget.isTyping) return const SizedBox.shrink();

    // Extract first letter for avatar
    final firstLetter = widget.typingUser.isNotEmpty ? widget.typingUser[0].toUpperCase() : "?";

    final textColor = widget.theme.colorScheme.onSurfaceVariant;
    final bubbleColor = widget.theme.colorScheme.surfaceVariant.withOpacity(0.7);
    final dotColor = widget.theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // User avatar for the other user
          CircleAvatar(
            radius: 16,
            backgroundColor: widget.theme.colorScheme.primary.withOpacity(0.2),
            child: Text(
              firstLetter,
              style: TextStyle(
                color: widget.theme.colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Typing indicator bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Only show the other user's name
                Text(
                    '${widget.typingUser} is typing...',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),

                // Animated dots
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (index) => AnimatedBuilder(
                      animation: _animations[index],
                      builder: (context, child) {
                        return Container(
                          margin: const EdgeInsets.only(left: 2),
                          height: 4 + (_animations[index].value * 4),
                          width: 4 + (_animations[index].value * 4),
                          decoration: BoxDecoration(
                            color: dotColor.withOpacity(0.6 + (_animations[index].value * 0.4)),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: dotColor.withOpacity(0.2 * _animations[index].value),
                                blurRadius: 2 + (2 * _animations[index].value),
                                spreadRadius: 0.5,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
