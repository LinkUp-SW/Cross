import 'package:flutter/material.dart';
import 'package:link_up/features/admin_panel/model/users_model.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onDelete;

  const UserCard({
    Key? key,
    required this.user,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user.profileImageUrl),
          radius: 24,
        ),
        title: Text('${user.firstName} ${user.lastName}',
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            Text('ID: ${user.id} | Type: ${user.type}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
