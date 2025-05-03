import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:link_up/features/chat/view/chat_screen.dart';
import 'package:link_up/features/chat/viewModel/newchat_viewmodel.dart';
import 'package:link_up/features/chat/widgets/connection_tile.dart';
import 'package:link_up/shared/themes/colors.dart';

class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final notifier = ref.read(newChatViewModelProvider.notifier);
      await notifier.getConnectionsList({'limit': '10'});
      await notifier.fetchChats();
    });
  }

  Future<void> _handleChatNavigation({
    required String userId,
    required String firstName,
    required String lastName,
    required String profilePic,
    required bool hasExistingChat,
  }) async {
    try {
      log("Processing ${hasExistingChat ? 'existing' : 'new'} chat for user: $firstName (ID: $userId)");

      Map<String, dynamic>? response;
      final viewModel = ref.read(newChatViewModelProvider.notifier);

      if (hasExistingChat) {
        response = await viewModel.openExistingChat(userId);
      } else {
        response = await viewModel.createNewChat(userId);
      }

      // Get the conversation ID
      final conversationId = response['conversationId'];
      log("Got conversation ID: $conversationId");

      // Check if widget is still mounted BEFORE using context
      if (!mounted) {
        log("Widget no longer mounted, skipping navigation");
        return;
      }

      // Navigate using a new context to avoid the unsafe ancestor lookup
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            otheruserid: userId,
            conversationId: conversationId,
            senderName: "$firstName $lastName",
            senderProfilePicUrl: profilePic,
          ),
        ),
      );
    } catch (e) {
      log("Error handling chat tap: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to open chat: ${e.toString()}")),
        );
      }
    } finally {
      // Update loading state only if still mounted
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        // Update the provider loading state if needed
        if (mounted) {
          ref.read(newChatViewModelProvider.notifier).updateLoading(false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final state = ref.watch(newChatViewModelProvider);
    final viewModel = ref.read(newChatViewModelProvider.notifier);
    final connections = state.connections ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Message'),
        backgroundColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      ),
      body: state.isLoading || isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : connections.isEmpty
              ? Center(
                  child: Text(
                    'No connections found.',
                    style: TextStyle(
                      color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: connections.length,
                  itemBuilder: (context, index) {
                    final connection = connections[index];
                    return ConnectionTile(
                      connection: connection,
                      onTap: () {
                        // Store connection data locally first
                        final String userId = connection.cardId;
                        final String firstName = connection.firstName;
                        final String lastName = connection.lastName;
                        final String profilePic = connection.profilePicture;
                        final bool hasExistingChat = connection.isExistingChat;

                        // Show loading indicator
                        setState(() {
                          isLoading = true;
                        });

                        // Use a separate method to handle the async operation
                        _handleChatNavigation(
                          userId: userId,
                          firstName: firstName,
                          lastName: lastName,
                          profilePic: profilePic,
                          hasExistingChat: hasExistingChat,
                        );
                      },
                    );
                  },
                ),
    );
  }
}
