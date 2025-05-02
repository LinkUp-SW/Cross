import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/chat/model/chat_model.dart';
import 'package:link_up/features/chat/model/connections_chat_model.dart';
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
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final notifier = ref.read(newChatViewModelProvider.notifier);
      await notifier.getConnectionsList({'limit': '10'});
      await notifier.fetchChats();
    });
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
      body: state.isLoading
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
                      onTap: () async {
                        try {
                          final chatResult = await viewModel.handleChatTap(connection);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                               
                                  conversationId: chatResult.conversationId,
                                  senderName: chatResult.senderName,
                                  senderProfilePicUrl: chatResult.profilePicUrl,
                                   otheruserid: chatResult.otherUserId ?? '',
                                ),
                            
                              ),
                            
                          );
                        } catch (e) {
                          log("Failed to open chat: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Failed to open chat")),
                          );
                        }
                      },
                    );
                  },
                ),
    );
  }
}
