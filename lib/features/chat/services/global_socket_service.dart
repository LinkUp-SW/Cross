import 'dart:developer';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/core/services/storage.dart';

class GlobalSocketService {
  static final GlobalSocketService _instance = GlobalSocketService._internal();

  // Singleton factory constructor
  factory GlobalSocketService() {
    return _instance;
  }

  // Private constructor for singleton
  GlobalSocketService._internal();

  // Socket instance
  IO.Socket? _socket;
  bool _isAuthenticated = false;
  bool _isConnecting = false;

  // Add a completer to track when socket is ready
  final Completer<void> _readyCompleter = Completer<void>();
  Future<void> get ready => _readyCompleter.future;

  // Event callbacks
  final Map<String, List<Function(dynamic)>> _eventHandlers = {};

  // Get authentication status
  bool get isAuthenticated => _isAuthenticated;

  Future<void> initialize() async {
    if (_socket != null || _isConnecting) {
      log('[GLOBAL_SOCKET] Socket already initialized or connecting');
      return;
    }

    _isConnecting = true;

    try {
      log('[GLOBAL_SOCKET] Initializing global socket connection');
      final token = await getToken();

      if (token == null || token.isEmpty) {
        log('[GLOBAL_SOCKET] No token available for authentication');
        _isConnecting = false;
        return;
      }

      _socket = IO.io(
        InternalEndPoints.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .setQuery({'token': token})
            .enableReconnection()
            .enableAutoConnect()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .build(),
      );

      _setupConnectionHandlers();
      _socket!.connect();

      log('[GLOBAL_SOCKET] Socket initialization completed');
    } catch (e, stack) {
      log('[GLOBAL_SOCKET] Error initializing socket: $e\n$stack');
      _isConnecting = false;

      // If initialization fails, retry after a delay
      Future.delayed(const Duration(seconds: 3), () {
        initialize();
      });
    }
  }

  void _setupConnectionHandlers() {
    _socket!.onConnect((_) {
      log('[GLOBAL_SOCKET] Connected successfully');
      _authenticate();
    });

    _socket!.onConnectError((error) {
      log('[GLOBAL_SOCKET] Connection error: $error');
      _isAuthenticated = false;
      _isConnecting = false;
    });

    _socket!.onDisconnect((_) {
      log('[GLOBAL_SOCKET] Disconnected from server');
      _isAuthenticated = false;
      _isConnecting = false;
    });
  }

  void _authenticate() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      log('[GLOBAL_SOCKET] Authentication failed: No token available');
      _isConnecting = false;
      return;
    }

    log('[GLOBAL_SOCKET] Attempting authentication with token');
    _socket!.emit('authenticate', {'token': token});

    _socket!.once('authenticated', (data) {
      log('[GLOBAL_SOCKET] Authentication successful');
      _isAuthenticated = true;
      _isConnecting = false;

      // Complete the ready completer to indicate socket is ready for use
      if (!_readyCompleter.isCompleted) {
        _readyCompleter.complete();
      }

      // Set up default listeners
      _setupDefaultListeners();
    });

    _socket!.once('authentication_error', (error) {
      log('[GLOBAL_SOCKET] Authentication failed: $error');
      _isAuthenticated = false;
      _isConnecting = false;

      // Retry authentication after a delay
      Future.delayed(const Duration(seconds: 3), () {
        _authenticate();
      });
    });
  }

  void _setupDefaultListeners() {
    // Set up listeners for common events
    _socket!.on('new_message', (data) {
      _notifyEventListeners('new_message', data);
    });

    _socket!.on('private_message', (data) {
      _notifyEventListeners('private_message', data);
    });

    _socket!.on('message_sent', (data) {
      _notifyEventListeners('message_sent', data);
    });

    _socket!.on('user_typing', (data) {
      _notifyEventListeners('user_typing', data);
    });

    _socket!.on('user_stop_typing', (data) {
      _notifyEventListeners('user_stop_typing', data);
    });

    _socket!.on('messages_read', (data) {
      _notifyEventListeners('messages_read', data);
    });
  }

  void _notifyEventListeners(String event, dynamic data) {
    if (_eventHandlers.containsKey(event)) {
      for (var handler in _eventHandlers[event]!) {
        handler(data);
      }
    }
  }

  // Register a handler for a specific event
  void on(String event, Function(dynamic) handler) {
    if (!_eventHandlers.containsKey(event)) {
      _eventHandlers[event] = [];
    }

    _eventHandlers[event]!.add(handler);
  }

  // Remove a specific handler
  void off(String event, Function(dynamic) handler) {
    if (_eventHandlers.containsKey(event)) {
      _eventHandlers[event]!.remove(handler);
    }
  }

  // Remove all handlers for an event
  void offAll(String event) {
    _eventHandlers.remove(event);
  }

  Future<void> emit(String event, dynamic data) async {
    if (!_isAuthenticated) {
      log('[GLOBAL_SOCKET] Socket not authenticated, waiting for authentication...');
      try {
        await ready.timeout(const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('Authentication timed out'));
      } catch (e) {
        log('[GLOBAL_SOCKET] Authentication timeout, attempting to emit anyway');
      }
    }

    if (_socket != null) {
      log('[GLOBAL_SOCKET] Emitting $event with data: $data');
      _socket!.emit(event, data);
    } else {
      log('[GLOBAL_SOCKET] Cannot emit event: socket is null');
    }
  }

  void dispose() {
    try {
      if (_socket != null) {
        log('[GLOBAL_SOCKET] Disposing global socket');
        _socket!.disconnect();
        _socket!.dispose();
        _socket = null;
        _isAuthenticated = false;
        _isConnecting = false;
        _eventHandlers.clear();
      }
    } catch (e) {
      log('[GLOBAL_SOCKET] Error disposing socket: $e');
    }
  }
}

// Provider for the global socket service
final globalSocketServiceProvider = Provider<GlobalSocketService>((ref) {
  return GlobalSocketService();
});
