import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../chat/services/global_socket_service.dart';
import '../model/notification_model.dart';

class NotificationSenderService {
  final GlobalSocketService _socketService;

  NotificationSenderService(this._socketService);

  Future<bool> sendNotification({
    required String recipientId,
    required String senderId,
    required NotificationFilter type,
    String? content,
    String? referenceId,
  }) async {
    try {
      // Wait for socket to be ready before sending
      await _socketService.ready;

      // Create the payload to send through socket
      final Map<String, dynamic> payload = {
        'recipientId': recipientId,
        'senderId': senderId,
        'type': _mapNotificationTypeToString(type),
        'content': content ?? '',
        'referenceId': referenceId ?? '',
      };

      // Emit the event to server
      _socketService.emit('new_notification', payload);

      print('📤 Notification sent: $payload');
      return true;
    } catch (e) {
      print('❌ Error sending notification: $e');
      return false;
    }
  }

  // Helper function to convert enum to string for backend
  String _mapNotificationTypeToString(NotificationFilter type) {
    switch (type) {
      case NotificationFilter.Posts:
        return 'posts';
      case NotificationFilter.CONNECTION_REQUEST:
        return 'connection_request';
      case NotificationFilter.CONNECTION_ACCEPTED:
        return 'connection_accepted';
      case NotificationFilter.FOLLOW:
        return 'follow';
      case NotificationFilter.All:
      default:
        return 'general';
    }
  }
}

// Provider for the notification sender service
final notificationSenderServiceProvider = Provider<NotificationSenderService>((ref) {
  final socketService = ref.watch(globalSocketServiceProvider);
  return NotificationSenderService(socketService);
});
