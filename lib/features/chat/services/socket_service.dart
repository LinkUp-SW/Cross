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
    if (typingConversationId == conversationId && _typingCallback != null) {
      _typingCallback!(data);
    }
  }

  void _handleStopTyping(dynamic data) {
    final String typingConversationId = _extractConversationId(data);
    if (typingConversationId == conversationId && _stopTypingCallback != null) {
      _stopTypingCallback!(data);
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

  Future<void> sendTypingIndicator() async {
    try {
      await _globalSocket.emit('typing', {
        'conversationId': conversationId,
        'userId': InternalEndPoints.userId,
      });
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

  void markAsRead() {
    _globalSocket.emit('mark_as_read', {'conversationId': conversationId});
  }

  void cleanupSocketConnection() {
    try {
      // Unregister event handlers for this conversation
      _globalSocket.off('private_message', _handleMessage);
      _globalSocket.off('new_message', _handleMessage);
      _globalSocket.off('message_sent', _handleMessage);
      _globalSocket.off('user_typing', _handleTyping);
      _globalSocket.off('user_stop_typing', _handleStopTyping);

      _isSetup = false;
      log('[SOCKET] Cleaned up handlers for conversation: $conversationId');
    } catch (e) {
      log('[SOCKET] Error during cleanup: $e');
    }
  }

  void disconnectGracefully() {
    cleanupSocketConnection();

    // We don't disconnect the global socket, just leave the conversation
    _globalSocket.emit('leaving_conversation', {
      'conversationId': conversationId,
      'userId': InternalEndPoints.userId,
    });
  }
}
