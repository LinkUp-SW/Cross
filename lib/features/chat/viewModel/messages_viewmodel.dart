// viewmodel/messages_viewmodel.dart
import 'dart:async';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/chat/model/chat_model.dart';
import 'package:link_up/features/chat/services/chat_service.dart';
import 'package:link_up/features/chat/services/global_socket_service.dart';
import 'package:link_up/features/chat/services/newchat_service.dart';
import '../model/message_model.dart';
import '../services/messages_service.dart';
import '../state/messages_state.dart';
import '../services/socket_service.dart';

class MessagesViewModel extends StateNotifier<MessagesState> {
  final MessagesService _service;
  final String conversationId;
  final SocketService _socketService;
  final ApiChatService _chatService;

  bool _isTyping = false;
  Timer? _typingTimer;

  // Track if user is actively viewing this conversation
  bool _isActivelyViewing = false;

  MessagesViewModel({
    ApiChatService ?chatService,
    required MessagesService service,
    required SocketService socketService,
    required this.conversationId,
  })  : _service = service,
        _chatService = chatService ?? ApiChatService(),
        _socketService = socketService,
        super(MessagesState.initial()) {
    _listenToSocket();
    loadMessages();
  }

  void _listenToSocket() async {
    log('[VIEWMODEL] Setting up socket listener...');
    final currentUserId = InternalEndPoints.userId;

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

              // REMOVE THIS AUTO MARKING AS READ - only mark when user is at bottom
              // _socketService.markAsRead();
            }
          }
        }
      } catch (e) {
        log('[VIEWMODEL] Error processing socket message: $e');
      }
    });

    // Update the typing handlers for immediate updates

    _socketService.onTypingStarted((data) {
      log('[VIEWMODEL] Typing started: $data');

      // Extract user ID from typing event
      String? typingUserId;

      if (data is List && data.isNotEmpty && data[0] is Map) {
        typingUserId = data[0]['userId'];
      } else if (data is Map) {
        typingUserId = data['userId'];
      }

      // Only update typing status if it's from the OTHER user (not current user)
      if (typingUserId != null && typingUserId != InternalEndPoints.userId) {
        state = state.copyWith(isOtherUserTyping: true);
        log('[VIEWMODEL] Set isOtherUserTyping to true for convo: $conversationId');
      }
    });

    _socketService.onTypingStopped((data) {
      log('[VIEWMODEL] Typing stopped: $data');

      // Handle array format
      String? typingConversationId;
      String? typingUserId;

      if (data is List && data.isNotEmpty && data[0] is Map) {
        typingConversationId = data[0]['conversationId'];
        typingUserId = data[0]['userId'];
      } else if (data is Map) {
        typingConversationId = data['conversationId'];
        typingUserId = data['userId'];
      }

      if (typingConversationId == conversationId && typingUserId != InternalEndPoints.userId) {
        log('[VIEWMODEL] Set isOtherUserTyping to false for convo: $conversationId');
        state = state.copyWith(isOtherUserTyping: false);
      }
    });

    // Add read status listener
    _socketService.onMessagesRead((dynamic data) {
      try {
        log('[VIEWMODEL] Messages read event received: $data');

        // Check if this read event should be processed
        // No need to parse isActive since the server only sends these events
        // when a user is actively viewing messages

        // Update the read status for messages sent by the current user
        final updatedMessages = state.messages?.map((message) {
          // If the message was sent by the current user (isOwnMessage is true)
          if (message.isOwnMessage == true) {
            return message.copyWith(isSeen: true);
          }
          return message;
        }).toList();

        if (updatedMessages != null) {
          state = state.copyWith(
            messages: updatedMessages,
            isLoading: false,
            isError: false,
          );
          log('[VIEWMODEL] Updated seen status for messages');
        }
      } catch (e) {
        log('[VIEWMODEL] Error processing read status: $e');
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
      final readSuccess = await _chatService.markRead(conversationId);
      if (readSuccess) {
        log('[VIEWMODEL] Successfully marked conversation as read: $conversationId');
      } else {
        log('[VIEWMODEL] Failed to mark conversation as read: $conversationId');
      }

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
    // Only send the typing event to the server, don't update local state
    _socketService.sendTypingIndicator();
    _isTyping = true;

    // Reset the timer each time user types
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      stopTyping();
    });

    log('[VIEWMODEL] Started typing, sent indicator');
  }

  void stopTyping() {
    if (_isTyping) {
      _isTyping = false;
      _socketService.sendStopTypingIndicator();
      log('[VIEWMODEL] Stopped typing, sent indicator');
    }
  }

  // Add method to set active status
  void setActiveViewStatus(bool isActive) {
    bool wasActive = _isActivelyViewing;
    _isActivelyViewing = isActive;

    // If status changed, log it
    if (wasActive != isActive) {
      if (isActive) {
        log('[VIEWMODEL] User ENTERED conversation view: $conversationId');
      } else {
        log('[VIEWMODEL] User LEFT conversation view: $conversationId');
      }
    }
  }

  // Update the markConversationAsRead method:
  void markConversationAsRead() {
    try {
      // Only mark as read if the user is actively viewing the conversation
      if (!_isActivelyViewing) {
        log('[VIEWMODEL] Not marking as read - user not actively viewing conversation');
        return;
      }

      log('[VIEWMODEL] Marking conversation as read - user is actively viewing');
      _socketService.markConversationAsRead();

      // Also update local state for received messages
      final updatedMessages = state.messages?.map((message) {
        // Mark all messages from other users as seen
        if (message.isOwnMessage != true) {
          return message.copyWith(isSeen: true);
        }
        return message;
      }).toList();

      if (updatedMessages != null) {
        state = state.copyWith(messages: updatedMessages);
      }
    } catch (e) {
      log('[VIEWMODEL] Error marking conversation as read: $e');
    }
  }

  void cleanupSocketConnection() {
    try {
      // Stop any typing indicators
      stopTyping();

      // Wait briefly to ensure stop typing message is sent
      Future.delayed(const Duration(milliseconds: 100), () {
        // Signal socket service to disconnect gracefully
        _socketService.disconnectGracefully();
        log('[VIEWMODEL] Socket connection cleanup requested for conversation: $conversationId');
      });
    } catch (e) {
      log('[VIEWMODEL] Error during socket cleanup: $e');
    }
  }

  // Add this method for immediate typing indication

  // This method can be called for immediate local typing indication
  // before socket events are processed
  void setOtherUserTypingStatus(bool isTyping) {
    // Only allow this to be set to true if it's confirmed from a socket event
    // This prevents any other code from accidentally setting it
    if (state.isOtherUserTyping != isTyping) {
      state = state.copyWith(isOtherUserTyping: isTyping);
      log('[VIEWMODEL] Directly set typing status to $isTyping');
    }
  }

  // Add these methods

  // Add a temporary local message (for immediate UI feedback)
  void addLocalMessage(Message message) {
    if (state.messages != null) {
      final updatedMessages = [...state.messages!, message];
      state = state.copyWith(messages: updatedMessages);
    } else {
      state = state.copyWith(messages: [message]);
    }
  }

  // Update message progress status (pending, uploading, sent, failed)
  void updateMessageProgress(String messageId, MessageProgress progress) {
    if (!mounted) return;

    final currentMessages = [...?state.messages];
    final messageIndex = currentMessages.indexWhere((m) => m.messageId == messageId);

    if (messageIndex != -1) {
      final updatedMessage = currentMessages[messageIndex].copyWith(
        sendProgress: progress,
      );

      currentMessages[messageIndex] = updatedMessage;
      state = state.copyWith(messages: currentMessages);
      log('[VIEWMODEL] Updated message progress: $messageId -> $progress');
    }
  }

  // Updated sendMediaMessage to use compression
  Future<void> sendMediaMessage(String tempMessageId, List<String> base64MediaList) async {
    try {
      // Find the temp message in the state
      final currentMessages = [...?state.messages];
      final tempMessageIndex = currentMessages.indexWhere((m) => m.messageId == tempMessageId);

      if (tempMessageIndex == -1) {
        log('[VIEWMODEL] Temp message not found: $tempMessageId');
        return;
      }

      // Get the temp message
      final tempMessage = currentMessages[tempMessageIndex];

      log('[VIEWMODEL] Sending media message to socket...');
      log('[VIEWMODEL] Media count: ${base64MediaList.length}');

      // For document messages, ensure they're marked as sent immediately
      if (base64MediaList.any((media) =>
          media.contains('application/pdf') ||
          media.contains('application/msword') ||
          media.contains('text/plain') ||
          media.contains('application/vnd.ms-excel') ||
          media.contains('application/octet-stream') ||
          media.contains('document'))) {
        updateMessageProgress(tempMessageId, MessageProgress.sent);
      }

      // Send through socket with base64 data
      await _socketService.sendMessage(
        conversationId,
        Message(
          messageId: tempMessageId,
          senderId: tempMessage.senderId,
          receiverId: tempMessage.receiverId,
          senderName: tempMessage.senderName,
          message: tempMessage.message,
          media: base64MediaList, // Send the base64 data
          timestamp: tempMessage.timestamp,
          isOwnMessage: tempMessage.isOwnMessage,
          isSeen: tempMessage.isSeen,
          reacted: tempMessage.reacted,
          isEdited: tempMessage.isEdited,
          sendProgress: MessageProgress.sent,
        ),
      );

      log('[VIEWMODEL] Media message sent successfully');
    } catch (e) {
      log('[VIEWMODEL] Error sending media message: $e');
      // Let the error propagate so it can be handled by the caller
      rethrow;
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    cleanupSocketConnection();
    log('[VIEWMODEL] Disposed messages view model for conversation: $conversationId');
    super.dispose();
  }
}

final messagesViewModelProvider = StateNotifierProvider.family<MessagesViewModel, MessagesState, String>(
  (ref, conversationId) {
    // Check if socket is authenticated first
    final globalSocket = ref.watch(globalSocketServiceProvider);
    if (!globalSocket.isAuthenticated) {
      // Make sure socket is initialized
      globalSocket.initialize();
    }

    return MessagesViewModel(
      service: ref.watch(messageServiceProvider),
      socketService: SocketService(conversationId: conversationId),
      conversationId: conversationId,
    );
  },
);
