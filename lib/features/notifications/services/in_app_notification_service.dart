import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InAppNotificationService {
  static final InAppNotificationService _instance = InAppNotificationService._internal();
  factory InAppNotificationService() => _instance;
  InAppNotificationService._internal();

  // For accessing overlay
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  OverlayEntry? _currentNotification;
  Timer? _dismissTimer;

  void showNotification({
    required String title,
    required String message,
    String? imageUrl,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Hide any existing notification first
    hideNotification();

    final context = navigatorKey.currentContext;
    if (context == null) {
      print('❌ Cannot show notification: No navigator context available');
      return;
    }

    final overlay = Overlay.of(context);
    if (overlay == null) {
      print('❌ Cannot show notification: No overlay available');
      return;
    }

    _currentNotification = OverlayEntry(
      builder: (context) => _InAppNotificationWidget(
        title: title,
        message: message,
        imageUrl: imageUrl,
        onTap: onTap,
        onDismiss: hideNotification,
      ),
    );

    overlay.insert(_currentNotification!);
    print('✅ In-app notification shown');

    // Auto dismiss after duration
    _dismissTimer = Timer(duration, hideNotification);
  }

  void hideNotification() {
    _dismissTimer?.cancel();
    _dismissTimer = null;

    if (_currentNotification != null) {
      _currentNotification!.remove();
      _currentNotification = null;
      print('🔄 In-app notification dismissed');
    }
  }
}

class _InAppNotificationWidget extends StatefulWidget {
  final String title;
  final String message;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback onDismiss;

  const _InAppNotificationWidget({
    Key? key,
    required this.title,
    required this.message,
    this.imageUrl,
    this.onTap,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<_InAppNotificationWidget> createState() => _InAppNotificationWidgetState();
}

class _InAppNotificationWidgetState extends State<_InAppNotificationWidget> with SingleTickerProviderStateMixin {
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
    final theme = Theme.of(context);

    return SafeArea(
      child: SlideTransition(
        position: _offsetAnimation,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
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
                      // Profile image
                      if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
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
                              color: theme.colorScheme.primary,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                          ),
                        ),
                      SizedBox(width: widget.imageUrl != null ? 12 : 0),

                      // Notification content
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.message,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Close button
                      IconButton(
                        icon: Icon(Icons.close, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                        onPressed: widget.onDismiss,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        splashRadius: 24,
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
