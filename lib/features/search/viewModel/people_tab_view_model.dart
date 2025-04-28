import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/search/model/people_search_card_model.dart';
import 'package:link_up/features/search/services/people_tab_services.dart';
import 'package:link_up/features/search/state/people_tab_state.dart';
import 'dart:developer';

class PeopleTabViewModel extends StateNotifier<PeopleTabState> {
  final PeopleTabServices _peopleTabServices;

  PeopleTabViewModel(this._peopleTabServices) : super(PeopleTabState.initial());

  Future<void> getPeopleSearch({
    required Map<String, dynamic> queryParameters,
  }) async {
    state = state.copyWith(isLoading: true, isError: false);
    try {
      final response = await _peopleTabServices.getPeopleSearch(
          queryParameters: queryParameters);
      final Set<PeopleCardModel> people = (response['people'] as List)
          .map((person) => PeopleCardModel.fromJson(person))
          .toSet();
      final peopleCount = response['pagination']['total'];
      final totalPages = response['pagination']['pages'];
      final currentPage = response['pagination']['page'];
      final currentPeopleDegreeFilter =
          queryParameters['connectionDegree'] ?? 'all';
      state = state.copyWith(
        isLoading: false,
        isError: false,
        isLoadingMore: false,
        people: people,
        peopleCount: peopleCount,
        totalPages: totalPages,
        currentPage: currentPage,
        currentPeopleDegreeFilter: currentPeopleDegreeFilter,
      );
    } catch (error) {
      log('Error getting people search list: $error');
      state = state.copyWith(isLoading: false, isError: true);
    }
  }

  Future<void> loadMorePeople({
    required Map<String, dynamic> queryParameters,
  }) async {
    final currentState = state;
    // Don't load more if already loading or at the end of pages
    if (currentState.isLoadingMore ||
        currentState.currentPage! >= currentState.totalPages!) {
      return;
    }

    // Set loading more state
    state = currentState.copyWith(isLoadingMore: true);
    try {
      final response = await _peopleTabServices.getPeopleSearch(
        queryParameters: queryParameters,
      );
      final Set<PeopleCardModel> newPeople = (response['people'] as List)
          .map((person) => PeopleCardModel.fromJson(person))
          .toSet();
      final peopleCount = response['pagination']['total'];
      final totalPages = response['pagination']['pages'];
      final currentPage = response['pagination']['page'];

      if (newPeople.isEmpty) {
        state = currentState.copyWith(
          isLoadingMore: false,
          totalPages: totalPages,
          currentPage: currentPage,
          peopleCount: peopleCount,
        );
        return;
      }

      final existingIds =
          currentState.people?.map((p) => p.cardId).toSet() ?? {};
      final uniqueNewPeople = newPeople
          .where((person) => !existingIds.contains(person.cardId))
          .toSet();

      final Set<PeopleCardModel> allPeople = {
        ...currentState.people ?? {},
        ...uniqueNewPeople
      };

      state = currentState.copyWith(
        isLoadingMore: false,
        isError: false,
        people: allPeople,
        currentPage: currentPage,
        totalPages: totalPages,
        peopleCount: peopleCount,
      );
    } catch (e) {
      // Handle errors
      log('Error loading more people: $e');
      state = currentState.copyWith(
        isLoadingMore: false,
        isError: true,
      );
    }
  }
}

final peopleTabViewModelProvider =
    StateNotifierProvider<PeopleTabViewModel, PeopleTabState>(
  (ref) {
    return PeopleTabViewModel(
      ref.read(peopleTabServicesProvider),
    );
  },
);
