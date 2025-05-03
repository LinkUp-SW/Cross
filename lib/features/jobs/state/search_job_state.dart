// search_job_state.dart

import 'package:link_up/features/jobs/model/search_job_model.dart';

class SearchJobState {
  final bool isLoading;
  final bool isError;
  final bool isLoadingMore;
  final String? errorMessage;
  final List<SearchJobModel>? searchJobs;
  final int? totalJobs;
  final int? currentPage;
  final int? totalPages;
  final int? limit;
  final List<String> recentSearches;
  

  final List<String>? selectedExperienceLevels;
  final String? selectedLocation;
  final int? minSalary;
  final int? maxSalary;

  const SearchJobState({
    required this.isLoading,
    required this.isError,
    required this.isLoadingMore,
    this.errorMessage,
    this.searchJobs,
    this.totalJobs,
    this.currentPage,
    this.totalPages,
    this.limit,
    required this.recentSearches,
    this.selectedExperienceLevels,
    this.selectedLocation,
    this.minSalary,
    this.maxSalary,
  });

  factory SearchJobState.initial() {
    return const SearchJobState(
      isLoading: false,
      isError: false,
      isLoadingMore: false,
      errorMessage: null,
      searchJobs: null,
      totalJobs: 0,
      currentPage: 1,
      totalPages: 0,
      limit: 10,
      recentSearches: [],
      selectedExperienceLevels: null,
      selectedLocation: null,
      minSalary: null,
      maxSalary: null,
    );
  }

  get recentLocationSearches => null;

  SearchJobState copyWith({
    bool? isLoading,
    bool? isError,
    bool? isLoadingMore,
    String? errorMessage,
    List<SearchJobModel>? searchJobs,
    int? totalJobs,
    int? currentPage,
    int? totalPages,
    int? limit,
    List<String>? recentSearches,
    List<String>? selectedExperienceLevels,
    String? selectedLocation,
    int? minSalary,
    int? maxSalary,
  }) {
    return SearchJobState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      searchJobs: searchJobs ?? this.searchJobs,
      totalJobs: totalJobs ?? this.totalJobs,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      limit: limit ?? this.limit,
      recentSearches: recentSearches ?? this.recentSearches,
      selectedExperienceLevels: selectedExperienceLevels ?? this.selectedExperienceLevels,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      minSalary: minSalary ?? this.minSalary,
      maxSalary: maxSalary ?? this.maxSalary,
    );
  }
}