import 'dart:developer';
import 'dart:async'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/profile/services/profile_services.dart';
import 'package:link_up/features/profile/state/blocked_users_state.dart';
import 'package:link_up/features/profile/model/blocked_user_model.dart';
import 'package:link_up/features/profile/viewModel/profile_view_model.dart'; 

class BlockedUsersUnblocking extends BlockedUsersLoaded {
  final String unblockingUserId;
  const BlockedUsersUnblocking(super.users, this.unblockingUserId);
}

class BlockedUsersViewModel extends StateNotifier<BlockedUsersState> {
  final ProfileService _profileService;
  final Ref _ref; 

  BlockedUsersViewModel(this._profileService, this._ref) : super(const BlockedUsersInitial()) {
    fetchBlockedUsers();
  }

  Future<void> fetchBlockedUsers() async {
    if (state is BlockedUsersLoading || state is BlockedUsersUnblocking || state is BlockedUsersBlocking) return;

    log("[BlockedUsersVM] Fetching blocked users...");
    state = const BlockedUsersLoading();
    try {
      final users = await _profileService.getBlockedUsers();
      if (mounted) {
        log("[BlockedUsersVM] Fetched ${users.length} blocked users.");
        // Sort users by date, most recent first
        users.sort((a, b) => b.date.compareTo(a.date));
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
     if (state is BlockedUsersUnblocking && (state as BlockedUsersUnblocking).unblockingUserId == userId) {
        log("[BlockedUsersVM] Already unblocking user $userId.");
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

   Future<bool> blockUser(String userId) async {
     log("[BlockedUsersVM] Attempting to block user: $userId");

     final previousState = state;
     List<BlockedUser> currentUsers = [];
     if(previousState is BlockedUsersLoaded) {
        currentUsers = List<BlockedUser>.from(previousState.users);
     } else if (previousState is BlockedUsersUnblocking) {
        currentUsers = List<BlockedUser>.from(previousState.users);
     }


     state = BlockedUsersBlocking(userId); 

     try {
       final success = await _profileService.blockUser(userId);

       if (success && mounted) {
         log("[BlockedUsersVM] Successfully blocked user: $userId");

          unawaited(_ref.read(profileViewModelProvider.notifier).fetchUserProfile());

         await fetchBlockedUsers(); 

         return true;
       }
     
        if (mounted) {
             log("[BlockedUsersVM] Block service call returned false or component unmounted for user: $userId");
             state = previousState;
        }
        return false;
     } catch (e) {
       log("[BlockedUsersVM] Error blocking user $userId: $e");
       if (mounted) {
          state = previousState;
         throw e;
       }
       return false; 
     }
   }

}

final blockedUsersViewModelProvider =
    StateNotifierProvider.autoDispose<BlockedUsersViewModel, BlockedUsersState>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return BlockedUsersViewModel(profileService, ref);
});