// lib/features/profile/viewModel/user_activity_viewmodel.dart
import 'dart:async';
import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/Home/model/post_model.dart';
import 'package:link_up/features/profile/services/activity_services.dart';
import 'package:link_up/features/profile/state/user_activity_state.dart';

class UserActivityViewModel extends StateNotifier<UserActivityState> {
  final UserActivityService _activityService;
  final String userId;
  final int _limit = 10; // Number of posts to fetch per page

  // Timer for debouncing loadMore calls
  Timer? _debounce;

  UserActivityViewModel(this._activityService, this.userId)
      : super(UserActivityState.initial()) {
    fetchUserPosts(); // Fetch initial posts when ViewModel is created
  }

  Future<void> fetchUserPosts({bool isRefreshing = false}) async {
    if (state.isLoading && !isRefreshing) return; // Avoid concurrent fetches unless refreshing
    log("UserActivityVM: Fetching initial posts for user $userId. Is refreshing: $isRefreshing");
    state = state.copyWith(isLoading: true, isError: false, clearError: true);

    try {
      final response = await _activityService.getUserPosts(
        userId: userId,
        queryParameters: {'limit': _limit.toString(), 'cursor': '0'}, // Start from cursor 0
      );

      final List<PostModel> fetchedPosts = (response['posts'] as List? ?? [])
          .map((postJson) => PostModel.fromJson(postJson))
          .toList();
      final int? nextCursor = response['next_cursor'];

      if (mounted) {
        log("UserActivityVM: Fetched ${fetchedPosts.length} initial posts. Next cursor: $nextCursor");
        state = state.copyWith(
          posts: fetchedPosts,
          isLoading: false,
          nextCursor: nextCursor,
        );
      }
    } catch (e, stackTrace) {
      log("UserActivityVM: Error fetching initial posts: $e", stackTrace: stackTrace);
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          isError: true,
          errorMessage: e.toString(),
        );
      }
    }
  }

  Future<void> loadMorePosts() async {
    if (state.isLoadingMore || state.nextCursor == null || state.nextCursor == -1) {
      log("UserActivityVM: Not loading more. isLoadingMore=${state.isLoadingMore}, nextCursor=${state.nextCursor}");
      return; // Don't load if already loading or no more pages
    }

    // Debounce to prevent rapid calls
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
        log("UserActivityVM: Loading more posts for user $userId. Current cursor: ${state.nextCursor}");
        state = state.copyWith(isLoadingMore: true, isError: false, clearError: true);

      try {
        final response = await _activityService.getUserPosts(
          userId: userId,
          queryParameters: {'limit': _limit.toString(), 'cursor': state.nextCursor.toString()},
        );

        final List<PostModel> newPosts = (response['posts'] as List? ?? [])
            .map((postJson) => PostModel.fromJson(postJson))
            .toList();
        final int? nextCursor = response['next_cursor']; // Can be null

         log("UserActivityVM: Fetched ${newPosts.length} more posts. Next cursor: $nextCursor");

        if (mounted) {
          final currentPosts = state.posts;
          // Simple append, assumes API doesn't send duplicates on pagination
          final updatedPosts = List<PostModel>.from(currentPosts)..addAll(newPosts);

          state = state.copyWith(
            posts: updatedPosts,
            isLoadingMore: false,
            nextCursor: nextCursor, // Update cursor, could become null
          );
        }
      } catch (e, stackTrace) {
        log("UserActivityVM: Error loading more posts: $e", stackTrace: stackTrace);
        if (mounted) {
          state = state.copyWith(
            isLoadingMore: false,
            isError: true,
            errorMessage: e.toString(),
          );
        }
      }
    });
  }

    // Called when the ViewModel is disposed
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

// AutoDispose StateNotifierProvider that takes the userId
final userActivityViewModelProvider = StateNotifierProvider.autoDispose
    .family<UserActivityViewModel, UserActivityState, String>((ref, userId) {
  final activityService = ref.watch(userActivityServiceProvider);
  return UserActivityViewModel(activityService, userId);
});