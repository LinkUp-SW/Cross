import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/jobs/viewModel/search_job_view_model.dart';
import 'package:link_up/features/jobs/widgets/job_search_card.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/utils/my_network_utils.dart';
import 'package:link_up/shared/widgets/custom_app_bar.dart';
import 'package:link_up/features/jobs/view/search_view.dart';
import 'dart:developer' as developer;

class SearchJobsPage extends ConsumerStatefulWidget {
  const SearchJobsPage({super.key});

  @override
  ConsumerState<SearchJobsPage> createState() => _SearchJobsPageState();
}

class _SearchJobsPageState extends ConsumerState<SearchJobsPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String searchKeyword = '';
  bool showClearButton = false;
  bool showSuggestions = false;
  
  // Recent searches or dynamic suggestions based on input
  List<String> filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        showClearButton = _searchController.text.isNotEmpty;
        
        // Get recent searches from state
        final recentSearches = ref.read(searchJobViewModelProvider).recentSearches;
        
        // Filter suggestions based on input
        if (_searchController.text.isNotEmpty) {
          filteredSuggestions = recentSearches
              .where((item) => item.toLowerCase().contains(
                    _searchController.text.toLowerCase(),
                  ))
              .toList();
          
          // Show suggestions when typing
          showSuggestions = true;
        } else {
          filteredSuggestions = recentSearches;
          // Hide suggestions when search bar is empty and not focused
          showSuggestions = _searchFocusNode.hasFocus;
        }
      });
    });
    
    _searchFocusNode.addListener(() {
      setState(() {
        // Show suggestions when search bar is focused
        showSuggestions = _searchFocusNode.hasFocus || _searchController.text.isNotEmpty;
        
        // Update filtered suggestions when focus changes
        if (showSuggestions) {
          final recentSearches = ref.read(searchJobViewModelProvider).recentSearches;
          if (_searchController.text.isEmpty) {
            filteredSuggestions = recentSearches;
          } else {
            filteredSuggestions = recentSearches
                .where((item) => item.toLowerCase().contains(
                      _searchController.text.toLowerCase(),
                    ))
                .toList();
          }
        }
      });
    });
    
    // Initialize filtered suggestions with recent searches
    Future.microtask(() {
      final recentSearches = ref.read(searchJobViewModelProvider).recentSearches;
      setState(() {
        filteredSuggestions = recentSearches;
      });
    });
    
    // Give focus to search field when page opens
    Future.microtask(() => _searchFocusNode.requestFocus());
    
    // Clear any previous search state
    Future.microtask(() {
      ref.read(searchJobViewModelProvider.notifier).clearSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void performSearch(String query) {
    // Hide keyboard
    FocusScope.of(context).unfocus();
    
    // Trim and validate query
    final String trimmedQuery = query.trim();
    developer.log('Performing search with query: "$trimmedQuery"');
    
    if (trimmedQuery.isEmpty) {
      developer.log('Empty search query, not performing search');
      return;
    }
    
    setState(() {
      searchKeyword = trimmedQuery;
      showSuggestions = false;
    });
    
    // Perform search
    final Map<String, dynamic> searchParams = {
      'query': trimmedQuery,
      'page': '1',
      'limit': '10'
    };
    
    developer.log('Search parameters: $searchParams');
    
    // Trigger search in the ViewModel
    ref.read(searchJobViewModelProvider.notifier).searchJobs(
      queryParameters: searchParams,
    );
    
    // Navigate to search results page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchView(
          searchQuery: trimmedQuery,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(searchJobViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Job Search'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar and location
            Container(
              color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                children: [
                  // Search bar
                  Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onSubmitted: performSearch,
                      decoration: InputDecoration(
                        hintText: 'Search by title, skill, or company',
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        suffixIcon: showClearButton
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    searchKeyword = '';
                                    showSuggestions = _searchFocusNode.hasFocus;
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  // Location bar
                  Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Icon(
                            Icons.location_on_outlined,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Egypt',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Show suggestions or search results
            Expanded(
              child: showSuggestions
                  ? buildSuggestionsList(isDarkMode)
                  : searchKeyword.isNotEmpty
                      ? buildSearchResults(isDarkMode, state)
                      : Center(
                          child: Text(
                            'Search for jobs to get started',
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSuggestionsList(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                filteredSuggestions.isEmpty 
                    ? 'No recent searches' 
                    : 'Recent searches',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (filteredSuggestions.isNotEmpty)
                TextButton(
                  onPressed: () {
                    // Clear all recent searches
                    ref.read(searchJobViewModelProvider.notifier).clearRecentSearches();
                    setState(() {
                      filteredSuggestions = [];
                    });
                  },
                  child: Text(
                    'Clear all',
                    style: TextStyle(
                      color: isDarkMode ? AppColors.darkBlue : AppColors.lightBlue,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: filteredSuggestions.isEmpty
              ? Center(
                  child: Text(
                    'Your recent searches will appear here',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                      fontSize: 14.sp,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: filteredSuggestions.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  ),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(
                        Icons.history,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      title: Text(
                        filteredSuggestions[index],
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 18.sp,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                            onPressed: () {
                              // Remove this search from history
                              ref.read(searchJobViewModelProvider.notifier)
                                  .deleteFromRecentSearches(filteredSuggestions[index]);
                              setState(() {
                                filteredSuggestions.removeAt(index);
                              });
                            },
                          ),
                          Icon(
                            Icons.north_east,
                            size: 20.sp,
                            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ],
                      ),
                      onTap: () {
                        final suggestion = filteredSuggestions[index];
                        _searchController.text = suggestion;
                        
                        // Perform search with the suggestion
                        final searchParams = {
                          'query': suggestion,
                          'page': '1',
                          'limit': '10'
                        };
                        
                        // Trigger search in view model
                        ref.read(searchJobViewModelProvider.notifier).searchJobs(
                          queryParameters: searchParams,
                        );
                        
                        // Navigate to search results
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchView(
                              searchQuery: suggestion,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget buildSearchResults(bool isDarkMode, dynamic state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter chips
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
                          'query': searchKeyword,
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
                          'query': searchKeyword,
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
        
        // Results list
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
                    "query": searchKeyword,
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
                              searchKeyword.isNotEmpty &&
                                      searchKeyword != " "
                                  ? 'No jobs found based on "${searchKeyword}"'
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
} 