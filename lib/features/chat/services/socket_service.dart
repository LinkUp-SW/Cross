import 'dart:developer';
import 'dart:async';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/chat/model/message_model.dart';
import 'package:link_up/features/chat/services/global_socket_service.dart';

class SocketService {
  final GlobalSocketService _globalSocket = GlobalSocketService();
  final String conversationId;
  bool _isSetup = false;

  // Callbacks
  Function(dynamic)? _messageCallback;
  Function(dynamic)? _typingCallback;
  Function(dynamic)? _stopTypingCallback;
  Function(dynamic)? _messagesReadCallback;

  // Add these fields to support debouncing
  Timer? _markAsReadDebouncer;
  bool _hasPendingReadStatusUpdate = false;

  SocketService({required this.conversationId}) {
    _setupEventHandlers();
  }

  Future<void> get ready => _globalSocket.ready;

  void _setupEventHandlers() {
    if (_isSetup) return;

    // Set up listeners for conversation-specific events
    _globalSocket.on('private_message', _handleMessage);
    _globalSocket.on('new_message', _handleMessage);
    _globalSocket.on('message_sent', _handleMessage);
    _globalSocket.on('user_typing', _handleTyping);
    _globalSocket.on('user_stop_typing', _handleStopTyping);
    _globalSocket.on('messages_read', _handleMessagesRead); // Add this line

    _isSetup = true;
    log('[SOCKET] Event handlers set up for conversation: $conversationId');
  }

  void _handleMessage(dynamic data) {
    // Only process messages for this conversation
    final String messageConversationId = _extractConversationId(data);
    if (messageConversationId == conversationId && _messageCallback != null) {
      _messageCallback!(data);
    }
  }

  void _handleTyping(dynamic data) {
    final String typingConversationId = _extractConversationId(data);

    // Immediately notify callback without any delay
    if (typingConversationId == conversationId && _typingCallback != null) {
      _typingCallback!(data);
      log('[SOCKET] Received typing indicator event');
    }
  }

  void _handleStopTyping(dynamic data) {
    final String typingConversationId = _extractConversationId(data);
    if (typingConversationId == conversationId && _stopTypingCallback != null) {
      _stopTypingCallback!(data);
    }
  }

  void _handleMessagesRead(dynamic data) {
    final String readConversationId = _extractConversationId(data);
    if (readConversationId == conversationId && _messagesReadCallback != null) {
      _messagesReadCallback!(data);
    }
  }

  String _extractConversationId(dynamic data) {
    if (data is Map && data.containsKey('conversationId')) {
      return data['conversationId'];
    } else if (data is List && data.isNotEmpty && data[0] is Map && data[0].containsKey('conversationId')) {
      return data[0]['conversationId'];
    }
    return '';
  }

  void onMessageReceived(Function(dynamic) callback) {
    _messageCallback = callback;
  }

  void onTypingStarted(Function(dynamic) callback) {
    _typingCallback = callback;
  }

  void onTypingStopped(Function(dynamic) callback) {
    _stopTypingCallback = callback;
  }

  void onMessagesRead(Function(dynamic) callback) {
    _messagesReadCallback = callback;
  }

  Future<void> sendMessage(String conversationId, Message message) async {
    try {
      final messageData = {
        'conversationId': conversationId,
        'message': message.message,
        'messageData': {
          'messageId': message.messageId,
          'senderId': message.senderId,
          'senderName': message.senderName,
          'message': message.message,
          'media': message.media,
          'timestamp': message.timestamp.toIso8601String(),
          'isSeen': message.isSeen,
          'isOwnMessage': message.isOwnMessage,
          'isEdited': message.isEdited,
        },
        'to': message.receiverId ?? "User-38", // Use the actual receiver ID
      };

      log('[SOCKET] Sending message: $messageData');
      await _globalSocket.emit('private_message', messageData);
    } catch (e, stack) {
      log('[SOCKET] Error sending message: $e\n$stack');
    }
  }

  void sendTypingIndicator() {
    // Remove async/await to eliminate delay
    try {
      // Emit the event synchronously without awaiting
      _globalSocket.emit('typing', {
        'conversationId': conversationId,
        'userId': InternalEndPoints.userId,
      });
      log('[SOCKET] Sent typing indicator for conversation: $conversationId');
    } catch (e) {
      log('[SOCKET] Error sending typing indicator: $e');
    }
  }

  Future<void> sendStopTypingIndicator() async {
    try {
      await _globalSocket.emit('stop_typing', {
        'conversationId': conversationId,
        'userId': InternalEndPoints.userId,
      });
    } catch (e) {
      log('[SOCKET] Error sending stop typing indicator: $e');
    }
  }

  Future<void> markConversationAsRead() async {
    try {
      // Cancel any pending debounce timer
      _markAsReadDebouncer?.cancel();

      // Set flag to track pending updates
      _hasPendingReadStatusUpdate = true;

      // Debounce the mark as read event to prevent rapid consecutive calls
      _markAsReadDebouncer = Timer(const Duration(milliseconds: 500), () {
        if (_hasPendingReadStatusUpdate) {
          _globalSocket.emit('mark_as_read', {
            'conversationId': conversationId,
          });
          log('[SOCKET] Marked conversation as read: $conversationId (debounced)');
          _hasPendingReadStatusUpdate = false;
        }
      });
    } catch (e) {
      log('[SOCKET] Error marking conversation as read: $e');
      _hasPendingReadStatusUpdate = false;
    }
  }

  void markAsRead() {
    // This empty method prevents automatic marking as read
    // Do not add implementation here - only mark as read when explicitly called
  }

  // Add a method to cancel pending read updates when leaving the chat
  void cancelPendingReadStatus() {
    _markAsReadDebouncer?.cancel();
    _hasPendingReadStatusUpdate = false;
  }

  void cleanupSocketConnection() {
    try {
      // Cancel any pending mark as read requests
      cancelPendingReadStatus();

      // Unregister event handlers for this conversation
      _globalSocket.off('private_message', _handleMessage);
      _globalSocket.off('new_message', _handleMessage);
      _globalSocket.off('message_sent', _handleMessage);
      _globalSocket.off('user_typing', _handleTyping);
      _globalSocket.off('user_stop_typing', _handleStopTyping);
      _globalSocket.off('messages_read', _handleMessagesRead); // Add this line

      _isSetup = false;
      log('[SOCKET] Cleaned up handlers for conversation: $conversationId');
    } catch (e) {
      log('[SOCKET] Error during cleanup: $e');
    }
  }

  void disconnectGracefully() {
    // Cancel any pending read updates before disconnecting
    cancelPendingReadStatus();
    cleanupSocketConnection();

    // We don't disconnect the global socket, just leave the conversation
    _globalSocket.emit('leaving_conversation', {
      'conversationId': conversationId,
      'userId': InternalEndPoints.userId,
    });
  }
}
