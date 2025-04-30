import 'package:link_up/features/jobs/model/search_job_model.dart';

class SearchJobState {
  final List<SearchJobModel>? searchJobs;
  final int? totalJobs;
  final int? totalPages;
  final int? currentPage;
  final int? limit;
  final String? errorMessage;
  final bool isLoadingMore;
  final bool isLoading;
  final bool isError;

  SearchJobState({
    this.searchJobs,
    this.totalJobs,
    this.totalPages = 1,
    this.currentPage = 1,
    this.limit = 10,
    this.errorMessage,
    this.isLoadingMore = false,
    this.isLoading = true,
    this.isError = false,
  });

  factory SearchJobState.initial() {
    return SearchJobState(
      searchJobs: null,
      totalJobs: null,
      totalPages: 1,
      currentPage: 1,
      limit: 10,
      errorMessage: null,
      isLoadingMore: false,
      isLoading: true,
      isError: false,
    );
  }

  SearchJobState copyWith({
    List<SearchJobModel>? searchJobs,
    int? totalJobs,
    int? totalPages,
    int? currentPage,
    int? limit,
    String? errorMessage,
    bool? isLoadingMore,
    bool? isLoading,
    bool? isError,
  }) {
    return SearchJobState(
      searchJobs: searchJobs ?? this.searchJobs,
      totalJobs: totalJobs ?? this.totalJobs,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
    );
  }
}




