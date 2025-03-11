import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/notification_state.dart';

class NotificationViewModel extends StateNotifier<NotificationState> {
  NotificationViewModel() : super(NotificationState());

  /// **Set the selected filter (All, Jobs, Mentions, Posts)**
  void setFilter(NotificationFilter filter) {
    state = state.copyWith(selectedFilter: filter);
  }
}

/// Define the provider globally (not inside the widget)**
final notificationViewModelProvider = StateNotifierProvider<NotificationViewModel, NotificationState>(
  (ref) => NotificationViewModel(),
);
