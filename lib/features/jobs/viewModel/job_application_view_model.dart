import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/jobs/model/job_application_user_model.dart';
import 'package:link_up/features/jobs/model/job_application_submit_model.dart';
import 'package:link_up/features/jobs/services/job_application_service.dart';
import 'package:link_up/features/jobs/state/job_application_state.dart';
import 'dart:developer' as developer;

class JobApplicationViewModel extends StateNotifier<JobApplicationState> {
  final JobApplicationService _jobApplicationService;

  JobApplicationViewModel(
    this._jobApplicationService,
  ) : super(JobApplicationState.initial());

  Future<void> getApplicationUserData() async {
    developer.log('Getting user data for job application');
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);

    try {
      final response = await _jobApplicationService.getApplicationUserData();

      developer.log('Parsing job application user data');
      final userData = JobApplicationUserModel.fromJson(response);

      developer.log('Successfully parsed user data');
      state = state.copyWith(
        isLoading: false,
        userData: userData,
        isError: false,
        errorMessage: null,
      );
    } catch (e, stackTrace) {
      developer.log('Error getting job application user data: $e\n$stackTrace');
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
        userData: null,
      );
    }
  }

  Future<void> submitJobApplication({
    required String jobId,
    required JobApplicationSubmitModel applicationData,
  }) async {
    developer.log('Submitting job application for job ID: $jobId');
    state = state.copyWith(isSubmitting: true, isError: false, errorMessage: null, isSuccess: false);

    try {
      await _jobApplicationService.submitJobApplication(
        jobId: jobId,
        applicationData: applicationData,
      );

      developer.log('Job application submitted successfully');
      state = state.copyWith(
        isSubmitting: false,
        isSuccess: true,
      );
    } catch (e, stackTrace) {
      developer.log('Error submitting job application: $e\n$stackTrace');
      state = state.copyWith(
        isSubmitting: false,
        isError: true,
        errorMessage: e.toString(),
        isSuccess: false,
      );
    }
  }

  void resetState() {
    state = JobApplicationState.initial();
  }
}

final jobApplicationViewModelProvider =
    StateNotifierProvider<JobApplicationViewModel, JobApplicationState>((ref) {
  return JobApplicationViewModel(
    ref.read(jobApplicationServiceProvider),
  );
});