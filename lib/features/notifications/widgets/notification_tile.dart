import 'package:flutter/material.dart';

class NotificationTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage('assets/images/profile.png'), // Placeholder
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
    );
  }
}
