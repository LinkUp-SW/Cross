// lib/features/admin_panel/view/users_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/admin_panel/state/users_state.dart';
import 'package:link_up/features/admin_panel/viewModel/users_provider.dart';
import 'package:link_up/features/admin_panel/widgets/admin_drawer.dart';
import 'package:link_up/features/admin_panel/widgets/admin_name.dart';
import 'package:link_up/features/admin_panel/widgets/user_card.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 200) {
      ref.read(userProvider.notifier).loadMoreUsers();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(userProvider);
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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: state is UserLoaded
            ? RefreshIndicator(
                onRefresh: notifier.refreshUsers,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: state.users.length + (notifier.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < state.users.length) {
                      final user = state.users[index];
                      return UserCard(
                        user: user,
                        onDelete: () => notifier.deleteUser(user.id),
                      );
                    }
                    // show a loading indicator at the bottom
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              )
            : switch (state) {
                UserInitial() || UserLoading() =>
                  const Center(child: CircularProgressIndicator()),
                UserError(:final message) =>
                  Center(child: Text('❌ $message')),
                _ => const SizedBox(),
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
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
