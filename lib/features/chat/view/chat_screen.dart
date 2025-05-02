/* import 'dart:io';
import 'package:file_picker/file_picker.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; 
immport 'package:link_up/features/chat/widgets/typing_indicator.dart';
import 'package:link_up/features/chat/widgets/video_player_screen.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart'; */
import 'package:link_up/features/chat/model/message_model.dart';
import 'package:link_up/features/chat/widgets/typing_indicator.dart';
import '../viewModel/chat_viewmodel.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/chat/viewModel/messages_viewmodel.dart';
import 'dart:developer';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String senderName;
  final String senderProfilePicUrl;
  final String otheruserid;

  const ChatScreen({
    Key? key,
    required this.otheruserid,
    required this.conversationId,
    required this.senderName,
    required this.senderProfilePicUrl,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController messageController = TextEditingController();
  late final String otheruser;

  @override
  void initState() {
    super.initState();
    otheruser = widget.otheruserid;

    // Load messages initially
    Future.microtask(() {
      log('Initializing chat screen for conversation: ${widget.conversationId}');
      ref.read(messagesViewModelProvider(widget.conversationId).notifier).loadMessages().then((_) {
        // Scroll to bottom after messages are loaded
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      });
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // Load more messages when reaching the bottom
      // ref.read(messagesViewModelProvider(widget.conversationId).notifier).loadMoreMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messagesState = ref.watch(messagesViewModelProvider(widget.conversationId));

    log('Building chat screen. Messages count: ${messagesState.messages?.length ?? 0}');
    log('Other user typing: ${messagesState.isOtherUserTyping}');

    // Scroll to bottom whenever messages update and loading completes
    if (!messagesState.isLoading && messagesState.messages != null && messagesState.messages!.isNotEmpty) {
      // Use post frame callback to ensure the list view is built before scrolling
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await ref.read(chatViewModelProvider.notifier).fetchChats(); // Fetch updated chat list
            if (context.mounted) {
              Navigator.of(context).pop(); // Return to chat list screen
            }
          },
        ),
        title: Text(
          widget.senderName,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesState.isLoading && (messagesState.messages?.isEmpty ?? true)
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: messagesState.messages?.length ?? 0,
                    itemBuilder: (context, index) {
                      final message = messagesState.messages![index];

                      // Debug the message at render time
                      print('Rendering message: ID=${message.messageId}, content="${message.message}"');

                      return ChatMessageBubble(
                        key: ValueKey(message.messageId),
                        message: message,
                        currentUserName: "You",
                        currentUserProfilePicUrl: "assets/images/profile.png",
                        chatProfilePicUrl: widget.senderProfilePicUrl,
                        senderName: widget.senderName, // Pass the sender name from the ChatScreen
                      );
                    },
                  ),
          ),

          // Show typing indicator when the other user is typing
          if (messagesState.isOtherUserTyping)
            TypingIndicator(
              isTyping: true, // Always true here since we're inside the conditional
              typingUser: widget.senderName,
              currentUser: "You",
              theme: theme,
            ),

          if (messagesState.isError)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                messagesState.errorMessage ?? 'Error sending message',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ChatInputField(
            Controller: messageController,
            onSendPressed: _handleSendMessage,
            onTyping: () {
              ref.read(messagesViewModelProvider(widget.conversationId).notifier).startTyping();
            },
          ),
        ],
      ),
    );
  }

  void _handleSendMessage() {
    if (messageController.text.isEmpty) return;

    final messageText = messageController.text.trim();

    // Debug logging
    print('Sending message: "$messageText"');

    final newMessage = Message(
      messageId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      senderId: InternalEndPoints.userId,
      receiverId: otheruser,
      senderName: 'You', // Simplified display name for current user
      message: messageText, // Make sure this is not empty
      media: [],
      timestamp: DateTime.now(),
      isOwnMessage: true,
      isSeen: false,
      reacted: '',
      isEdited: false,
    );

    // Clear input field immediately
    messageController.clear();

    // Send message
    ref.read(messagesViewModelProvider(widget.conversationId).notifier).sendMessage(newMessage);

    // Scroll to bottom immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      try {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        log('[CHAT] Scrolled to bottom');
      } catch (e) {
        log('[CHAT] Error scrolling to bottom: $e');
      }
    } else {
      log('[CHAT] Scroll controller has no clients yet');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }
}
