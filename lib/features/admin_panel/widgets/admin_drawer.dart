// POLISHED VERSION of admin_drawer.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/core/services/storage.dart';
import 'package:link_up/features/admin_panel/widgets/admin_name.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.colorScheme.background,
      child: Column(
        children: [
          _buildSectionHeader("Admin Panel", theme),
          _buildDrawerItem(context, Icons.dashboard_outlined, 'Dashboard',
              () => context.go('/dashboard')),
          _buildDrawerItem(context, Icons.query_stats_outlined, 'Statistics',
              () => context.go('/statistics')),
          _buildDrawerItem(context, Icons.report_outlined, 'Reports',
              () => context.go('/contentModration')),
          _buildDrawerItem(context, Icons.people_alt_outlined, 'Users',
              () => context.go('/users')),
          const Spacer(),
          const Divider(),
          _buildDrawerItem(context, Icons.logout, 'Logout', () {
            context.push('/login');
            logout(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Logged out successfully")),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String label, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: TextStyles.font13_700Weight.copyWith(
            color: theme.hintColor,
          ),
        ),
      ),
    );
  }

  ListTile _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.iconTheme.color),
      title: Text(
        title,
        style: TextStyles.font15_700Weight.copyWith(
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      hoverColor: theme.hoverColor.withOpacity(0.05),
      onTap: onTap,
    );
  }
}
