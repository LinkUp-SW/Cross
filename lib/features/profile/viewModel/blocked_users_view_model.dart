import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/state/blocked_users_state.dart';
import 'package:link_up/features/profile/model/blocked_user_model.dart';

class BlockedUsersUnblocking extends BlockedUsersLoaded {
  final String unblockingUserId;
  const BlockedUsersUnblocking(super.users, this.unblockingUserId);
}
class BlockedUsersViewModel extends StateNotifier<BlockedUsersState> {
  final ProfileService _profileService;

  BlockedUsersViewModel(this._profileService) : super(const BlockedUsersInitial()) {
    fetchBlockedUsers();
  }

  Future<void> fetchBlockedUsers() async {
    if (state is BlockedUsersLoading) return;

    log("[BlockedUsersVM] Fetching blocked users...");
    state = const BlockedUsersLoading();
    try {
      final users = await _profileService.getBlockedUsers();
      if (mounted) {
        log("[BlockedUsersVM] Fetched ${users.length} blocked users.");
        state = BlockedUsersLoaded(users);
      }
    } catch (e, s) {
      log("[BlockedUsersVM] Error fetching blocked users: $e", stackTrace: s);
      if (mounted) {
        state = BlockedUsersError('Failed to load blocked users: ${e.toString()}');
      }
    }
  }

 Future<bool> unblockUser(String userId, String password) async {
    if (state is! BlockedUsersLoaded) {
       log("[BlockedUsersVM] Cannot unblock user: State is not Loaded.");
       return false;
    }

    final currentState = state as BlockedUsersLoaded;
    final currentUsers = List<BlockedUser>.from(currentState.users); 

    log("[BlockedUsersVM] Attempting to unblock user: $userId");

    state = BlockedUsersUnblocking(currentUsers, userId);

    try {
      final success = await _profileService.unblockUser(userId, password);

      if (success && mounted) {
        log("[BlockedUsersVM] Successfully unblocked user: $userId");
        currentUsers.removeWhere((user) => user.userId == userId);
        state = BlockedUsersLoaded(currentUsers);
        return true; 
      } else if (mounted) {
         log("[BlockedUsersVM] Unblock service call returned false for user: $userId");
         state = BlockedUsersLoaded(currentUsers); 
         return false; 
      }
        return false; 
    } catch (e) {
      log("[BlockedUsersVM] Error unblocking user $userId: $e");
      if (mounted) {
        state = BlockedUsersLoaded(currentUsers);

        throw e; 
      }
      return false; 
    }
  }
}

final blockedUsersViewModelProvider =
    StateNotifierProvider.autoDispose<BlockedUsersViewModel, BlockedUsersState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return BlockedUsersViewModel(profileService /*, ref */);
});