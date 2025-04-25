import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/chat/view/chat_screen.dart';
import 'package:link_up/features/chat/viewModel/chat_viewmodel.dart';
import 'package:link_up/features/my-network/viewModel/connections_screen_view_model.dart';

class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final int paginationLimit = 10;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(connectionsScreenViewModelProvider.notifier).getConnectionsList({
        'limit': '$paginationLimit',
      });
    });

    _scrollController.addListener(() {
      final viewModel = ref.read(connectionsScreenViewModelProvider.notifier);
      final state = ref.read(connectionsScreenViewModelProvider);

      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !state.isLoadingMore &&
          state.nextCursor != null) {
        viewModel.loadMoreConnections(paginationLimit: paginationLimit);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final connectionState = ref.watch(connectionsScreenViewModelProvider);
    final connections = connectionState.connections ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Message'),
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary,
      ),
      body: connectionState.isLoading && connections.isEmpty
    ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
    : connections.isEmpty
        ? Center(
            child: Text(
              'No connections found.',
              style: TextStyle(color: theme.hintColor, fontSize: 16),
            ),
          )

          : ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              itemCount: connections.length + 1,
              separatorBuilder: (_, __) => const Divider(indent: 70, endIndent: 16),
              itemBuilder: (context, index) {
                if (index == connections.length) {
                  // Loader at the bottom
                  return connectionState.isLoadingMore
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox.shrink();
                }

                final connection = connections[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(connection.profilePicture),
                    radius: 24,
                  ),
                  title: Text('${connection.firstName} ${connection.lastName}'),
                  subtitle: Text(connection.title),
                  onTap: () {
                    final chatIndex = ref
                        .read(chatViewModelProvider.notifier)
                        .startNewOrOpenExistingChat(connection);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(chatIndex: chatIndex),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
