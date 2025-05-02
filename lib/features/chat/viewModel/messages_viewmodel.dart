// viewmodel/messages_viewmodel.dart
import 'dart:async';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import '../model/message_model.dart';
import '../services/messages_service.dart';
import '../state/messages_state.dart';
import '../services/socket_service.dart';

class MessagesViewModel extends StateNotifier<MessagesState> {
  final MessagesService _service;
  final String conversationId;
  final SocketService _socketService;

  bool _isTyping = false;
  Timer? _typingTimer;

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

  void _listenToSocket() async {
    log('[VIEWMODEL] Setting up socket listener...');
    

    _socketService.onMessageReceived((dynamic data) async {
      log('[VIEWMODEL] Full data received: $data');
      try {
        // Handle different message formats properly
        final Message message = _parseMessageFromSocketData(data);

        // Extract the conversation ID from data
        final messageConversationId = data is Map && data.containsKey('conversationId')
            ? data['conversationId']
            : (data is List && data.isNotEmpty && data[0] is Map && data[0].containsKey('conversationId')
                ? data[0]['conversationId']
                : null);

        // Only process messages for this conversation
        if (messageConversationId == conversationId) {
          // For messages we sent, replace temporary message
          if (message.isOwnMessage == true) {
            final currentMessages = [...?state.messages];

            // Find and remove any temporary messages
            final filteredMessages = currentMessages.where((m) => !m.messageId.startsWith('temp_')).toList();

            // Add the confirmed message
            filteredMessages.add(message);
            filteredMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

            state = state.copyWith(
              messages: filteredMessages,
              isLoading: false,
              isError: false,
            );

            log('[VIEWMODEL] Replaced temporary message with server confirmed message');
          }
          // For messages from others, add if not already there
          else {
            // Check if we already have this message (to avoid duplicates)
            final messageExists = state.messages?.any((m) => m.messageId == message.messageId) ?? false;
            if (!messageExists) {
              final updatedMessages = [...?state.messages, message]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

              state = state.copyWith(
                messages: updatedMessages,
                isLoading: false,
                isError: false,
              );

              log('[VIEWMODEL] New incoming message added to state');

              // Send read receipt if applicable
              _socketService.markAsRead();
            }
          }
        }
      } catch (e) {
        log('[VIEWMODEL] Error processing socket message: $e');
      }
    });
  }

  // Helper method to parse messages from different socket data formats
  Message _parseMessageFromSocketData(dynamic data) {
    try {
      // Handle array format: [{conversationId: id, senderId: id, message: {...}}]
      if (data is List && data.isNotEmpty && data[0] is Map) {
        final messageData = data[0]['message'];
        if (messageData != null) {
          return Message(
            messageId: messageData['messageId'] ?? '',
            senderId: data[0]['senderId'] ?? '',
            senderName: messageData['senderName'] ?? data[0]['senderId'] ?? '',
            message: messageData['message'] ?? '',
            media: List<String>.from(messageData['media'] ?? []),
            timestamp: DateTime.parse(messageData['timestamp'] ?? DateTime.now().toIso8601String()),
            isSeen: messageData['is_seen'] ?? false,
            isOwnMessage: data[0]['senderId'] == InternalEndPoints.userId,
            receiverId: data[0]['recipientId'] ?? data[0]['receiverId'],
          );
        }
      }

      // Handle direct object format: {conversationId: id, senderId: id, message: {...}}
      else if (data is Map && data.containsKey('message')) {
        final messageData = data['message'];
        if (messageData != null) {
          return Message(
            messageId: messageData['messageId'] ?? '',
            senderId: data['senderId'] ?? '',
            senderName: messageData['senderName'] ?? data['senderId'] ?? '',
            message: messageData['message'] ?? '',
            media: List<String>.from(messageData['media'] ?? []),
            timestamp: DateTime.parse(messageData['timestamp'] ?? DateTime.now().toIso8601String()),
            isSeen: messageData['is_seen'] ?? false,
            isOwnMessage: data['senderId'] == InternalEndPoints.userId,
            receiverId: data['recipientId'] ?? data['receiverId'],
          );
        }
      }

      // If unable to parse with the above formats, attempt standard parsing
      return Message.fromJson(data['message'] ?? data);
    } catch (e) {
      log('[VIEWMODEL] Error parsing message: $e');
      // Return a fallback message to prevent crashes
      return Message(
        messageId: DateTime.now().toString(),
        senderId: 'unknown',
        senderName: 'Unknown',
        message: 'Could not parse message',
        media: [],
        timestamp: DateTime.now(),
      );
    }
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

      // Generate a temporary ID for the message that's easy to track
      final tempMessage = message.copyWith(
        messageId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Add message to state immediately for instant feedback
      final currentMessages = [...?state.messages];
      currentMessages.add(tempMessage);
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
      final originalMessages =
          state.messages?.where((m) => !m.messageId.startsWith('temp_') || m.messageId != message.messageId).toList();

      state = state.copyWith(
        messages: originalMessages,
        errorMessage: 'Failed to send message',
      );
    }
  }

  void startTyping() {
    if (!_isTyping) {
      _isTyping = true;
      _socketService.sendTypingIndicator();
    }

    // Reset the timer each time user types
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      stopTyping();
    });
  }

  void stopTyping() {
    if (_isTyping) {
      _isTyping = false;
      _socketService.sendStopTypingIndicator();
      _typingTimer?.cancel();
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
