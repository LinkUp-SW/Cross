import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/jobs/model/search_job_model.dart';
import 'package:link_up/features/jobs/viewModel/search_job_view_model.dart';
import 'package:link_up/features/jobs/widgets/job_search_card.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/utils/my_network_utils.dart';

class SearchView extends ConsumerWidget {
  final String searchQuery;
  
  const SearchView({
    super.key,
    required this.searchQuery,
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
      appBar: AppBar(
        title: Text(
          'Search Results: "$searchQuery"',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter chips row
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 10.h,
                  horizontal: 10.w,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FilterChip(
                      selected: true,
                      backgroundColor:
                          isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                      selectedColor:
                          isDarkMode ? AppColors.darkGreen : AppColors.lightGreen,
                      label: Text(
                        'All',
                        style: TextStyles.font14_500Weight.copyWith(
                          color: isDarkMode
                              ? AppColors.darkBackground
                              : AppColors.lightBackground,
                        ),
                      ),
                      onSelected: (bool selected) {},
                    ),
                    FilterChip(
                      selected: false,
                      backgroundColor:
                          isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                      selectedColor:
                          isDarkMode ? AppColors.darkGreen : AppColors.lightGreen,
                      label: Text(
                        'Remote',
                        style: TextStyles.font14_500Weight.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.lightSecondaryText,
                        ),
                      ),
                      onSelected: (bool selected) {
                        if (selected) {
                          ref
                              .read(searchJobViewModelProvider.notifier)
                              .searchJobs(
                            queryParameters: {
                              'query': searchQuery,
                              'page': '1',
                              'limit': '10',
                              'workplace_type': 'Remote'
                            },
                          );
                        }
                      },
                    ),
                    FilterChip(
                      selected: false,
                      backgroundColor:
                          isDarkMode ? AppColors.darkMain : AppColors.lightMain,
                      selectedColor:
                          isDarkMode ? AppColors.darkGreen : AppColors.lightGreen,
                      label: Text(
                        'Entry Level',
                        style: TextStyles.font14_500Weight.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextColor
                              : AppColors.lightSecondaryText,
                        ),
                      ),
                      onSelected: (bool selected) {
                        if (selected) {
                          ref
                              .read(searchJobViewModelProvider.notifier)
                              .searchJobs(
                            queryParameters: {
                              'query': searchQuery,
                              'page': '1',
                              'limit': '10',
                              'experience_level': 'Entry level'
                            },
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Results count
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'About ${parseIntegerToCommaSeparatedString(state.totalJobs ?? 0)} results',
                  style: TextStyles.font15_500Weight.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextColor
                        : AppColors.lightSecondaryText,
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
                                  color: isDarkMode
                                      ? AppColors.darkTextColor
                                      : AppColors.lightTextColor,
                                ),
                              ),
                              const SizedBox(height: 8),
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
                                  color: isDarkMode
                                      ? AppColors.darkTextColor
                                      : AppColors.lightTextColor,
                                ),
                              ),
                            )
                          : NotificationListener<ScrollNotification>(
                              onNotification: (notification) {
                                // Load more jobs when near the end of the list
                                if (notification is ScrollEndNotification &&
                                    notification.metrics.pixels >=
                                        notification.metrics.maxScrollExtent - 200 &&
                                    !state.isLoadingMore &&
                                    state.currentPage != null &&
                                    state.currentPage! < (state.totalPages ?? 1)) {
                                  ref.read(searchJobViewModelProvider.notifier).loadMoreJobs(
                                    queryParameters: {
                                      "query": searchQuery,
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
                                    // Loading indicator at the bottom when loading more jobs
                                    return const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  }
                                  
                                  // Job card
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
} 