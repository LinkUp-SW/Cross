import 'package:link_up/features/jobs/model/search_job_model.dart';

class SearchJobState {
  final bool isLoading;
  final bool isError;
  final bool isLoadingMore;
  final String? errorMessage;
  final List<SearchJobModel>? searchJobs;
  final int? totalJobs;
  final int? totalPages;
  final int? currentPage;
  final int? limit;
  final List<String> recentSearches;

  SearchJobState({
    required this.isLoading,
    required this.isError,
    required this.isLoadingMore,
    this.errorMessage,
    this.searchJobs,
    this.totalJobs,
    this.totalPages,
    this.currentPage,
    this.limit,
    required this.recentSearches,
  });

  factory SearchJobState.initial() {
    return SearchJobState(
      isLoading: false,
      isError: false,
      isLoadingMore: false,
      errorMessage: null,
      searchJobs: null,
      totalJobs: 0,
      totalPages: 0,
      currentPage: 1,
      limit: 10,
      recentSearches: [],
    );
  }

  SearchJobState copyWith({
    bool? isLoading,
    bool? isError,
    bool? isLoadingMore,
    String? errorMessage,
    List<SearchJobModel>? searchJobs,
    int? totalJobs,
    int? totalPages,
    int? currentPage,
    int? limit,
    List<String>? recentSearches,
  }) {
    return SearchJobState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      searchJobs: searchJobs ?? this.searchJobs,
      totalJobs: totalJobs ?? this.totalJobs,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }
}




