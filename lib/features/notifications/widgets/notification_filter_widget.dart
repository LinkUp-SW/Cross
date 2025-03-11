import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/notification_state.dart';
import '../viewModel/notification_view_model.dart';

class NotificationFilterWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationViewModelProvider);
    final notificationViewModel = ref.read(notificationViewModelProvider.notifier);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: NotificationFilter.values.map((filter) {
        return ChoiceChip(
          label: Text(filter.toString().split('.').last),
          selected: notificationState.selectedFilter == filter,
          onSelected: (_) => notificationViewModel.setFilter(filter),
        );
      }).toList(),
    );
  }
}
