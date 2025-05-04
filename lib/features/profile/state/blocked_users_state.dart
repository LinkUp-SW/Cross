import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:link_up/features/profile/model/blocked_user_model.dart'; 
@immutable
sealed class BlockedUsersState {
  const BlockedUsersState();
}

class BlockedUsersInitial extends BlockedUsersState {
  const BlockedUsersInitial();
}

class BlockedUsersLoading extends BlockedUsersState {
  const BlockedUsersLoading();
}

class BlockedUsersLoaded extends BlockedUsersState {
  final List<BlockedUser> users;
  const BlockedUsersLoaded(this.users);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockedUsersLoaded &&
          runtimeType == other.runtimeType &&
          listEquals(users, other.users); 

  @override
  int get hashCode => Object.hashAll(users); 
}

class BlockedUsersError extends BlockedUsersState {
  final String message;
  const BlockedUsersError(this.message);

   @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockedUsersError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
class BlockedUsersBlocking extends BlockedUsersState {
  final String blockingUserId;
  const BlockedUsersBlocking(this.blockingUserId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockedUsersBlocking &&
          runtimeType == other.runtimeType &&
          blockingUserId == other.blockingUserId;

  @override
  int get hashCode => blockingUserId.hashCode;
}