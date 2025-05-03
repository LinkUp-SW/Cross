import 'package:link_up/features/my-network/model/people_i_follow_screen_model.dart';

class PeopleIFollowScreenState {
  final Set<FollowingCardModel>? followings;
  final int? followingsCount;
  final String? nextCursor;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isError;

  const PeopleIFollowScreenState({
    this.followings,
    this.followingsCount,
    this.nextCursor,
    required this.isLoading,
    required this.isLoadingMore,
    required this.isError,
  });

  factory PeopleIFollowScreenState.initial() {
    return const PeopleIFollowScreenState(
      followings: null,
      followingsCount: null,
      nextCursor: null,
      isLoading: true,
      isLoadingMore: false,
      isError: false,
    );
  }

  PeopleIFollowScreenState copyWith({
    final Set<FollowingCardModel>? followings,
    final int? followingsCount,
    final String? nextCursor,
    final bool? isLoading,
    final bool? isLoadingMore,
    final bool? isError,
  }) {
    return PeopleIFollowScreenState(
      followings: followings ?? this.followings,
      followingsCount: followingsCount ?? this.followingsCount,
      nextCursor: nextCursor ?? this.nextCursor,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isError: isError ?? this.isError,
    );
  }
}
