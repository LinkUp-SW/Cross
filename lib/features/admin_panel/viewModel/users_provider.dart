import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/admin_panel/model/users_model.dart';
import 'package:link_up/features/admin_panel/services/users_service.dart';
import 'package:link_up/features/admin_panel/state/users_state.dart';


final userServiceProvider = Provider((ref) => UserService());

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final service = ref.watch(userServiceProvider);
  return UserNotifier(service);
});

class UserNotifier extends StateNotifier<UserState> {
  final UserService _service;

  UserNotifier(this._service) : super(const UserInitial()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = const UserLoading();
    try {
      final users = await _service.fetchUsers();
      state = UserLoaded(users);
    } catch (e) {
      state = UserError("Failed to load users");
    }
  }

  Future<void> addUser(UserModel user) async {
    try {
      if (state is! UserLoaded) return;
      final current = (state as UserLoaded).users;
      await _service.addUser(user);
      state = UserLoaded([...current, user]);
    } catch (e) {
      state = UserError("Failed to add user");
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      if (state is! UserLoaded) return;
      final current = (state as UserLoaded).users;
      await _service.deleteUser(id);
      state = UserLoaded(current.where((u) => u.id != id).toList());
    } catch (e) {
      state = UserError("Failed to delete user");
    }
  }
}
