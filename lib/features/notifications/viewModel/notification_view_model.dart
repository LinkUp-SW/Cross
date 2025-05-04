import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../state/notification_state.dart';
import '../model/notification_model.dart';
import '../../chat/services/global_socket_service.dart';
import '../services/in_app_notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final notificationsViewModelProvider = StateNotifierProvider.autoDispose<NotificationsViewModel, NotificationState>(
  (ref) {
    final service = ref.watch(notificationServiceProvider);
    final socketService = ref.watch(globalSocketServiceProvider);
    final inAppNotificationService = ref.watch(inAppNotificationServiceProvider);
    return NotificationsViewModel(service, socketService, inAppNotificationService);
  },
);

class NotificationsViewModel extends StateNotifier<NotificationState> {
  final NotificationService service;
  final GlobalSocketService socketService;
  final InAppNotificationService inAppNotificationService;

  NotificationsViewModel(this.service, this.socketService, this.inAppNotificationService)
      : super(NotificationState(notifications: [])) {
    fetchNotifications();
    fetchUnreadCount();
    _setupSocketListeners();
  }

  void _setupSocketListeners() async {
    // Wait for socket to be authenticated
    await socketService.ready;

    // Listen for new notifications
    socketService.on('new_notification', (data) {
      _handleNewNotification(data);
    });

    // Listen for unread count updates
    socketService.on('unread_notifications_count', (data) {
      if (data is Map && data.containsKey('count')) {
        final count = data['count'] as int;
        state = state.copyWith(unreadCount: count);
      }
    });
  }

  void _handleNewNotification(dynamic data) {
    try {
      // Convert socket data to NotificationModel
      final Map<String, dynamic> notificationData = {
        'recipientId': data['recipientId'],
        'content': data['content'],
        'type': data['type'],
        'referenceId': data['referenceId'] ,
        'senderId': data['senderId'],
        
      };

      final notification = NotificationModel.fromJson(notificationData);

      // Add new notification to the top of the list
      final updatedNotifications = [notification, ...state.notifications];
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: state.unreadCount + 1,
      );

      // Show in-app notification
      inAppNotificationService.showNotification(
          title: data['senderName'] ?? 'New Notification',
          message: data['content'] ?? '',
          imageUrl: data['senderPhoto'],
          onTap: () {
            // Handle notification tap if needed
            markAsRead(notification.id);
          });
    } catch (e) {
      state = state.copyWith(errorMessage: "Error processing new notification: ${e.toString()}");
    }
  }

  @override
  void dispose() {
    socketService.off('new_notification', _handleNewNotification);
    socketService.offAll('unread_notifications_count');
    super.dispose();
  }

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final notifications = await service.fetchNotifications();
      state = state.copyWith(notifications: notifications, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  void setFilter(NotificationFilter filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      // Call the API to mark notification as read on the server
      final success = await service.markNotificationAsRead(notificationId);

      if (success) {
        // Update local state if server update was successful
        List<NotificationModel> updatedNotifications = state.notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();

        state = state.copyWith(notifications: updatedNotifications);
      }
      fetchUnreadCount();
    } catch (e) {
      // Handle any errors from the API call
      state = state.copyWith(errorMessage: "Failed to mark notification as read: ${e.toString()}");
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final count = await service.getUnreadNotificationsCount();

      // Update state with the unread count
      state = state.copyWith(unreadCount: count);
    } catch (e) {
      // Handle any errors from the API call
      state = state.copyWith(errorMessage: "Failed to fetch unread notifications count: ${e.toString()}");
    }
  }
}
