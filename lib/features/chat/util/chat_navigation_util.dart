import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/chat/viewModel/newchat_viewmodel.dart';


Future<void> navigateDirectlyToChat({
  required BuildContext context,
  required WidgetRef ref,
  required String userId,
  required String firstName,
  required String lastName,
  required String profilePic,
}) async {
  // Show a loading indicator
  final loadingOverlay = _showLoadingOverlay(context);

  try {
    final viewModel = ref.read(newChatViewModelProvider.notifier);

    // Determine if there's an existing chat
    await viewModel.fetchChats();
    final state = ref.read(newChatViewModelProvider);
    final hasExistingChat = state.chats?.any((chat) => chat.senderId == userId) ?? false;

    // Get response based on whether chat exists
    Map<String, dynamic>? response;
    if (hasExistingChat) {
      response = await viewModel.openExistingChat(userId);
    } else {
      response = await viewModel.createNewChat(userId);
    }

    final conversationId = response['conversationId'];
    log("Got conversation ID: $conversationId");

    // Remove loading overlay
    loadingOverlay.remove();

    // Navigate directly to the chat screen
    GoRouter.of(context).push(
      '/chatroom/$conversationId',
      extra: {
        'otheruserid': userId,
        'senderName': "$firstName $lastName",
        'senderProfilePicUrl': profilePic,
      },
    );
  } catch (e) {
    log("Error navigating to chat: $e");

    // Remove loading overlay
    loadingOverlay.remove();

    // Show error in snackbar instead of a separate page
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Chat error: ${_formatErrorMessage(e.toString())}"),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              // Retry the navigation
              navigateDirectlyToChat(
                  context: context,
                  ref: ref,
                  userId: userId,
                  firstName: firstName,
                  lastName: lastName,
                  profilePic: profilePic);
            },
          ),
          duration: const Duration(seconds: 10),
        ),
      );
    }
  }
}

// Helper to format error messages
String _formatErrorMessage(String error) {
  if (error.contains(':')) {
    final parts = error.split(':');
    if (parts.length > 1) {
      return parts.last.trim();
    }
  }

  if (error.length > 100) {
    return '${error.substring(0, 100)}...';
  }

  return error;
}

// Helper to show a loading overlay
OverlayEntry _showLoadingOverlay(BuildContext context) {
  final overlay = OverlayEntry(
    builder: (context) => Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Opening chat...'),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(overlay);
  return overlay;
}
