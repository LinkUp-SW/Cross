/* import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocalPushNotificationService {
  static final LocalPushNotificationService _instance = LocalPushNotificationService._internal();
  factory LocalPushNotificationService() => _instance;
  LocalPushNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Configure local notifications
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const IOSInitializationSettings iosSettings = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onSelectNotification: _onSelectNotification,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    _initialized = true;
  }

  Future<void> _createNotificationChannels() async {
    // Create channel for posts notifications
    const AndroidNotificationChannel postsChannel = AndroidNotificationChannel(
      'posts_channel',
      'Posts Notifications',
      description: 'Notifications about posts, comments, and reactions',
      importance: Importance.high,
    );

    // Create channel for connections notifications
    const AndroidNotificationChannel connectionsChannel = AndroidNotificationChannel(
      'connections_channel',
      'Connections Notifications',
      description: 'Notifications about connection requests and updates',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(postsChannel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(connectionsChannel);
  }

  Future<void> _onSelectNotification(String? payload) async {
    // Handle notification tap
    if (payload != null) {
      // Navigate to appropriate screen based on payload
      debugPrint('Notification tapped with payload: $payload');
      // TODO: Add navigation logic here
    }
  }

  // Show local notification from socket data
  Future<void> showNotificationFromSocketData(Map<String, dynamic> data) async {
    try {
      // Get notification type to determine channel
      final notificationType = data['type'] as String;
      final String channelId = _getChannelIdForType(notificationType);

      // Create Android notification details
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channelId,
        channelId == 'posts_channel' ? 'Posts Notifications' : 'Connections Notifications',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      // Create iOS notification details
      const IOSNotificationDetails iosDetails = IOSNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Create platform specific details
      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Format notification content
      final String title = _getNotificationTitle(data);
      final String body = data['content'] ?? 'You have a new notification';

      // Show the notification
      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        notificationDetails,
        payload: data['id'],
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  String _getChannelIdForType(String type) {
    // Determine the channel ID based on notification type
    switch (type.toLowerCase()) {
      case 'reacted':
      case 'comment':
      case 'posts':
        return 'posts_channel';
      case 'connection_request':
      case 'connection_accepted':
      case 'follow':
      case 'connections':
        return 'connections_channel';
      default:
        return 'posts_channel'; // Default channel
    }
  }

  String _getNotificationTitle(Map<String, dynamic> data) {
    final String senderName = data['senderName'] ?? 'Someone';
    switch ((data['type'] as String).toLowerCase()) {
      case 'reacted':
        return '$senderName reacted to your post';
      case 'comment':
        return '$senderName commented on your post';
      case 'connection_request':
        return '$senderName sent you a connection request';
      case 'connection_accepted':
        return '$senderName accepted your connection request';
      case 'follow':
        return '$senderName started following you';
      default:
        return 'New Notification';
    }
  }
}

// Provider for push notification service
final localPushNotificationServiceProvider = Provider<LocalPushNotificationService>((ref) {
  return LocalPushNotificationService();
});
 */