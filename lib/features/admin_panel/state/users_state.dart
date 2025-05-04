// lib/features/admin_panel/state/users_state.dart
import 'package:link_up/features/admin_panel/model/users_model.dart';

sealed class UserState {
  const UserState();
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  final List<UserModel> users;
  const UserLoaded(this.users);
}

class UserError extends UserState {
  final String message;
  const UserError(this.message);
}
