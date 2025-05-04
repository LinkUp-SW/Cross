import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/notifications/model/notification_model.dart';

class NotificationFilterWidget extends ConsumerWidget {
  final NotificationFilter selectedFilter;
  final Function(NotificationFilter) onFilterSelected;

  const NotificationFilterWidget({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create a filtered list that excludes individual connection filters
    final filteredValues = NotificationFilter.values
        .where((filter) =>
            filter == NotificationFilter.All ||
            filter == NotificationFilter.Posts ||
            filter == NotificationFilter.CONNECTIONS)
        .toList();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: filteredValues.map((filter) {
        // Get a friendly display name for each filter
        String displayName;
        switch (filter) {
          case NotificationFilter.All:
            displayName = "All";
            break;
          case NotificationFilter.Posts:
            displayName = "Posts";
            break;
          case NotificationFilter.CONNECTIONS:
            displayName = "Connections";
            break;
          default:
            displayName = filter.toString().split('.').last;
        }

        return ChoiceChip(
          label: Text(displayName),
          selected: selectedFilter == filter ||
              // Consider connection request/accepted/follow as selected when CONNECTIONS is selected
              ((filter == NotificationFilter.CONNECTIONS) &&
                  (selectedFilter == NotificationFilter.CONNECTION_REQUEST ||
                      selectedFilter == NotificationFilter.CONNECTION_ACCEPTED ||
                      selectedFilter == NotificationFilter.FOLLOW)),
          onSelected: (_) => onFilterSelected(filter),
        );
      }).toList(),
    );
  }
}
