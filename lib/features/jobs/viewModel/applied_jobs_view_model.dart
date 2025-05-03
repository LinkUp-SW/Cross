import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/jobs/model/applied_job_model.dart';
import 'package:link_up/features/jobs/services/job_application_service.dart';
import 'package:link_up/features/jobs/state/applied_jobs_state.dart';
import 'dart:developer' as developer;

class AppliedJobsViewModel extends StateNotifier<AppliedJobsState> {
  final JobApplicationService _jobApplicationService;

  AppliedJobsViewModel(
    this._jobApplicationService,
  ) : super(AppliedJobsState.initial());

  Future<void> getAppliedJobs() async {
    developer.log('Getting user\'s applied jobs');
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);

    try {
      final List<AppliedJobModel> appliedJobs = await _jobApplicationService.getAppliedJobs();

      developer.log('Successfully fetched applied jobs: ${appliedJobs.length}');
      state = state.copyWith(
        isLoading: false,
        appliedJobs: appliedJobs,
        count: appliedJobs.length,
        isError: false,
        errorMessage: null,
      );
    } catch (e, stackTrace) {
      developer.log('Error getting applied jobs: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
        appliedJobs: [],
        count: 0,
      );
    }
  }

  Future<void> updateApplicationStatus(String applicationId, String status) async {
    try {
      developer.log('Updating application status: $applicationId to $status');
      
      await _jobApplicationService.updateApplicationStatus(
        applicationId: applicationId,
        status: status,
      );
      
      // Refresh the list after updating
      await getAppliedJobs();
      
    } catch (e, stackTrace) {
      developer.log('Error updating application status: $e\n$stackTrace');
      state = state.copyWith(
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }
}

final appliedJobsViewModelProvider =
    StateNotifierProvider<AppliedJobsViewModel, AppliedJobsState>((ref) {
  return AppliedJobsViewModel(
    ref.read(jobApplicationServiceProvider),
  );
});