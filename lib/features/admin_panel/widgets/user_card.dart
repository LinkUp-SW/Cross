// THEMED VERSION of user_card.dart (no logic changed)
import 'package:flutter/material.dart';
import 'package:link_up/features/admin_panel/model/users_model.dart';
import 'package:link_up/shared/themes/text_styles.dart';

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
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(user.profileImageUrl),
          radius: 24,
        ),
        title: Text(
          '${user.firstName} ${user.lastName}',
          style: TextStyles.font18_700Weight.copyWith(
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.email,
              style: TextStyles.font14_400Weight.copyWith(
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'ID: ${user.id} | Type: ${user.type}',
              style: TextStyles.font12_500Weight.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: theme.colorScheme.error),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
