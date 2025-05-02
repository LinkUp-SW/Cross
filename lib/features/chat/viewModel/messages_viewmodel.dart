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
        // Reload messages when receiving a new message
        await loadMessages();
        log('[VIEWMODEL] Messages reloaded after receiving new message');
      } catch (e) {
        log('[VIEWMODEL] Error reloading messages: $e');
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

      // Optimistic update
      final updatedMessages = [...?state.messages, message]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      state = state.copyWith(messages: updatedMessages);

      // Send via socket
      _socketService.sendMessage(conversationId, message);

      // Reload messages after sending
      await loadMessages();

      log('[VIEWMODEL] Message sent and messages reloaded');
    } catch (e) {
      log('[VIEWMODEL] Failed to send message: $e');
      // Revert optimistic update on failure
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
