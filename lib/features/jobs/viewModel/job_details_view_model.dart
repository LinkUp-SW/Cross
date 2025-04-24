import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/jobs/model/job_detail_model.dart';
import 'package:link_up/features/jobs/services/job_details_service.dart';
import 'package:link_up/features/jobs/state/job_details_state.dart';
import 'dart:developer' as developer;

class JobDetailsViewModel extends StateNotifier<JobDetailsState> {
  final JobDetailsService _jobDetailsService;

  JobDetailsViewModel(
    this._jobDetailsService,
  ) : super(
      JobDetailsState.initial(),
    );

  Future<void> getJobDetails(String jobId) async {
    developer.log('Getting job details for ID: $jobId');
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);

    try {
      final response = await _jobDetailsService.jobDetailsData(
        jobId: jobId,
      );

      developer.log('Parsing job details response');
      final jobDetails = JobDetailsModel.fromJson(response);
      
      developer.log('Successfully parsed job details');
      state = state.copyWith(
        isLoading: false,
        jobDetails: jobDetails,
        isError: false,
        errorMessage: null,
      );
    } catch (e, stackTrace) {
      developer.log('Error getting job details: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false, 
        isError: true,
        errorMessage: e.toString(),
        jobDetails: null,
      );
    }
  }
}

final jobDetailsViewModelProvider =
    StateNotifierProvider<JobDetailsViewModel, JobDetailsState>(
  (ref) {
    return JobDetailsViewModel(
      ref.read(jobDetailsServiceProvider),
    );
  },
);