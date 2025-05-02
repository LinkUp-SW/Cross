import 'dart:developer';
import 'package:link_up/features/chat/model/message_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/core/services/storage.dart';

class SocketService {
  late IO.Socket _socket;
  final String conversationId;
  bool _isAuthenticated = false;

  SocketService({required this.conversationId}) {
    initSocket();
  }

  Future<void> initSocket() async {
    try {
      log('[SOCKET] Initializing socket connection...');
      final token = await getToken();

      if (token == null || token.isEmpty) {
        log('[SOCKET] No token available for authentication');
        return;
      }

      _socket = IO.io(
        InternalEndPoints.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders({'Authorization': 'Bearer $token'}) // Add token in headers
            .setQuery({'token': token}) // Also add token in query
            .enableReconnection()
            .enableAutoConnect()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .build(),
      );

      _setupConnectionHandlers();
      _socket.connect();
    } catch (e, stack) {
      log('[SOCKET] Error initializing socket: $e\n$stack');
    }
  }

  void _setupConnectionHandlers() {
    _socket.onConnect((_) {
      log('[SOCKET] Connected successfully');
      _authenticate();
    });

    _socket.onConnectError((error) {
      log('[SOCKET] Connection error: $error');
      _isAuthenticated = false;
    });

    _socket.onDisconnect((_) {
      log('[SOCKET] Disconnected from server');
      _isAuthenticated = false;
    });
  }

  void _authenticate() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      log('[SOCKET] Authentication failed: No token available');
      return;
    }

    log('[SOCKET] Attempting authentication with token');
    _socket.emit('authenticate', {'token': token});

    _socket.once('authenticated', (data) {
      log('[SOCKET] Authentication successful: $data');
      _isAuthenticated = true;
      _setupListeners();
    });

    _socket.once('authentication_error', (error) {
      log('[SOCKET] Authentication failed: $error');
      _isAuthenticated = false;
    });
  }

  void _setupListeners() {
    // Listen for new messages
    _socket.on('new_message', (data) {
      log('[SOCKET] Received message: $data');
      if (_messageCallback != null) {
        _messageCallback!(data);
      }
    });

    // Also listen for private messages (which might have a different format)
    _socket.on('private_message', (data) {
      log('[SOCKET] Received private message: $data');
      if (_messageCallback != null) {
        _messageCallback!(data);
      }
    });

    // Listen for message sent confirmation
    _socket.on('message_sent', (data) {
      log('[SOCKET] Message sent confirmation: $data');
      // Also trigger the message callback for sent messages to ensure both sides update
      if (_messageCallback != null) {
        _messageCallback!(data);
      }
    });

    // Listen for typing indicators
    _socket.on('user_typing', (data) {
      log('[SOCKET] User typing: $data');
      if (_typingCallback != null) {
        _typingCallback!(data);
      }
    });

    _socket.on('user_stop_typing', (data) {
      log('[SOCKET] User stopped typing: $data');
      if (_stopTypingCallback != null) {
        _stopTypingCallback!(data);
      }
    });

    // Listen for read receipts
    _socket.on('messages_read', (data) {
      log('[SOCKET] Messages read: $data');
    });
  }

  // Callback for handling messages
  Function(dynamic)? _messageCallback;

  // Callback for handling typing events
  Function(dynamic)? _typingCallback;
  Function(dynamic)? _stopTypingCallback;

  void onMessageReceived(Function(dynamic) callback) {
    _messageCallback = callback;
  }

  void onTypingStarted(Function(dynamic) callback) {
    _typingCallback = callback;
  }

  void onTypingStopped(Function(dynamic) callback) {
    _stopTypingCallback = callback;
  }

  void sendMessage(String conversationId, Message message) {
    if (!_isAuthenticated) {
      log('[SOCKET] Cannot send message: Not authenticated');
      _authenticate();
      return;
    }

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
      _socket.emit('private_message', messageData);
    } catch (e, stack) {
      log('[SOCKET] Error sending message: $e\n$stack');
    }
  }

  void sendTypingIndicator() {
    if (!_isAuthenticated) {
      log('[SOCKET] Not authenticated, cannot send typing indicator');
      return;
    }

    try {
      log('[SOCKET] Sending typing indicator for conversation: $conversationId');
      _socket.emit('typing', {
        'conversationId': conversationId,
        'userId': InternalEndPoints.userId,
      });
    } catch (e) {
      log('[SOCKET] Error sending typing indicator: $e');
    }
  }

  void sendStopTypingIndicator() {
    if (!_isAuthenticated) {
      log('[SOCKET] Not authenticated, cannot send stop typing indicator');
      return;
    }

    try {
      log('[SOCKET] Sending stop typing indicator for conversation: $conversationId');
      _socket.emit('stop_typing', {
        'conversationId': conversationId,
        'userId': InternalEndPoints.userId,
      });
    } catch (e) {
      log('[SOCKET] Error sending stop typing indicator: $e');
    }
  }

  void markAsRead() {
    _socket.emit('mark_as_read', {'conversationId': conversationId});
  }

  void disposeSocket(String conversationId) {
    try {
      _socket.off('new_message');
      _socket.off('user_typing');
      _socket.off('user_stop_typing');
      _socket.off('messages_read');
      _socket.off('authenticated');
      _socket.off('authentication_error');
      _socket.clearListeners();
      _socket.dispose();
      _isAuthenticated = false;
      log('[SOCKET] Socket disposed for conversation: $conversationId');
    } catch (e) {
      log('[SOCKET] Error disposing socket: $e');
    }
  }
}
