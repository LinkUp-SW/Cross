import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/my-network/model/people_i_follow_screen_model.dart';
import 'package:link_up/features/my-network/services/people_i_follow_screen_services.dart';
import 'package:link_up/features/my-network/state/people_i_follow_screen_state.dart';

class PeopleIFollowScreenViewModel
    extends StateNotifier<PeopleIFollowScreenState> {
  final PeopleIFollowScreenServices _peopleIFollowScreenServices;

  PeopleIFollowScreenViewModel(
    this._peopleIFollowScreenServices,
  ) : super(
          PeopleIFollowScreenState.initial(),
        );

  Future<void> getFollowingsCount() async {
    state = state.copyWith(isLoading: true, isError: false);

    try {
      final followingsCount =
          await _peopleIFollowScreenServices.getFollowingsCount();

      state = state.copyWith(
        isLoading: false,
        followingsCount: followingsCount,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, isError: true);
    }
  }

  Future<void> getFollowingsList(
    Map<String, dynamic>? queryParameters,
  ) async {
    state = state.copyWith(isLoading: true, isError: false);

    try {
      final response = await _peopleIFollowScreenServices.getFollowingsList(
        queryParameters: queryParameters,
      );

      // Parse the connections from the response
      final List<FollowingCardModel> followings =
          (response['following'] as List)
              .map((following) => FollowingCardModel.fromJson(following))
              .toList();
      final nextCursor = response['nextCursor'];
      state = state.copyWith(
          isLoading: false, followings: followings, nextCursor: nextCursor);
    } catch (e) {
      state = state.copyWith(isLoading: false, isError: true);
    }
  }

  Future<void> loadMoreFollowings({
    required int paginationLimit,
  }) async {
    final currentState = state;

    // Don't load if we're already loading or at the end
    if (currentState.isLoadingMore || currentState.nextCursor == null) return;

    state = currentState.copyWith(isLoadingMore: true);

    try {
      final response = await _peopleIFollowScreenServices.getFollowingsList(
        queryParameters: {
          'limit': '$paginationLimit',
          'cursor': currentState.nextCursor,
        },
      );

      final List<dynamic> followingData = response['following'] as List? ?? [];
      // If server returns empty data, we've reached the end
      if (followingData.isEmpty) {
        state = currentState.copyWith(
          isLoadingMore: false,
          nextCursor: null, // Set to null to prevent more requests
        );
        return;
      }

      final newFollowings =
          followingData.map((f) => FollowingCardModel.fromJson(f)).toList();

      // Check for duplicates using cardId
      final existingIds =
          currentState.followings?.map((f) => f.cardId).toSet() ?? {};
      final uniqueNewFollowings = newFollowings
          .where((following) => !existingIds.contains(following.cardId))
          .toList();

      // If we got no unique results despite getting data, we're at the end
      if (uniqueNewFollowings.isEmpty) {
        state = currentState.copyWith(
          isLoadingMore: false,
          nextCursor: null, // Set to null to prevent more requests
        );
        return;
      }

      final List<FollowingCardModel> allFollowings = [
        ...currentState.followings ?? [],
        ...uniqueNewFollowings
      ];

      state = currentState.copyWith(
        followings: allFollowings,
        nextCursor: response['nextCursor'],
        isLoadingMore: false,
      );
    } catch (e) {
      state = currentState.copyWith(isLoadingMore: false);
    }
  }

  Future<void> unfollow(String userId) async {
    state = state.copyWith(isLoading: true, isError: false);
    try {
      await _peopleIFollowScreenServices.unfollow(userId);

      // Remove the connection from the connections list
      if (state.followings != null) {
        final updatedFollowings = state.followings!
            .where((following) => following.cardId != userId)
            .toList();

        state = state.copyWith(
          isLoading: false,
          followings: updatedFollowings,
          followingsCount: updatedFollowings.length,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, isError: true);
    }
  }
}

final peopleIFollowScreenViewModelProvider = StateNotifierProvider<
    PeopleIFollowScreenViewModel, PeopleIFollowScreenState>(
  (ref) {
    return PeopleIFollowScreenViewModel(
      ref.read(peopleIFollowScreenServicesProvider),
    );
  },
);
