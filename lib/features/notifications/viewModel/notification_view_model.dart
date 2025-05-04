import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../state/notification_state.dart';
import '../model/notification_model.dart';


final notificationServiceProvider = Provider<NotificationService>((ref) {
  // For switching between mock and real service
  
  return  NotificationService();
});

final notificationsViewModelProvider = StateNotifierProvider.autoDispose<NotificationsViewModel, NotificationState>(
  (ref) => NotificationsViewModel(ref.watch(notificationServiceProvider)),
);

class NotificationsViewModel extends StateNotifier<NotificationState> {
  final NotificationService service;

  NotificationsViewModel(this.service) : super(NotificationState(notifications: [])) {
    fetchNotifications();
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

  void markAsRead(String notificationId) {
    List<NotificationModel> updatedNotifications = state.notifications.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();

    state = state.copyWith(notifications: updatedNotifications);
  }
}
