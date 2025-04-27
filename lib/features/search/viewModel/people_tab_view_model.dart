import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/search/model/people_search_card_model.dart';
import 'package:link_up/features/search/services/people_tab_services.dart';
import 'package:link_up/features/search/state/people_tab_state.dart';

class PeopleTabViewModel extends StateNotifier<PeopleTabState> {
  final PeopleTabServices _peopleTabServices;

  PeopleTabViewModel(this._peopleTabServices) : super(PeopleTabState.initial());

  Future<void> getPeopleSearch({
    Map<String, dynamic>? queryParameters,
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
      final cuurentPage = response['pagination']['page'];
      final limit = response['pagination']['limit'];

      state = state.copyWith(
        isLoading: false,
        isError: false,
        people: people,
        peopleCount: peopleCount,
        totalPages: totalPages,
        currentPage: cuurentPage,
        limit: limit,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, isError: true);
    }
  }
}
