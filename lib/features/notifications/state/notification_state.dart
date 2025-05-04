import '../model/notification_model.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? errorMessage;
  final int unreadCount;
  final NotificationFilter selectedFilter;

  const NotificationState({
    required this.notifications,
    this.isLoading = false,
    this.errorMessage,
    this.unreadCount = 0,
    this.selectedFilter = NotificationFilter.All,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? errorMessage,
    int? unreadCount,
    NotificationFilter? selectedFilter,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  // Get notifications filtered by the currently selected filter
  List<NotificationModel> get filteredNotifications {
    if (selectedFilter == NotificationFilter.All) {
      return notifications;
    } else if (selectedFilter == NotificationFilter.CONNECTIONS) {
      // Show all connection-related notifications when CONNECTIONS filter is selected
      return notifications
          .where((notification) =>
              notification.type == NotificationFilter.CONNECTION_REQUEST ||
              notification.type == NotificationFilter.CONNECTION_ACCEPTED ||
              notification.type == NotificationFilter.FOLLOW)
          .toList();
    } else {
      // For other filters, exact match
      return notifications.where((notification) => notification.type == selectedFilter).toList();
    }
  }
}
