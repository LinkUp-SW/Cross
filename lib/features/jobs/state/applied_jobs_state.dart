import 'package:link_up/features/jobs/model/applied_job_model.dart';

class AppliedJobsState {
  final List<AppliedJobModel>? appliedJobs;
  final int? count;
  final String? errorMessage;
  final bool isLoading;
  final bool isError;

  AppliedJobsState({
    this.appliedJobs,
    this.count,
    this.errorMessage,
    this.isLoading = true,
    this.isError = false,
  });

  factory AppliedJobsState.initial() {
    return AppliedJobsState(
      appliedJobs: null,
      count: 0,
      errorMessage: null,
      isLoading: true,
      isError: false,
    );
  }

  AppliedJobsState copyWith({
    List<AppliedJobModel>? appliedJobs,
    int? count,
    String? errorMessage,
    bool? isLoading,
    bool? isError,
  }) {
    return AppliedJobsState(
      appliedJobs: appliedJobs ?? this.appliedJobs,
      count: count ?? this.count,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
    );
  }
}