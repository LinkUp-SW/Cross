import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/jobs/model/jobs_screen_model.dart';
import 'package:link_up/features/jobs/state/jobs_screen_state.dart';
import 'package:link_up/features/jobs/services/job_screen_service.dart';
import 'dart:developer' as developer;

class JobsScreenViewModel extends StateNotifier<JobsScreenState> {
  final JobScreenService _jobScreenService;

  JobsScreenViewModel(
    this._jobScreenService,
  ) : super(
          JobsScreenState.initial(),
        );

 
  Future<void>getTopJobs(
    Map<String, dynamic>? queryParameters,
  ) async {
    developer.log('Fetching top jobs with params: $queryParameters');
    state = state.copyWith(isLoading: true, isError: false);

    try {
      // Convert query parameters to strings
      final stringQueryParams = queryParameters?.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      
      final response = await _jobScreenService.topJobsData(
        queryParameters: stringQueryParams,
      );
      
      developer.log('Got response: $response');

      // Parse the connections from the response
      final data = response['data'] as List;
      developer.log('Parsing ${data.length} jobs from response');
      
      final List<JobsCardModel> jobs = [];
      for (final job in data) {
        try {
          jobs.add(JobsCardModel.fromJson(job));
        } catch (e) {
          developer.log('Error parsing job: $e\nJob data: $job');
          // Continue parsing other jobs even if one fails
        }
      }
      
      final topJobsNextCursor = response['nextCursor'];
      developer.log('Successfully parsed ${jobs.length} jobs');
      
      state = state.copyWith(
          isLoading: false,
          topJobPicksForYou: jobs,  
          topJobsNextCursor: topJobsNextCursor,
          isError: false,
          errorMessage: null
      );
    } catch (e, stackTrace) {
      developer.log('Error fetching jobs: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false, 
        isError: true, 
        errorMessage: e.toString(),
        topJobPicksForYou: [] // Clear any partial data
      );
    }
  }

  Future<void> getAllJobs(
    Map<String, dynamic>? queryParameters,
  ) async {
    developer.log('Fetching all jobs with params: $queryParameters');
    state = state.copyWith(isLoading: true, isError: false);

    try {
      // Convert query parameters to strings
      final stringQueryParams = queryParameters?.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      
      final response = await _jobScreenService.getAllJobs(
        queryParameters: stringQueryParams,
      );
      
      developer.log('Got response: $response');

      // Parse the connections from the response
      final data = response['data'] as List;
      developer.log('Parsing ${data.length} jobs from response');
      
      final List<JobsCardModel> jobs = [];
      for (final job in data) {
        try {
          jobs.add(JobsCardModel.fromJson(job));
        } catch (e) {
          developer.log('Error parsing job: $e\nJob data: $job');
          // Continue parsing other jobs even if one fails
        }
      }
      
      final moreJobsNextCursor = response['nextCursor'];
      developer.log('Successfully parsed ${jobs.length} jobs');
      
      state = state.copyWith(
          isLoading: false,
          moreJobsForYou: jobs,  
          moreJobsNextCursor: moreJobsNextCursor,
          isError: false,
          errorMessage: null
      );
    } catch (e, stackTrace) {
      developer.log('Error fetching jobs: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false, 
        isError: true, 
        errorMessage: e.toString(),
        moreJobsForYou: [] // Clear any partial data
      );
    }
  }
  // In your JobsScreenViewModel.dart, add these methods:

Future<void> loadMoreTopJobs() async {
  developer.log('Loading more top jobs');
  
  if (state.topJobsNextCursor == null) {
    developer.log('No more top jobs to load');
    return;
  }
  
  try {
    final response = await _jobScreenService.topJobsData(
      queryParameters: {
        'limit': '3',
        'cursor': state.topJobsNextCursor
      },
    );
    
    final data = response['data'] as List;
    final List<JobsCardModel> newJobs = [];
    
    for (final job in data) {
      try {
        newJobs.add(JobsCardModel.fromJson(job));
      } catch (e) {
        developer.log('Error parsing job: $e\nJob data: $job');
      }
    }
    
    state = state.copyWith(
      topJobPicksForYou: [...state.topJobPicksForYou, ...newJobs],
      topJobsNextCursor: response['nextCursor'],
    );
    
    developer.log('Loaded ${newJobs.length} more top jobs');
  } catch (e) {
    developer.log('Error loading more top jobs: $e');
  }
}

Future<void> loadMoreAllJobs() async {
  developer.log('Loading more jobs');
  
  if (state.moreJobsNextCursor == null) {
    developer.log('No more jobs to load');
    return;
  }
  
  try {
    final response = await _jobScreenService.getAllJobs(
      queryParameters: {
        'limit': '10',
        'cursor': state.moreJobsNextCursor
      },
    );
    
    final data = response['data'] as List;
    final List<JobsCardModel> newJobs = [];
    
    for (final job in data) {
      try {
        newJobs.add(JobsCardModel.fromJson(job));
      } catch (e) {
        developer.log('Error parsing job: $e\nJob data: $job');
      }
    }
    
    state = state.copyWith(
      moreJobsForYou: [...state.moreJobsForYou, ...newJobs],
      moreJobsNextCursor: response['nextCursor'],
    );
    
    developer.log('Loaded ${newJobs.length} more jobs');
  } catch (e) {
    developer.log('Error loading more jobs: $e');
  }
}
}

final jobsScreenViewModelProvider =
    StateNotifierProvider<JobsScreenViewModel, JobsScreenState>(
  (ref) {
    return JobsScreenViewModel(
      ref.read(jobScreenServiceProvider),
    );
  },
);
