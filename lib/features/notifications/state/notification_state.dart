import '../model/notification_model.dart';

class NotificationState {
  final NotificationFilter selectedFilter;
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? errorMessage;
  final int unreadCount;
  NotificationState({
    this.selectedFilter = NotificationFilter.All,
    this.notifications = const [],
    this.isLoading = false,
    this.errorMessage,
    this.unreadCount = 0,
  });

  List<NotificationModel> get filteredNotifications {
    if (selectedFilter == NotificationFilter.All) {
      return notifications;
    }
    //  Filter notifications based on type
    final filteredList = notifications.where((n) {
      return n.type == selectedFilter;
    }).toList();
    return filteredList;
  }

  NotificationState copyWith({
    NotificationFilter? selectedFilter,
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? errorMessage,
    int? unreadCount,
  }) {
    return NotificationState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
