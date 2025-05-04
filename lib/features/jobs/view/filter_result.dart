import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/jobs/model/jobs_screen_model.dart';
import 'package:link_up/features/jobs/view/job_details.dart';
import 'package:link_up/features/jobs/viewModel/job_filter_view_model.dart';
import 'package:link_up/features/jobs/widgets/job_card_refactor.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/widgets/custom_app_bar.dart';

class FilteredJobsResultsPage extends ConsumerWidget {
  final List<JobsCardModel> filteredJobs;
  final Map<String, dynamic> appliedFilters;

  const FilteredJobsResultsPage({
    Key? key,
    required this.filteredJobs,
    required this.appliedFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        // This matches your CustomAppBar parameters
        searchBar: Text(
          'Filter Results',
          style: TextStyles.font18_700Weight.copyWith(
            color: Colors.white, // Use white for app bar title
          ),
        ),
        leadingAction: () => context.pop(),
      ),
      body: Column(
        children: [
          // Applied filters summary
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            color: isDarkMode ? AppColors.darkGrey.withOpacity(0.2) : AppColors.lightGrey.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Applied Filters',
                      style: TextStyles.font18_700Weight.copyWith(
                        color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                      ),
                    ),
                    Text(
                      '${filteredJobs.length} ${filteredJobs.length == 1 ? 'result' : 'results'}',
                      style: TextStyles.font14_400Weight.copyWith(
                        color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    // Display location filter if applied
                    if (appliedFilters['location'] != null)
                      _buildFilterChip(
                        'Location: ${appliedFilters['location']}',
                        isDarkMode,
                      ),
                    
                    // Display experience level filters if applied
                    if (appliedFilters['experienceLevel'] != null)
                      ...(appliedFilters['experienceLevel'] as List<String>).map(
                        (level) => _buildFilterChip('Experience: $level', isDarkMode)
                      ),
                    
                    // Display salary range if applied
                    if (appliedFilters['minSalary'] != null || appliedFilters['maxSalary'] != null)
                      _buildFilterChip(
                        'Salary: \$${appliedFilters['minSalary'] ?? 0} - \$${appliedFilters['maxSalary'] ?? '100k+'}',
                        isDarkMode,
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          // Results list
          Expanded(
            child: filteredJobs.isEmpty
                ? _buildEmptyState(isDarkMode, context)
                : ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, index) {
                      final job = filteredJobs[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: GestureDetector(
                          onTap: () => context.go('details/${job.jobId}'),
                          child: JobsCard(
                            isDarkMode: isDarkMode,
                            data: job,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.blue.withOpacity(0.2) : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDarkMode ? Colors.blue.withOpacity(0.4) : Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyles.font12_500Weight.copyWith(
          color: isDarkMode ? Colors.blue[200] : Colors.blue[700],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode, BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64.sp,
              color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
            ),
            SizedBox(height: 16.h),
            Text(
              'No matching jobs found',
              style: TextStyles.font18_700Weight.copyWith(
                color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Try adjusting your filters to see more results',
              textAlign: TextAlign.center,
              style: TextStyles.font14_400Weight.copyWith(
                color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text('Adjust Filters'),
            ),
          ],
        ),
      ),
    );
  }
}