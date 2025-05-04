/*import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/jobs/model/job_filter_model.dart';
import 'package:link_up/features/jobs/viewModel/job_filter_view_model.dart';
import 'package:link_up/features/jobs/viewModel/search_job_view_model.dart';
import 'package:link_up/features/jobs/widgets/job_filter_card.dart';
import 'package:link_up/features/search/viewModel/jobs_tab_view_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class JobFilterView extends ConsumerStatefulWidget {
  final String searchQuery;

  const JobFilterView({super.key, required this.searchQuery});

  @override
  ConsumerState<JobFilterView> createState() => _JobFilterViewState();
}

class _JobFilterViewState extends ConsumerState<JobFilterView> {
  final List<String> _experienceLevels = [
    'Internship',
    'Entry level',
    'Associate',
    'Mid-Senior level',
    'Director',
    'Executive',
  ];

  final List<String> _locations = [
    'Egypt',
    'Cairo',
    'Alexandria',
    'Remote',
    'On-site',
    'Hybrid',
  ];

  List<String> _selectedExperienceLevels = [];
  String? _selectedLocation;

  final TextEditingController _minSalaryController = TextEditingController();
  final TextEditingController _maxSalaryController = TextEditingController();

  @override
  void dispose() {
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Filter Jobs',
          style: TextStyles.font18_700Weight.copyWith(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedExperienceLevels = [];
                _selectedLocation = null;
                _minSalaryController.clear();
                _maxSalaryController.clear();
              });
            },
            child: Text(
              'Reset',
              style: TextStyle(
                color: isDarkMode ? AppColors.darkBlue : AppColors.lightBlue,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FilterCard(
                      title: 'Experience Level',
                      options: _experienceLevels,
                      selectedOptions: _selectedExperienceLevels,
                      onSelect: (option) {
                        setState(() {
                          if (_selectedExperienceLevels.contains(option)) {
                            _selectedExperienceLevels.remove(option);
                          } else {
                            _selectedExperienceLevels.add(option);
                          }
                        });
                      },
                    ),
                    FilterCard(
                      title: 'Location',
                      options: _locations,
                      selectedOptions: _selectedLocation != null ? [_selectedLocation!] : [],
                      onSelect: (option) {
                        setState(() {
                          if (_selectedLocation == option) {
                            _selectedLocation = null;
                          } else {
                            _selectedLocation = option;
                          }
                        });
                      },
                    ),
                    SalaryFilterCard(
                      minSalaryController: _minSalaryController,
                      maxSalaryController: _maxSalaryController,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    // Create filter model
                    final filter = JobFilterModel(
                      experienceLevel: _selectedExperienceLevels.isNotEmpty ? _selectedExperienceLevels : null,
                      location: _selectedLocation,
                      minSalary: _minSalaryController.text.isNotEmpty 
                          ? int.tryParse(_minSalaryController.text) 
                          : null,
                      maxSalary: _maxSalaryController.text.isNotEmpty 
                          ? int.tryParse(_maxSalaryController.text) 
                          : null,
                    );
                    
                    // Apply filters
                    Map<String, dynamic> queryParams = {
                      'query': widget.searchQuery,
                      'page': '1',
                      'limit': '10',
                    };
                    
                    if (_selectedExperienceLevels.isNotEmpty) {
                      queryParams['experienceLevel'] = _selectedExperienceLevels.join(',');
                    }
                    
                    if (_selectedLocation != null) {
                      queryParams['location'] = _selectedLocation;
                    }
                    
                    if (_minSalaryController.text.isNotEmpty) {
                      queryParams['minSalary'] = _minSalaryController.text;
                    }
                    
                    if (_maxSalaryController.text.isNotEmpty) {
                      queryParams['maxSalary'] = _maxSalaryController.text;
                    }
                    
                    // Store filter in state
                    ref.read(jobFilterViewModelProvider.notifier).filterJobs(filter: filter);
                    
                    // Return to search and apply filters
                    Navigator.pop(context, _selectedLocation);
                    
                    // Apply filters to search
                    ref.read(searchJobViewModelProvider.notifier).searchJobs(
                      queryParameters: queryParams,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? AppColors.darkBlue : AppColors.lightBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Show Results',
                    style: TextStyles.font18_700Weight.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/