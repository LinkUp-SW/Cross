import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/jobs/model/search_job_model.dart';
import 'package:link_up/features/jobs/services/search_job_service.dart';
import 'package:link_up/features/jobs/state/search_job_state.dart';
import 'dart:developer' as developer;

class SearchJobViewModel extends StateNotifier<SearchJobState> {
  final SearchJobService _searchJobService;

  SearchJobViewModel(this._searchJobService) : super(SearchJobState.initial());

  Future<void> searchJobs({
    required Map<String, dynamic> queryParameters,
  }) async {
    developer.log('Starting job search with parameters: $queryParameters');
    state = state.copyWith(isLoading: true, isError: false);
    
    // Add search term to recent searches if it exists
    if (queryParameters.containsKey('query') && queryParameters['query'] != null) {
      addToRecentSearches(queryParameters['query']);
    }
    
    try {
      final response = await _searchJobService.searchJobsData(
        queryParameters: queryParameters,
      );
      
      developer.log('Received job search response: ${response.keys}');
      
      // Safely handle jobs data
      List<dynamic> jobsList = [];
      if (response.containsKey('jobs') && response['jobs'] is List) {
        jobsList = response['jobs'] as List;
        developer.log('Found ${jobsList.length} jobs in response');
      } else if (response.containsKey('data') && response['data'] is List) {
        jobsList = response['data'] as List;
        developer.log('Found ${jobsList.length} jobs in data field');
        if (jobsList.isNotEmpty) {
          developer.log('Sample job data: ${jobsList.first}');
        }
      } else {
        developer.log('No jobs list found in response or invalid format');
        developer.log('Response keys: ${response.keys}');
      }
      
      final List<SearchJobModel> jobs = jobsList
          .map((job) => SearchJobModel.fromJson(job as Map<String, dynamic>))
          .toList();
      
      final totalJobs = response['total'] ?? response['count'] ?? 0;
      developer.log('Total jobs from API: $totalJobs, Processed jobs: ${jobs.length}');
      
      final currentPage = int.parse(queryParameters['page'] ?? '1');
      final limit = int.parse(queryParameters['limit'] ?? '10');
      final totalPages = (totalJobs / limit).ceil();
      
      state = state.copyWith(
        isLoading: false,
        isError: false,
        isLoadingMore: false,
        searchJobs: jobs,
        totalJobs: totalJobs,
        totalPages: totalPages,
        currentPage: currentPage,
        limit: limit,
      );
      
      developer.log('Search completed, updated state with ${jobs.length} jobs');
    } catch (error) {
      developer.log('Error getting job search list: $error');
      developer.log('Error stack trace: ${StackTrace.current}');
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: error.toString(),
        totalJobs: 0,
      );
    }
  }

  // Add a search term to recent searches
  void addToRecentSearches(String searchTerm) {
    if (searchTerm.isEmpty) return;
    
    // Normalize the search term - trim and lowercase
    final normalizedTerm = searchTerm.trim();
    if (normalizedTerm.isEmpty) return;
    
    // Get current searches
    final currentSearches = state.recentSearches;
    
    // Remove existing occurrence of this search term (if any)
    final updatedSearches = currentSearches
        .where((term) => term.toLowerCase() != normalizedTerm.toLowerCase())
        .toList();
    
    // Add the new search term to the beginning of the list
    updatedSearches.insert(0, normalizedTerm);
    
    // Keep only the most recent searches (max 10)
    final limitedSearches = updatedSearches.length > 10 
        ? updatedSearches.sublist(0, 10) 
        : updatedSearches;
    
    // Update state with new recent searches
    state = state.copyWith(recentSearches: limitedSearches);
  }

  // Clear all recent searches
  void clearRecentSearches() {
    state = state.copyWith(recentSearches: []);
  }

  // Delete a specific search from recent searches
  void deleteFromRecentSearches(String searchTerm) {
    final currentSearches = state.recentSearches;
    final updatedSearches = currentSearches
        .where((term) => term != searchTerm)
        .toList();
    
    state = state.copyWith(recentSearches: updatedSearches);
  }

  Future<void> loadMoreJobs({
    required Map<String, dynamic> queryParameters,
  }) async {
    final currentState = state;
    // Don't load more if already loading or at the end of pages
    if (currentState.isLoadingMore ||
        (currentState.currentPage ?? 1) >= (currentState.totalPages ?? 1)) {
      return;
    }

    // Set loading more state
    state = currentState.copyWith(isLoadingMore: true);
    try {
      final response = await _searchJobService.searchJobsData(
        queryParameters: queryParameters,
      );
      
      // Safely handle jobs data
      List<dynamic> jobsList = [];
      if (response.containsKey('jobs') && response['jobs'] is List) {
        jobsList = response['jobs'] as List;
      } else if (response.containsKey('data') && response['data'] is List) {
        jobsList = response['data'] as List;
      }
      
      final List<SearchJobModel> newJobs = jobsList
          .map((job) => SearchJobModel.fromJson(job as Map<String, dynamic>))
          .toList();
      
      final totalJobs = response['total'] ?? response['count'] ?? 0;
      final currentPage = int.parse(queryParameters['page'] ?? '1');
      final limit = int.parse(queryParameters['limit'] ?? '10');
      final totalPages = (totalJobs / limit).ceil();

      if (newJobs.isEmpty) {
        state = currentState.copyWith(
          isLoadingMore: false,
          totalPages: totalPages,
          currentPage: currentPage,
          totalJobs: totalJobs,
        );
        return;
      }

      final existingIds = 
          currentState.searchJobs?.map((job) => job.jobId).toSet() ?? {};
      final uniqueNewJobs = newJobs
          .where((job) => !existingIds.contains(job.jobId))
          .toList();

      final List<SearchJobModel> allJobs = [
        ...currentState.searchJobs ?? [],
        ...uniqueNewJobs
      ];

      state = currentState.copyWith(
        isLoadingMore: false,
        isError: false,
        searchJobs: allJobs,
        currentPage: currentPage,
        totalPages: totalPages,
        totalJobs: totalJobs,
      );
    } catch (e) {
      // Handle errors
      developer.log('Error loading more jobs: $e');
      state = currentState.copyWith(
        isLoadingMore: false,
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }

  void clearSearch() {
    // Keep the recent searches when clearing the current search results
    final currentSearches = state.recentSearches;
    state = SearchJobState.initial().copyWith(recentSearches: currentSearches);
  }
}

final searchJobViewModelProvider =
    StateNotifierProvider<SearchJobViewModel, SearchJobState>(
  (ref) {
    return SearchJobViewModel(
      ref.read(searchJobServiceProvider),
    );
  },
);
