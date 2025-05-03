import 'package:link_up/features/jobs/model/jobs_screen_model.dart';

class JobFilterState {
  final List<JobsCardModel> filteredJobs;
  final List<JobsCardModel> originalJobs;
  final String? location;
  final List<String>? experienceLevel;
  final int? minSalary;
  final int? maxSalary;
  final bool isLoading;
  final String? errorMessage;

  const JobFilterState({
    required this.filteredJobs,
    required this.originalJobs,
    this.location,
    this.experienceLevel,
    this.minSalary,
    this.maxSalary,
    this.isLoading = false,
    this.errorMessage,
  });

  factory JobFilterState.initial(List<JobsCardModel> jobs) {
    return JobFilterState(
      filteredJobs: List.from(jobs),
      originalJobs: jobs,
    );
  }

  JobFilterState copyWith({
    List<JobsCardModel>? filteredJobs,
    List<JobsCardModel>? originalJobs,
    String? location,
    List<String>? experienceLevel,
    int? minSalary,
    int? maxSalary,
    bool? isLoading,
    String? errorMessage,
  }) {
    return JobFilterState(
      filteredJobs: filteredJobs ?? this.filteredJobs,
      originalJobs: originalJobs ?? this.originalJobs,
      location: location ?? this.location,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      minSalary: minSalary ?? this.minSalary,
      maxSalary: maxSalary ?? this.maxSalary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Function to check if any filters are applied
  bool get hasFilters => 
      location != null ||
      (experienceLevel != null && experienceLevel!.isNotEmpty) ||
      minSalary != null ||
      maxSalary != null;

  // Clear a specific filter type
  JobFilterState clearFilter(String filterType) {
    switch (filterType) {
      case 'location':
        return copyWith(location: null);
      case 'experienceLevel':
        return copyWith(experienceLevel: null);
      case 'salary':
        return copyWith(minSalary: null, maxSalary: null);
      default:
        return this;
    }
  }
}