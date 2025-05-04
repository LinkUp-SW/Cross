import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/jobs/model/jobs_screen_model.dart';
import 'package:link_up/features/jobs/view/filter_result.dart';
import 'package:link_up/features/jobs/view/filter_result.dart'; // Import the new page
import 'package:link_up/features/jobs/viewModel/job_filter_view_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class JobFilterWidget extends ConsumerStatefulWidget {
  final List<JobsCardModel> allJobs;
  final Function(bool isApplied) onFilterApplied;

  const JobFilterWidget({
    Key? key,
    required this.allJobs,
    required this.onFilterApplied,
  }) : super(key: key);

  @override
  ConsumerState<JobFilterWidget> createState() => _JobFilterWidgetState();
}

class _JobFilterWidgetState extends ConsumerState<JobFilterWidget> {
  final TextEditingController _locationController = TextEditingController();
  List<String> selectedExperienceLevels = [];
  double _minSalary = 0;
  double _maxSalary = 100000;

  final List<String> experienceLevels = [
    'Entry-level',
    'Associate',
    'Mid-Senior',
    'Director',
    'Executive',
    'Internship',
  ];

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    ref
        .read(jobFilterViewModelProvider(widget.allJobs).notifier)
        .resetAllFilters();
    _locationController.clear();
    setState(() {
      selectedExperienceLevels = [];
      _minSalary = 0;
      _maxSalary = 100000;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Filter Jobs',
          style: TextStyles.font18_700Weight.copyWith(
            color:
                isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color:
                isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location filter
                  Text(
                    'Location',
                    style: TextStyles.font18_700Weight.copyWith(
                      color: isDarkMode
                          ? AppColors.darkSecondaryText
                          : AppColors.lightTextColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      hintText: 'Enter location',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: isDarkMode
                              ? Colors.grey[700]!
                              : Colors.grey[300]!,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      fillColor:
                          isDarkMode ? Colors.grey[800] : Colors.grey[50],
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Experience level filter
                  Text(
                    'Experience Level',
                    style: TextStyles.font18_700Weight.copyWith(
                      color: isDarkMode
                          ? AppColors.darkSecondaryText
                          : AppColors.lightTextColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: experienceLevels.map((level) {
                      final isSelected =
                          selectedExperienceLevels.contains(level);
                      return FilterChip(
                        label: Text(level),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedExperienceLevels.add(level);
                            } else {
                              selectedExperienceLevels.remove(level);
                            }
                          });
                        },
                        backgroundColor:
                            isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        selectedColor:
                            isDarkMode ? Colors.blue[700] : Colors.blue[100],
                        checkmarkColor: isDarkMode ? Colors.white : Colors.blue,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? (isDarkMode ? Colors.white : Colors.blue[800])
                              : (isDarkMode
                                  ? AppColors.darkTextColor
                                  : AppColors.lightTextColor),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24.h),

                  // Salary range filter
                  Text(
                    'Salary Range',
                    style: TextStyles.font18_700Weight.copyWith(
                      color: isDarkMode
                          ? AppColors.darkSecondaryText
                          : AppColors.lightTextColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${_minSalary.toInt()}',
                        style: TextStyles.font14_400Weight.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.lightTextColor,
                        ),
                      ),
                      Text(
                        '\$${_maxSalary.toInt()}',
                        style: TextStyles.font14_400Weight.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.lightTextColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  RangeSlider(
                    values: RangeValues(_minSalary, _maxSalary),
                    min: 0,
                    max: 100000,
                    divisions: 100,
                    labels: RangeLabels(
                      '\$${_minSalary.toInt()}',
                      '\$${_maxSalary.toInt()}',
                    ),
                    activeColor: Colors.blue,
                    inactiveColor:
                        isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    onChanged: (RangeValues values) {
                      setState(() {
                        _minSalary = values.start;
                        _maxSalary = values.end;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Apply/Reset buttons
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkMain : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Reset button
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(
                        color:
                            isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Reset',
                      style: TextStyles.font16_500Weight.copyWith(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                // Apply button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      // Create filter parameters
                      final location = _locationController.text.isEmpty
                          ? null
                          : _locationController.text;
                      final experienceLevel = selectedExperienceLevels.isEmpty
                          ? null
                          : selectedExperienceLevels;
                      final minSalary =
                          _minSalary > 0 ? _minSalary.toInt() : null;
                      final maxSalary =
                          _maxSalary < 100000 ? _maxSalary.toInt() : null;

                      // Apply filters to get filtered jobs
                      final filterViewModel = ref.read(
                          jobFilterViewModelProvider(widget.allJobs).notifier);
                      filterViewModel.applyFilters(
                        location: location,
                        experienceLevel: experienceLevel,
                        minSalary: minSalary,
                        maxSalary: maxSalary,
                      );

                      // Get filtered jobs from state
                      final filteredJobs = ref
                          .read(jobFilterViewModelProvider(widget.allJobs))
                          .filteredJobs;

                      // Create a map of applied filters for display
                      final appliedFilters = {
                        'location': location,
                        'experienceLevel': experienceLevel,
                        'minSalary': minSalary,
                        'maxSalary': maxSalary,
                      };

                      // Notify parent that filters were applied
                      widget.onFilterApplied(true);

                      // Navigate to filtered results page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FilteredJobsResultsPage(
                            filteredJobs: filteredJobs,
                            appliedFilters: appliedFilters,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: TextStyles.font16_500Weight.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
