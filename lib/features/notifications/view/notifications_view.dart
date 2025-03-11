import 'package:flutter/material.dart';
import '../widgets/notification_tile.dart';

class NotificationsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        itemCount: 5, // Placeholder count
        itemBuilder: (context, index) {
          return NotificationTile();
        },
      ),
    );
  }
}
