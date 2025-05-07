import 'package:link_up/features/jobs/model/job_detail_model.dart';

class MyJobsState {
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final List<JobDetailsModel> savedJobs;

  MyJobsState({
    required this.isLoading,
    required this.isError,
    this.errorMessage,
    required this.savedJobs,
  });

  factory MyJobsState.initial() {
    return MyJobsState(
      isLoading: false,
      isError: false,
      errorMessage: null,
      savedJobs: [],
    );
  }

  MyJobsState copyWith({
    bool? isLoading,
    bool? isError,
    String? errorMessage,
    List<JobDetailsModel>? savedJobs,
  }) {
    return MyJobsState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      savedJobs: savedJobs ?? this.savedJobs,
    );
  }
} 