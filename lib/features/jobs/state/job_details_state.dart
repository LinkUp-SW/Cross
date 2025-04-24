import 'package:link_up/features/jobs/model/job_detail_model.dart';

class JobDetailsState {
  final JobDetailsModel? jobDetails;
  final String? errorMessage;
  final bool isLoading;
  final bool isError;

  const JobDetailsState({
    this.jobDetails,
    this.errorMessage,
    this.isLoading = true,
    this.isError = false,
  });

  factory JobDetailsState.initial() {
    return const JobDetailsState(
      jobDetails: null,
      errorMessage: null,
      isLoading: true,
      isError: false,
    );
  }

  JobDetailsState copyWith({
    JobDetailsModel? jobDetails,
    String? errorMessage,
    bool? isLoading,
    bool? isError,
  }) {
    return JobDetailsState(
      jobDetails: jobDetails ?? this.jobDetails,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
    );
  }
}