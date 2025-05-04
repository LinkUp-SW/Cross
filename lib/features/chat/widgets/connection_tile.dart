import 'package:flutter/material.dart';
import '../model/connections_chat_model.dart';

class ConnectionTile extends StatelessWidget {
  final ConnectionsChatModel connection;
  final VoidCallback? onTap;

  const ConnectionTile({
    Key? key,
    required this.connection,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(connection.profilePicture),
              onBackgroundImageError: (_, __) {},
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '${connection.firstName} ${connection.lastName}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
