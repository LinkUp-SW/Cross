import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/notifications/viewModel/notification_view_model.dart';
import '../widgets/notification_tile.dart';
import '../widgets/notification_app_bar.dart';
import '../widgets/notification_filter_widget.dart';

class NotificationsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationsViewModelProvider);
    final notificationViewModel = ref.read(notificationsViewModelProvider.notifier);

    return Scaffold(
      appBar: NotificationAppBar(),
      body: Column(
        children: [
          // Pass filter data
          NotificationFilterWidget(
            selectedFilter: notificationState.selectedFilter,
            onFilterSelected: (filter) => notificationViewModel.setFilter(filter),
          ),
          Expanded(
            child: notificationState.isLoading
                ? const Center(child: CircularProgressIndicator()) //Show loading spinner
                : notificationState.notifications.isEmpty
                    ? const Center(child: Text("No notifications available")) //  Handle empty state
                    : ListView.builder(
                        itemCount: notificationState.filteredNotifications.length, 
                        itemBuilder: (context, index) {
                          final notification = notificationState.filteredNotifications[index];

                          return NotificationTile(
                            notification: notification,
                            onTap: () {
                            notificationViewModel.markAsRead(notification.id); // Mark notification as read
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
