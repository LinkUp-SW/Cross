// search_job_view_model.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/jobs/model/search_job_model.dart';
import 'package:link_up/features/jobs/services/search_job_service.dart';
import 'package:link_up/features/jobs/state/search_job_state.dart';
import 'dart:developer' as developer;

class SearchJobViewModel extends StateNotifier<SearchJobState> {
  final SearchJobService _searchJobService;

  SearchJobViewModel(this._searchJobService) : super(SearchJobState.initial());

  // Search jobs
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
      developer.log('Using search service with parameters: $queryParameters');
      
      // Use search service
      final response = await _searchJobService.searchJobsData(
        queryParameters: {
          'query': queryParameters['query'] ?? '',
          if (queryParameters.containsKey('cursor'))
            'cursor': queryParameters['cursor'].toString(),
          'limit': queryParameters['limit']?.toString() ?? '10',
        },
      );
      
      final List<dynamic> jobsList = response['jobs'] ?? [];
      final int totalCount = response['total'] ?? 0;
      
      final List<SearchJobModel> jobs = jobsList
          .map((job) => SearchJobModel.fromJson(job))
          .toList();
      
      // Update state with results
      state = state.copyWith(
        isLoading: false,
        searchJobs: jobs,
        totalJobs: totalCount,
        currentPage: int.parse(queryParameters['page'] ?? '1'),
        totalPages: (totalCount / (int.parse(queryParameters['limit'] ?? '10'))).ceil(),
      );
    } catch (e) {
      developer.log('Error in search: $e');
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
    if (state.isLoadingMore || (state.currentPage ?? 0) >= (state.totalPages ?? 0)) {
      return;
    }
    
    state = state.copyWith(isLoadingMore: true);
    
    try {
      // Include current page in parameters
      final Map<String, dynamic> params = {
        ...queryParameters,
        'page': '${(state.currentPage ?? 0) + 1}',
      };
      
      await searchJobs(queryParameters: params);
      
      state = state.copyWith(isLoadingMore: false);
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

  // Clear current search
  void clearSearch() {
    final currentSearches = state.recentSearches;
    state = SearchJobState.initial().copyWith(
      recentSearches: currentSearches,
    );
  }
}

final searchJobViewModelProvider = StateNotifierProvider<SearchJobViewModel, SearchJobState>(
  (ref) => SearchJobViewModel(
    ref.read(searchJobServiceProvider),
  ),
);