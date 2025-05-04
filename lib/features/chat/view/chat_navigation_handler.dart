import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/chat/viewModel/newchat_viewmodel.dart';

class ChatNavigationHandler extends ConsumerStatefulWidget {
  final String userId;
  final String firstName;
  final String lastName;
  final String profilePic;

  const ChatNavigationHandler({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.profilePic,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ChatNavigationHandler> createState() => _ChatNavigationHandlerState();
}

class _ChatNavigationHandlerState extends ConsumerState<ChatNavigationHandler> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _navigateToChat();
  }

  Future<void> _navigateToChat() async {
    try {
      final viewModel = ref.read(newChatViewModelProvider.notifier);

      // Determine if there's an existing chat
      await viewModel.fetchChats();
      final state = ref.read(newChatViewModelProvider);
      final hasExistingChat =
          state.chats?.any((chat) => chat.senderId == widget.userId) ?? false;

      // Get response based on whether chat exists
      Map<String, dynamic>? response;
      if (hasExistingChat) {
        response = await viewModel.openExistingChat(widget.userId);
      } else {
        response = await viewModel.createNewChat(widget.userId);
      }

      final conversationId = response['conversationId'];
      log("Got conversation ID: $conversationId");

      // Replace current screen with chat screen
       if (mounted) {
      // Create a direct route to ChatScreen instead of using the handler
      GoRouter.of(context).pushReplacement(
        '/chatroom/$conversationId',
        extra: {
          'otheruserid': widget.userId,
          'senderName': "${widget.firstName} ${widget.lastName}",
          'senderProfilePicUrl': widget.profilePic,
        },
      );
    }
  } catch (e) {
    log("Error navigating to chat: $e");
    setState(() {
      _isLoading = false;
      _errorMessage = "Failed to open chat: $e";
    });
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Opening Chat')),
      body: Center(
        child: _errorMessage != null
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48.0,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chat Connection Error',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatErrorMessage(_errorMessage!),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        _navigateToChat();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }

  // Add this helper method to format error messages
  String _formatErrorMessage(String error) {
    // Extract just the user-friendly part of the error message
    if (error.contains(':')) {
      final parts = error.split(':');
      if (parts.length > 1) {
        return parts.last.trim();
      }
    }
    
    // Limit length if still too long
    if (error.length > 100) {
      return '${error.substring(0, 100)}...';
    }
    
    return error;
  }
}
