// lib/features/profile/state/user_activity_state.dart
import 'package:flutter/foundation.dart' show immutable;
import 'package:link_up/features/Home/model/post_model.dart'; // Import your PostModel

@immutable
class UserActivityState {
  final List<PostModel> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isError;
  final String? errorMessage;
  final int? nextCursor; // Using int? based on your existing code

  const UserActivityState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isError = false,
    this.errorMessage,
    this.nextCursor,
  });

  factory UserActivityState.initial() {
    return const UserActivityState(isLoading: true); // Start in loading state
  }

  UserActivityState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isError,
    String? errorMessage,
    int? nextCursor, // Allow setting cursor to null
    bool clearError = false,
  }) {
    return UserActivityState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isError: isError ?? this.isError,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      nextCursor: nextCursor, // Directly assign the new value
    );
  }
}