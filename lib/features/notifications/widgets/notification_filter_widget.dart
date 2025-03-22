import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/notifications/model/notification_model.dart';


class NotificationFilterWidget extends ConsumerWidget {
  final NotificationFilter selectedFilter;
  final Function(NotificationFilter) onFilterSelected;

  const NotificationFilterWidget({
    Key? key,
    required this.selectedFilter,
    required this.onFilterSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: NotificationFilter.values.map((filter) {
        return ChoiceChip(
          label: Text(filter.toString().split('.').last),
          selected: selectedFilter == filter,
          onSelected: (_) => onFilterSelected(filter),
        );
      }).toList(),
    );
  }
}
