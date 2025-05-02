// viewmodel/messages_viewmodel.dart
import 'dart:async';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/message_model.dart';
import '../services/messages_service.dart';
import '../state/messages_state.dart';
import '../services/socket_service.dart';

class MessagesViewModel extends StateNotifier<MessagesState> {
  final MessagesService _service;
  final String conversationId;
  final SocketService _socketService;

  MessagesViewModel({
    required MessagesService service,
    required SocketService socketService,
    required this.conversationId,
  })  : _service = service,
        _socketService = socketService,
        super(MessagesState.initial()) {
    _listenToSocket();
    loadMessages();
  }

  void _listenToSocket() {
    log('[VIEWMODEL] Setting up socket listener...');
    _socketService.onMessageReceived((dynamic data) async {
      log('[VIEWMODEL] Full data received: $data');
      try {
        // Add new message to state
        final message = Message.fromJson(data['message']);
        final updatedMessages = [...?state.messages, message]
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
        
        state = state.copyWith(
          messages: updatedMessages,
          isLoading: false,
          isError: false,
        );

        log('[VIEWMODEL] Message added to state');
      } catch (e) {
        log('[VIEWMODEL] Error processing message: $e');
      }
    });
  }

  Future<void> loadMessages() async {
    if (state.isLoading) return;

    try {
      state = state.copyWith(isLoading: true, isError: false);
      final messages = await _service.openExistingChat(conversationId);

      if (!mounted) return;

      state = state.copyWith(
        messages: messages,
        isLoading: false,
        isError: false,
      );
      log('[VIEWMODEL] Successfully loaded ${messages.length} messages');
    } catch (e) {
      log('[VIEWMODEL] Error loading messages: $e');
      if (!mounted) return;

      state = state.copyWith(
        isError: true,
        isLoading: false,
        errorMessage: 'Failed to load messages',
      );
    }
  }

  Future<void> sendMessage(Message message) async {
    try {
      log('[VIEWMODEL] Sending message: ${message.message}');

      // Add message to state immediately for instant feedback
      final currentMessages = [...?state.messages];
      currentMessages.add(message);
      currentMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      state = state.copyWith(
        messages: currentMessages,
        isLoading: false,
        isError: false,
      );

      // Send via socket in background
      _socketService.sendMessage(conversationId, message);
    } catch (e) {
      log('[VIEWMODEL] Failed to send message: $e');

      // Remove message from state if sending failed
      final originalMessages = state.messages?.where((m) => m.messageId != message.messageId).toList();
      state = state.copyWith(
        messages: originalMessages,
        errorMessage: 'Failed to send message',
      );
    }
  }

  @override
  void dispose() {
    _socketService.disposeSocket(conversationId);
    super.dispose();
  }
}

final messagesViewModelProvider = StateNotifierProvider.family<MessagesViewModel, MessagesState, String>(
  (ref, conversationId) => MessagesViewModel(
    service: ref.watch(messageServiceProvider),
    socketService: SocketService(conversationId: conversationId), // Create new instance with conversation ID
    conversationId: conversationId,
  ),
);
