import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/chat/viewModel/newchat_viewmodel.dart';
import 'package:link_up/features/my-network/viewModel/connections_screen_view_model.dart';
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

    // Fetch connections and chats when screen initializes
    Future.microtask(() {
      ref.read(newChatViewModelProvider.notifier).getConnectionsList({
        'limit': '10',
      }); 
      ref.read(newChatViewModelProvider.notifier).fetchChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final connectionState = ref.watch(newChatViewModelProvider);
    final connections = connectionState.connections ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Message'),
        backgroundColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      ),
      body: connectionState.isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : connections.isEmpty
              ? Center(
                  child: Text(
                    'No connections found.',
                    style: TextStyle(color: isDarkMode ? AppColors.darkMain : AppColors.lightMain, fontSize: 16),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  itemCount: connections.length,
                  separatorBuilder: (_, __) => const Divider(indent: 70, endIndent: 16),
                  itemBuilder: (context, index) {
                    final connection = connections[index];
                    log('Building connection tile: ${connection.firstName}');
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(connection.profilePicture),
                        radius: 24,
                      ),
                      title: Text('${connection.firstName} ${connection.lastName}'),
                      subtitle: Text(connection.title),
                      onTap: () async {
                        try {
                          if (!mounted) return;
                          // Handle chat navigation here
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
                    );
                  },
                ),
    );
  }
}
