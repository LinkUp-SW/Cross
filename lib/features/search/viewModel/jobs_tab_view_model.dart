// search_job_view_model.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/jobs/model/search_job_model.dart';
import 'package:link_up/features/search/state/job_tab_state.dart';
import 'package:link_up/features/search/service/job_tab_service.dart';


import 'dart:developer' as developer;

class SearchJobViewModel extends StateNotifier<SearchJobState> {
  final SearchJobService _searchJobService;

  SearchJobViewModel(this._searchJobService) : super(SearchJobState.initial());

  // Main method for both searching and filtering
  Future<void> searchJobs({
    required Map<String, dynamic> queryParameters,
  }) async {
    state = state.copyWith(isLoading: true, isError: false);
    
    // Save search term to history if provided
    if (queryParameters.containsKey('query')) {
      final query = queryParameters['query'];
      if (query != null && query.toString().trim().isNotEmpty) {
        addToRecentSearches(query.toString());
      }
    }
    
    try {
      final response = await _searchJobService.searchJobsData(
        queryParameters: queryParameters,
      );
      
      final List<dynamic> jobsList = response['jobs'] ?? [];
      final int totalCount = response['total'] ?? 0;
      
      final List<SearchJobModel> jobs = jobsList
          .map((job) => SearchJobModel.fromJson(job))
          .toList();
      
      // Update state with results and any filters
      state = state.copyWith(
        isLoading: false,
        searchJobs: jobs,
        totalJobs: totalCount,
        currentPage: int.parse(queryParameters['page'] ?? '1'),
        totalPages: (totalCount / (int.parse(queryParameters['limit'] ?? '10'))).ceil(),
        selectedExperienceLevels: queryParameters.containsKey('experienceLevel')
            ? queryParameters['experienceLevel'].toString().split(',')
            : null,
        selectedLocation: queryParameters['location'],
        minSalary: queryParameters.containsKey('minSalary')
            ? int.tryParse(queryParameters['minSalary'].toString())
            : null,
        maxSalary: queryParameters.containsKey('maxSalary')
            ? int.tryParse(queryParameters['maxSalary'].toString())
            : null,
      );
    } catch (e) {
      developer.log('Error in search/filter: $e');
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }

  // Load more results for pagination
  Future<void> loadMoreJobs({
    required Map<String, dynamic> queryParameters,
  }) async {
    if (state.isLoadingMore || 
        (state.currentPage ?? 0) >= (state.totalPages ?? 0)) {
      return;
    }
    
    state = state.copyWith(isLoadingMore: true);
    
    try {
      final response = await _searchJobService.searchJobsData(
        queryParameters: queryParameters,
      );
      
      final List<dynamic> jobsList = response['jobs'] ?? [];
      
      final List<SearchJobModel> newJobs = jobsList
          .map((job) => SearchJobModel.fromJson(job))
          .toList();
      
      if (newJobs.isEmpty) {
        state = state.copyWith(isLoadingMore: false);
        return;
      }
      
      // Combine with existing jobs
      final List<SearchJobModel> allJobs = [
        ...(state.searchJobs ?? []),
        ...newJobs,
      ];
      
      state = state.copyWith(
        isLoadingMore: false,
        searchJobs: allJobs,
        currentPage: (state.currentPage ?? 1) + 1,
      );
    } catch (e) {
      developer.log('Error loading more jobs: $e');
      state = state.copyWith(
        isLoadingMore: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }

  // Recent searches management
  void addToRecentSearches(String searchTerm) {
    final String trimmedTerm = searchTerm.trim();
    if (trimmedTerm.isEmpty) return;
    
    final currentSearches = List<String>.from(state.recentSearches);
    
    // Remove if it already exists to avoid duplicates
    currentSearches.removeWhere(
      (term) => term.toLowerCase() == trimmedTerm.toLowerCase()
    );
    
    // Add to beginning
    currentSearches.insert(0, trimmedTerm);
    
    // Limit to 10 items
    final limitedSearches = currentSearches.length > 10
        ? currentSearches.sublist(0, 10)
        : currentSearches;
    
    state = state.copyWith(recentSearches: limitedSearches);
  }

  void clearRecentSearches() {
    state = state.copyWith(recentSearches: []);
  }

  void deleteFromRecentSearches(String searchTerm) {
    final currentSearches = List<String>.from(state.recentSearches);
    currentSearches.remove(searchTerm);
    state = state.copyWith(recentSearches: currentSearches);
  }

  // Apply filters to current search
  void applyFilters({
    List<String>? experienceLevels,
    String? location,
    int? minSalary,
    int? maxSalary,
    required String searchQuery,
  }) {
    final Map<String, dynamic> queryParams = {
      'query': searchQuery,
      'page': '1',
      'limit': '10',
    };
    
    // Add filters if provided
    if (experienceLevels != null && experienceLevels.isNotEmpty) {
      queryParams['experienceLevel'] = experienceLevels.join(',');
    }
    
    if (location != null && location.isNotEmpty) {
      queryParams['location'] = location;
    }
    
    if (minSalary != null) {
      queryParams['minSalary'] = minSalary.toString();
    }
    
    if (maxSalary != null) {
      queryParams['maxSalary'] = maxSalary.toString();
    }
    
    // Perform search with filters
    searchJobs(queryParameters: queryParams);
  }

  // Reset all filters
  void clearFilters(String searchQuery) {
    searchJobs(queryParameters: {
      'query': searchQuery,
      'page': '1',
      'limit': '10',
    });
  }

  // Clear current search
  void clearSearch() {
    final currentSearches = state.recentSearches;
    state = SearchJobState.initial().copyWith(
      recentSearches: currentSearches,
    );
  }
}

final searchJobViewModelProvider = StateNotifierProvider<SearchJobViewModel, SearchJobState>(
  (ref) => SearchJobViewModel(ref.read(searchJobServiceProvider)),
);