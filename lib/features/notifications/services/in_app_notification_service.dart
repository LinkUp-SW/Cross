import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InAppNotificationService {
  static final InAppNotificationService _instance = InAppNotificationService._internal();
  factory InAppNotificationService() => _instance;
  InAppNotificationService._internal();

  // Create a navigator key that will be passed to GoRouter
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  OverlayEntry? _currentNotification;
  Timer? _dismissTimer;

  void showNotification({
    required String title,
    required String message,
    String? imageUrl,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Hide any existing notification first
    hideNotification();

    // Get the overlay context from navigator
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    _currentNotification = OverlayEntry(
      builder: (context) => InAppNotificationWidget(
        title: title,
        message: message,
        imageUrl: imageUrl,
        onTap: () {
          if (onTap != null) onTap();
          hideNotification();
        },
        onDismiss: hideNotification,
      ),
    );

    overlay.insert(_currentNotification!);

    // Auto dismiss after duration
    _dismissTimer = Timer(duration, hideNotification);
  }

  void hideNotification() {
    _dismissTimer?.cancel();
    _dismissTimer = null;

    if (_currentNotification != null) {
      _currentNotification!.remove();
      _currentNotification = null;
    }
  }
}

class InAppNotificationWidget extends StatefulWidget {
  final String title;
  final String message;
  final String? imageUrl;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const InAppNotificationWidget({
    Key? key,
    required this.title,
    required this.message,
    this.imageUrl,
    required this.onTap,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<InAppNotificationWidget> createState() => _InAppNotificationWidgetState();
}

class _InAppNotificationWidgetState extends State<InAppNotificationWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SlideTransition(
        position: _offsetAnimation,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Profile picture if available
                      if (widget.imageUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            widget.imageUrl!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],

                      // Notification content
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.message,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Close button
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70, size: 16),
                        onPressed: widget.onDismiss,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final inAppNotificationServiceProvider = Provider<InAppNotificationService>((ref) {
  return InAppNotificationService();
});
