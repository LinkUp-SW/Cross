import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../services/notification_sender_service.dart';
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
    final notificationSender = ref.watch(notificationSenderServiceProvider);

    return NotificationsViewModel(service, socketService, inAppNotificationService, notificationSender);
  },
);

class NotificationsViewModel extends StateNotifier<NotificationState> {
  final NotificationService service;
  final GlobalSocketService socketService;
  final InAppNotificationService inAppNotificationService;
  final NotificationSenderService notificationSender;

  NotificationsViewModel(this.service, this.socketService, this.inAppNotificationService, this.notificationSender)
      : super(NotificationState(notifications: [])) {
    fetchNotifications();
    fetchUnreadCount();
    _setupSocketListeners();
  }

  // Function to send notifications for different actions
  Future<bool> sendNotification({
    required String recipientId,
    required String senderId,
    required NotificationFilter type,
    String? content,
    String? referenceId,
  }) async {
    return await notificationSender.sendNotification(
      recipientId: recipientId,
      senderId: senderId,
      type: type,
      content: content,
      referenceId: referenceId,
    );
  }

  // Convenience methods for specific notification types
  Future<bool> sendConnectionRequest({
    required String recipientId,
    required String senderId,
    String? userName,
  }) async {
    final content = ' sent you a connection request';
    return await sendNotification(
      recipientId: recipientId,
      senderId: senderId,
      type: NotificationFilter.CONNECTION_REQUEST,
      content: content,
      referenceId: senderId, // Reference the sender in this case
    );
  }

  Future<bool> sendConnectionAccepted({
    required String recipientId,
    required String senderId,
    String? userName,
  }) async {
    final content = ' accepted your connection request';
    return await sendNotification(
      recipientId: recipientId,
      senderId: senderId,
      type: NotificationFilter.CONNECTION_ACCEPTED,
      content: content,
      referenceId: senderId,
    );
  }

  Future<bool> sendFollowNotification({
    required String recipientId,
    required String senderId,
    String? userName,
  }) async {
    final content = userName != null ? '$userName started following you' : ' started following you';
    return await sendNotification(
      recipientId: recipientId,
      senderId: senderId,
      type: NotificationFilter.FOLLOW,
      content: content,
      referenceId: senderId,
    );
  }

  Future<bool> sendPostInteractionNotification({
    required String recipientId,
    required String senderId,
    required String postId,
    required String interactionType, // 'liked', 'commented', etc.
    String? userName,
  }) async {
    final content = ' $interactionType your post';
    return await sendNotification(
      recipientId: recipientId,
      senderId: senderId,
      type: NotificationFilter.Posts,
      content: content,
      referenceId: postId,
    );
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

      print('📩 Received notification data: $data');

      // Convert socket data to notification model format
      final Map<String, dynamic> notificationData = {
        'id': data['id'] ?? '',
        'content': data['content'] ?? '',
        'type': data['type'] ?? '',
        'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
        'isRead': false,
        'referenceId': data['referenceId'] ?? '',
        'sender': {
          'id': data['senderId'] ?? '',
          'firstName': data['senderName']?.toString().split(' ').first ?? '',
          'lastName': data['senderName']?.toString().split(' ').last ?? '',
          'profilePhoto': data['senderPhoto'] ?? '',
        }
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
            // When tapped, mark as read and navigate based on notification type
            markAsRead(notification.id);
            _navigateBasedOnNotificationType(notification);
          });
    } catch (e) {
      print('❌ Error processing notification: $e');
      state = state.copyWith(errorMessage: "Error processing new notification: ${e.toString()}");
    }
  }

  // Helper method for navigation based on notification type
  void _navigateBasedOnNotificationType(NotificationModel notification) {
    // This will be called when notification is tapped
    // Navigation logic can be implemented here or passed to a separate service
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
