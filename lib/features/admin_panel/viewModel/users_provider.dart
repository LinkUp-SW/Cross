// lib/features/admin_panel/viewModel/users_provider.dart
import 'dart:developer';

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
  static const int _pageSize = 10;

  int  _cursor         = 0;
  bool _hasMore        = true;
  bool _isLoadMoreBusy = false;

  UserNotifier(this._service) : super(const UserInitial()) {
    refreshUsers();
  }

  /// Expose for the UI
  bool get hasMore => _hasMore;

  /// Pull-to-refresh: reload from scratch
  Future<void> refreshUsers() async {
    state = const UserLoading();
    _cursor  = 0;
    _hasMore = true;

    try {
      final users = await _service.fetchUsers(
        cursor: _cursor,
        limit:  _pageSize,
      );
      state   = UserLoaded(users);
      _cursor = users.length;
      _hasMore = users.length == _pageSize;
    } catch (e) {
      log("Error: $e");
      state = const UserError("Failed to load users");
    }
  }

  /// Infinite scroll: fetch next page and append
  Future<void> loadMoreUsers() async {
    if (!_hasMore || _isLoadMoreBusy || state is! UserLoaded) return;
    _isLoadMoreBusy = true;

    try {
      final nextPage = await _service.fetchUsers(
        cursor: _cursor,
        limit:  _pageSize,
      );
      final current = (state as UserLoaded).users;
      state   = UserLoaded([...current, ...nextPage]);
      _cursor += nextPage.length;
      _hasMore = nextPage.length == _pageSize;
    } catch (_) {
      // you could optionally set an error state here
    }
    _isLoadMoreBusy = false;
  }

  Future<void> addUser(UserModel user) async {
    if (state is! UserLoaded) return;
    try {
      final current = (state as UserLoaded).users;
      await _service.addUser(user);
      state = UserLoaded([user, ...current]);
    } catch (e) {
      state = const UserError("Failed to add user");
    }
  }

  Future<void> deleteUser(String id) async {
    if (state is! UserLoaded) return;
    try {
      final current = (state as UserLoaded).users;
      await _service.deleteUser(id);
      state = UserLoaded(current.where((u) => u.id != id).toList());
    } catch (e) {
      state = const UserError("Failed to delete user");
    }
  }
}
