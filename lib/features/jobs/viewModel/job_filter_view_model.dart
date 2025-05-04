import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/features/jobs/model/jobs_screen_model.dart';
import 'package:link_up/features/jobs/state/job_filter_state.dart';
import 'dart:developer' as developer;

class JobFilterViewModel extends StateNotifier<JobFilterState> {
  JobFilterViewModel(List<JobsCardModel> jobs)
      : super(JobFilterState.initial(jobs));

  void applyFilters({
    String? location,
    List<String>? experienceLevel,
    int? minSalary,
    int? maxSalary,
  }) {
    developer.log('Applying filters: location=$location, experienceLevel=$experienceLevel, minSalary=$minSalary, maxSalary=$maxSalary');
    
    // Update the filter values in state
    state = state.copyWith(
      location: location,
      experienceLevel: experienceLevel,
      minSalary: minSalary,
      maxSalary: maxSalary,
      isLoading: true,
    );
    
    // Filter the original jobs list based on the criteria
    final List<JobsCardModel> filtered = state.originalJobs.where((job) {
      // Location filter
      if (location != null && location.isNotEmpty) {
        final bool locationMatch = job.location.toLowerCase().contains(location.toLowerCase());
        if (!locationMatch) return false;
      }
      
      // Experience level filter
      if (experienceLevel != null && experienceLevel.isNotEmpty && job.experienceLevel != null) {
        if (!experienceLevel.contains(job.experienceLevel)) return false;
      }
      
      // Salary filter
      if (minSalary != null && job.salary < minSalary) return false;
      if (maxSalary != null && job.salary > maxSalary) return false;
      
      return true;
    }).toList();
    
    // Update state with filtered jobs
    state = state.copyWith(
      filteredJobs: filtered,
      isLoading: false,
    );
    
    developer.log('Filter applied. Found ${filtered.length} matching jobs');
  }
  
  void clearFilter(String filterType) {
    developer.log('Clearing filter: $filterType');
    
    // Clear the specific filter
    final newState = state.clearFilter(filterType);
    
    // Re-apply remaining filters
    applyFilters(
      location: newState.location,
      experienceLevel: newState.experienceLevel,
      minSalary: newState.minSalary,
      maxSalary: newState.maxSalary,
    );
  }
  
  void resetAllFilters() {
    developer.log('Resetting all filters');
    state = JobFilterState.initial(state.originalJobs);
  }
}

final jobFilterViewModelProvider = StateNotifierProvider.family<JobFilterViewModel, JobFilterState, List<JobsCardModel>>(
  (ref, jobs) => JobFilterViewModel(jobs),
);