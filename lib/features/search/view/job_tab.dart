import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/jobs/model/search_job_model.dart';
import 'package:link_up/features/jobs/view/job_filter_screen.dart';
import 'package:link_up/features/jobs/view/job_filter_screen.dart';
import 'package:link_up/features/jobs/viewModel/search_job_view_model.dart';
import 'package:link_up/features/jobs/widgets/job_search_card.dart';
import 'package:link_up/features/search/viewModel/jobs_tab_view_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/utils/my_network_utils.dart';

class SearchView extends ConsumerWidget {
  final String searchQuery;
  final String? location;
  
  const SearchView({
    super.key,
    required this.searchQuery,
    this.location,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(searchJobViewModelProvider);
    
    // Make sure the search is added to recent searches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchJobViewModelProvider.notifier).addToRecentSearches(searchQuery);
    });
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
                border: Border(
                  bottom: BorderSide(
                    color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Container(
                      height: 40.h,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(
                          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              searchQuery,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Location chip
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 20.sp,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    location ?? 'All Locations',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),

            // Filter buttons row
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterButton(
                      context: context,
                      isDarkMode: isDarkMode,
                      icon: Icons.work_outline,
                      label: 'Experience Level',
                      onTap: () async {
                        final String? newLocation = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobFilterView(searchQuery: searchQuery),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 8.w),
                    _buildFilterButton(
                      context: context,
                      isDarkMode: isDarkMode,
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      onTap: () async {
                        final String? newLocation = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobFilterView(searchQuery: searchQuery),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 8.w),
                    _buildFilterButton(
                      context: context,
                      isDarkMode: isDarkMode,
                      icon: Icons.attach_money,
                      label: 'Salary',
                      onTap: () async {
                        final String? newLocation = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobFilterView(searchQuery: searchQuery),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Results count
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${parseIntegerToCommaSeparatedString(state.totalJobs ?? 0)} results',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ),

            // Results list
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.isError
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Error loading search results',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              ElevatedButton(
                                onPressed: () {
                                  ref.read(searchJobViewModelProvider.notifier).searchJobs(
                                    queryParameters: {
                                      'query': searchQuery,
                                      'page': '1',
                                      'limit': '10'
                                    },
                                  );
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : state.searchJobs == null || state.searchJobs!.isEmpty
                          ? Center(
                              child: Text(
                                'No jobs found matching "$searchQuery"',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                                ),
                              ),
                            )
                          : NotificationListener<ScrollNotification>(
                              onNotification: (notification) {
                                if (notification is ScrollEndNotification &&
                                    notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200 &&
                                    !state.isLoadingMore &&
                                    state.currentPage != null &&
                                    state.currentPage! < (state.totalPages ?? 1)) {
                                  ref.read(searchJobViewModelProvider.notifier).loadMoreJobs(
                                    queryParameters: {
                                      "query": searchQuery,
                                      if (location?.isNotEmpty == true)
                                        "location": location!,
                                      "page": '${state.currentPage! + 1}',
                                      "limit": '${state.limit}'
                                    },
                                  );
                                }
                                return false;
                              },
                              child: ListView.builder(
                                itemCount: state.searchJobs!.length + (state.isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == state.searchJobs!.length) {
                                    return Padding(
                                      padding: EdgeInsets.all(16.h),
                                      child: const Center(child: CircularProgressIndicator()),
                                    );
                                  }
                                  return JobSearchCard(
                                    data: state.searchJobs![index],
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required BuildContext context,
    required bool isDarkMode,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.arrow_drop_down,
              size: 18.sp,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}