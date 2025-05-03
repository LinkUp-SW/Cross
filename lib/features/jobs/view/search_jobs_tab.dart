/*import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/jobs/viewModel/search_job_view_model.dart';
import 'package:link_up/features/jobs/widgets/job_search_card.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/utils/my_network_utils.dart';


class SearchJobsTab extends ConsumerStatefulWidget {
  final String keyWord;
  
  const SearchJobsTab({
    super.key,
    required this.keyWord,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchJobsTabState();
}

class _SearchJobsTabState extends ConsumerState<SearchJobsTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.keyWord.isNotEmpty) {
        ref.read(searchJobViewModelProvider.notifier).searchJobs(
          queryParameters: {
            'query': widget.keyWord,
            'page': '1',
            'limit': '10'
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(searchJobViewModelProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                          'query': widget.keyWord,
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
                          'query': widget.keyWord,
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
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // Check if user has scrolled to near the end
              if (notification is ScrollEndNotification &&
                  notification.metrics.pixels >=
                      notification.metrics.maxScrollExtent - 200 &&
                  !state.isLoadingMore &&
                  state.currentPage != null) {
                ref.read(searchJobViewModelProvider.notifier).loadMoreJobs(
                  queryParameters: {
                    "query": widget.keyWord,
                    "page": '${state.currentPage! + 1}',
                    "limit": '${state.limit}'
                  },
                );
              }
              return false;
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
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
                state.isLoading && state.searchJobs == null
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildLoadingSkeleton(isDarkMode),
                          childCount: 3,
                        ),
                      )
                    : state.searchJobs == null ||
                            state.searchJobs!.isEmpty ||
                            state.isError
                        ? SliverToBoxAdapter(
                            child: _buildEmptyMessage(
                              widget.keyWord.isNotEmpty &&
                                      widget.keyWord != " "
                                  ? 'No jobs found based on "${widget.keyWord}"'
                                  : 'Please enter search keyword',
                              isDarkMode,
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index == state.searchJobs!.length) {
                                  // Loading indicator at bottom when loading more
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16.h),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: isDarkMode
                                            ? AppColors.darkBlue
                                            : AppColors.lightBlue,
                                      ),
                                    ),
                                  );
                                }
                                return JobSearchCard(
                                  data: state.searchJobs![index],
                                );
                              },
                              childCount: state.searchJobs!.length +
                                  (state.isLoadingMore ? 1 : 0),
                            ),
                          ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLoadingSkeleton(bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company logo skeleton
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          SizedBox(width: 12.w),
          
          // Content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 150.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 100.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Container(
                      width: 80.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 80.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Bookmark skeleton
          Container(
            width: 30.w,
            height: 30.h,
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyMessage(String message, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64.sp,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
} */