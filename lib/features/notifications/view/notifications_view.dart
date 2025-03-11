import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/notification_tile.dart';
import '../widgets/notification_app_bar.dart'; 
import '../widgets/notification_filter_widget.dart'; 


class NotificationsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: NotificationAppBar(), 
      body: Column(
        children: [
          NotificationFilterWidget(), 
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Placeholder count
              itemBuilder: (context, index) {
                return NotificationTile();
              },
            ),
          ),
        ],
      ),
    );
  }
}
