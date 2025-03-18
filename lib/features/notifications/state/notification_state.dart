import '../model/notification_model.dart';


class NotificationState {
  final NotificationFilter selectedFilter;
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? errorMessage;

  NotificationState({
    this.selectedFilter = NotificationFilter.all,
    this.notifications = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  List<NotificationModel> get filteredNotifications {
  if (selectedFilter == NotificationFilter.all) {
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
  }) {
    return NotificationState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
