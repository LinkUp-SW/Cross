import 'package:link_up/features/search/model/people_search_card_model.dart';

class PeopleTabState {
  final Set<PeopleCardModel>? people;
  final int? peopleCount;
  final int? totalPages;
  final int? currentPage;
  final int? limit;
  final String currentPeopleDegreeFilter;
  final bool isLoadingMore;
  final bool isLoading;
  final bool isError;

  const PeopleTabState({
    required this.people,
    required this.peopleCount,
    this.totalPages = 1,
    this.currentPage = 1,
    this.limit = 10,
    this.currentPeopleDegreeFilter = 'all',
    this.isLoadingMore = false,
    this.isLoading = true,
    this.isError = false,
  });

  factory PeopleTabState.initial() {
    return PeopleTabState(
      people: null,
      peopleCount: null,
      totalPages: 1,
      currentPage: 1,
      limit: 10,
      currentPeopleDegreeFilter: 'all',
      isLoadingMore: false,
      isLoading: true,
      isError: false,
    );
  }

  PeopleTabState copyWith({
    final Set<PeopleCardModel>? people,
    final int? peopleCount,
    final String? searchKeyWord,
    final int? totalPages,
    final int? currentPage,
    final int? limit,
    final String? currentPeopleDegreeFilter,
    final bool? isLoadingMore,
    final bool? isLoading,
    final bool? isError,
  }) {
    return PeopleTabState(
      people: people ?? this.people,
      peopleCount: peopleCount ?? this.peopleCount,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      currentPeopleDegreeFilter:
          currentPeopleDegreeFilter ?? this.currentPeopleDegreeFilter,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
    );
  }
}
