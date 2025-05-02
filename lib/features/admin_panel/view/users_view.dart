import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/admin_panel/state/users_state.dart';
import 'package:link_up/features/admin_panel/viewModel/users_provider.dart';
import 'package:link_up/features/admin_panel/widgets/admin_drawer.dart';
import 'package:link_up/features/admin_panel/widgets/admin_name.dart';
import 'package:link_up/features/admin_panel/widgets/user_card.dart';

class UsersPage extends ConsumerWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userProvider);
    final notifier = ref.read(userProvider.notifier);

    return Scaffold(
      drawer: const AdminDrawer(),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/5559852.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: const Text(
          'Users',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: switch (state) {
          UserInitial() ||
          UserLoading() =>
            const Center(child: CircularProgressIndicator()),
          UserError(:final message) => Center(child: Text('❌ $message')),
          UserLoaded(:final users) => users.isEmpty
              ? const Center(child: Text('No users found.'))
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (_, i) => UserCard(
                    user: users[i],
                    onDelete: () => notifier.deleteUser(users[i].id),
                  ),
                ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newUser = await showAdminNameDialog(context);
          if (newUser != null) {
            await notifier.addUser(newUser);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${newUser.firstName} added')),
            );
          }
        },
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
    );
  }
}
