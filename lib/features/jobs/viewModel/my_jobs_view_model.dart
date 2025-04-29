import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/jobs/model/job_detail_model.dart';
import 'package:link_up/features/jobs/services/job_details_service.dart';
import 'package:link_up/features/jobs/state/my_jobs_state.dart';
import 'dart:developer' as developer;

class MyJobsViewModel extends StateNotifier<MyJobsState> {
  final JobDetailsService _jobDetailsService;

  MyJobsViewModel(this._jobDetailsService) : super(MyJobsState.initial());

  Future<void> getSavedJobs() async {
    developer.log('Fetching saved jobs');
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);

    try {
      final savedJobIds = await _jobDetailsService.getSavedJobs();
      final List<JobDetailsModel> savedJobs = [];

      for (String jobId in savedJobIds) {
        try {
          final jobData = await _jobDetailsService.jobDetailsData(jobId: jobId);
          final job = JobDetailsModel.fromJson(jobData);
          savedJobs.add(job);
        } catch (e) {
          developer.log('Error fetching job details for ID $jobId: $e');
          // Continue with other jobs even if one fails
        }
      }

      state = state.copyWith(
        isLoading: false,
        savedJobs: savedJobs,
        isError: false,
        errorMessage: null,
      );
    } catch (e, stackTrace) {
      developer.log('Error getting saved jobs: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
        savedJobs: [],
      );
    }
  }

  Future<void> unsaveJob(String jobId) async {
    try {
      await _jobDetailsService.saveJob(jobId: jobId, isSaved: true);
      await getSavedJobs(); // Refresh the list after unsaving
    } catch (e, stackTrace) {
      developer.log('Error unsaving job: $e\n$stackTrace');
      state = state.copyWith(
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }
}

final myJobsViewModelProvider =
    StateNotifierProvider<MyJobsViewModel, MyJobsState>((ref) {
  return MyJobsViewModel(ref.read(jobDetailsServiceProvider));
}); 