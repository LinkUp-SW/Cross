import 'package:link_up/features/jobs/model/job_application_user_model.dart';

class JobApplicationState {
  final JobApplicationUserModel? userData;
  final String? errorMessage;
  final bool isLoading;
  final bool isError;
  final bool isSubmitting;
  final bool isSuccess;

  JobApplicationState({
    this.userData,
    this.errorMessage,
    this.isLoading = true,
    this.isError = false,
    this.isSubmitting = false,
    this.isSuccess = false,
  });

  factory JobApplicationState.initial() {
    return JobApplicationState(
      userData: null,
      errorMessage: null,
      isLoading: true,
      isError: false,
      isSubmitting: false,
      isSuccess: false,
    );
  }

  JobApplicationState copyWith({
    JobApplicationUserModel? userData,
    String? errorMessage,
    bool? isLoading,
    bool? isError,
    bool? isSubmitting,
    bool? isSuccess,
  }) {
    return JobApplicationState(
      userData: userData ?? this.userData,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}