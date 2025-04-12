import 'package:link_up/features/jobs/model/jobs_screen_model.dart';

class JobsScreenState {
  final List<JobsCardModel> topJobPicksForYou;
  final List<JobsCardModel>? hiringInYourNetwork;
  final List<JobsCardModel> moreJobsForYou;

  const JobsScreenState({
    required this.topJobPicksForYou,
    this.hiringInYourNetwork,
    required this.moreJobsForYou,
  });

  factory JobsScreenState.initial() {
    return const JobsScreenState(
      topJobPicksForYou: [],
      moreJobsForYou: [],
    );
  }

  JobsScreenState copyWith({
    final List<JobsCardModel>? topJobPicksForYou,
    final List<JobsCardModel>? hiringInYourNetwork,
    final List<JobsCardModel>? moreJobsForYou,
  }) {
    return JobsScreenState(
      topJobPicksForYou: topJobPicksForYou ?? this.topJobPicksForYou,
      hiringInYourNetwork: hiringInYourNetwork ?? this.hiringInYourNetwork,
      moreJobsForYou: moreJobsForYou ?? this.moreJobsForYou,
    );
  }
}