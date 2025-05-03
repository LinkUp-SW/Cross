import 'package:link_up/features/jobs/model/job_detail_model.dart';

class JobDetailsState {
  final JobDetailsModel? jobDetails;
  final String? errorMessage;
  final bool isLoading;
  final bool isError;
  bool? isSaved;
 

  JobDetailsState({
    this.jobDetails,
    this.errorMessage,
    this.isLoading = true,
    this.isError = false,
    this.isSaved,
  });

  factory JobDetailsState.initial() {
    return  JobDetailsState(
      jobDetails: null,
      errorMessage: null,
      isLoading: true,
      isError: false,
      isSaved: false,
    );
  }

  JobDetailsState copyWith({
    JobDetailsModel? jobDetails,
    String? errorMessage,
    bool? isLoading,
    bool? isError,
    bool? isSaved,
  }) {
    return JobDetailsState(
      jobDetails: jobDetails ?? this.jobDetails,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}