/* import 'dart:async';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/chat/services/global_socket_service.dart';
import 'package:link_up/features/notifications/services/local_push_notification.dart';

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();
  
  bool _isRunning = false;

  Future<void> initialize() async {
    if (_isRunning) return;
    
    // Get instances from providers
    final container = ProviderContainer();
    final socketService = container.read(globalSocketServiceProvider);
    final localpushService = container.read(localPushNotificationServiceProvider);
    
    // Set up background callback
    final callback = PluginUtilities.getCallbackHandle(_backgroundCallback)?.toRawHandle();
    
    // Register background callback (keep socket alive)
    _isRunning = true;
  }
  
  // Background callback function
  static void _backgroundCallback() async {
    // Keep socket connection alive in background
    // This is a simplified implementation
    final container = ProviderContainer();
    final socketService = container.read(globalSocketServiceProvider);
    
    // Ensure socket remains connected
    if (!socketService.isAuthenticated) {
      await socketService.initialize();
    }
  }
}

// Provider for background service
final backgroundServiceProvider = Provider<BackgroundService>((ref) {
  return BackgroundService();
}); */