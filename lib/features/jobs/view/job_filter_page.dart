import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/jobs/model/jobs_screen_model.dart';
import 'package:link_up/features/jobs/state/job_filter_state.dart';
import 'package:link_up/features/jobs/viewModel/job_filter_view_model.dart';
import 'package:link_up/features/jobs/widgets/job_card_refactor.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class JobFilterResultsWidget extends ConsumerWidget {
  final List<JobsCardModel> allJobs;
  final VoidCallback onEditFilters;
  
  const JobFilterResultsWidget({
    Key? key,
    required this.allJobs,
    required this.onEditFilters,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(jobFilterViewModelProvider(allJobs));
    
    return Column(
      children: [
        // Results header with count and edit button
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Text(
                'Found ${state.filteredJobs.length} jobs',
                style: TextStyles.font16_500Weight.copyWith(
                  color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onEditFilters,
                icon: const Icon(Icons.tune),
                label: const Text('Adjust Filters'),
                style: TextButton.styleFrom(
                  foregroundColor: isDarkMode ? Colors.blue[300] : Colors.blue,
                ),
              ),
            ],
          ),
        ),
        
        // Applied filter chips
        if (state.hasFilters)
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 8.h),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (state.location != null)
                    _buildFilterChip(
                      label: 'Location: ${state.location}',
                      onDeleted: () {
                        ref.read(jobFilterViewModelProvider(allJobs).notifier)
                            .clearFilter('location');
                      },
                      isDarkMode: isDarkMode,
                    ),
                    
                  if (state.experienceLevel != null && state.experienceLevel!.isNotEmpty)
                    ...state.experienceLevel!.map((level) => _buildFilterChip(
                      label: level,
                      onDeleted: () {
                        final List<String> newLevels = List.from(state.experienceLevel!)
                          ..remove(level);
                          
                        ref.read(jobFilterViewModelProvider(allJobs).notifier).applyFilters(
                          location: state.location,
                          experienceLevel: newLevels.isEmpty ? null : newLevels,
                          minSalary: state.minSalary,
                          maxSalary: state.maxSalary,
                        );
                      },
                      isDarkMode: isDarkMode,
                    )),
                    
                  if (state.minSalary != null || state.maxSalary != null)
                    _buildFilterChip(
                      label: 'Salary: \$${state.minSalary ?? 0} - \$${state.maxSalary ?? '∞'}',
                      onDeleted: () {
                        ref.read(jobFilterViewModelProvider(allJobs).notifier)
                            .clearFilter('salary');
                      },
                      isDarkMode: isDarkMode,
                    ),
                ],
              ),
            ),
          ),
          
        Divider(height: 1.h),
        
        // Results list
        Expanded(
          child: _buildResultsList(context, state, isDarkMode),
        ),
      ],
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 12.sp,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        deleteIcon: Icon(
          Icons.close,
          size: 16.sp,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
        ),
        onDeleted: onDeleted,
      ),
    );
  }
  
  Widget _buildResultsList(BuildContext context, JobFilterState state, bool isDarkMode) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (state.filteredJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48.w,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'No jobs match your filter criteria',
              style: TextStyles.font16_500Weight.copyWith(
                color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Try adjusting your filters to see more results',
              style: TextStyles.font14_400Weight.copyWith(
                color: isDarkMode ? AppColors.darkTextColor : AppColors.lightSecondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: state.filteredJobs.length,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final job = state.filteredJobs[index];
        return JobsCard(
          isDarkMode: isDarkMode,
          data: job,
        );
      },
    );
  }
}