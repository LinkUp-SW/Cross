import 'package:link_up/features/jobs/model/jobs_screen_model.dart';

class JobsScreenState {
  final List<JobsCardModel> topJobPicksForYou;

  final List<JobsCardModel> moreJobsForYou;
  final String? topJobsNextCursor;
  final String? moreJobsNextCursor;
  final String? errorMessage;
  final bool isLoading;
  final bool isError;
  const JobsScreenState({
    required this.topJobPicksForYou,

    required this.moreJobsForYou,
    this.topJobsNextCursor,
    this.moreJobsNextCursor,
    this.errorMessage,
    this.isLoading = true,
    this.isError = false,
  });

  factory JobsScreenState.initial() {
    return const JobsScreenState(
      topJobPicksForYou: [],
      moreJobsForYou: [],
      topJobsNextCursor: null,
      moreJobsNextCursor: null,
      errorMessage: null,
      isLoading: true,
      isError: false,
    );
  }

  JobsScreenState copyWith({
    final List<JobsCardModel>? topJobPicksForYou,
    final String? topJobsNextCursor,
    final String? moreJobsNextCursor,
    final String? errorMessage,
    final bool? isLoading,
    final bool? isError,
    final List<JobsCardModel>? moreJobsForYou,
  }) {
    return JobsScreenState(
      topJobPicksForYou: topJobPicksForYou ?? this.topJobPicksForYou,
      topJobsNextCursor: topJobsNextCursor ?? this.topJobsNextCursor, 
      moreJobsNextCursor: moreJobsNextCursor ?? this.moreJobsNextCursor,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      moreJobsForYou: moreJobsForYou ?? this.moreJobsForYou,
    );
  }
}