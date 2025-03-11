import 'package:flutter/material.dart';

class NotificationTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // White background for all notifications
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage('assets/images/profile.png'), // Placeholder image
        ),
        title: RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.black, fontSize: 16),
            children: [
              TextSpan(text: 'John Doe ', style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: 'liked your post.'),
            ],
          ),
        ),
        subtitle: Text('2h ago', style: TextStyle(color: Colors.grey)),
        onTap: () {
          // Action (to be implemented later)
        },
      ),
    );
  }
}
