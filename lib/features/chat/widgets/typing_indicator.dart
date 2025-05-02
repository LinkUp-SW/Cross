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
    // Only check if typing is active - don't compare users
    if (!isTyping) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        height: 30,
        child: Row(
          children: [
            _buildDotAnimation(),
            const SizedBox(width: 8),
            Text(
              '$typingUser is typing...',
              style: TextStyle(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
                fontStyle: FontStyle.italic,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add animated dots for better visual feedback
  Widget _buildDotAnimation() {
    return Row(
      children: List.generate(
        3,
        (index) => _AnimatedDot(
          index: index,
          color:Colors. blue,
        ),
      ),
    );
  }
}

// Create an animated dot for the typing indicator
class _AnimatedDot extends StatefulWidget {
  final int index;
  final Color color;

  const _AnimatedDot({required this.index, required this.color});

  @override
  _AnimatedDotState createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    // Stagger the animations
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          widget.index * 0.2, // stagger the start
          0.6 + widget.index * 0.2,
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 6 + (_animation.value * 4),
          width: 6 + (_animation.value * 4),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.6 + (_animation.value * 0.4)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
