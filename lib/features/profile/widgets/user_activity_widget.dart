// lib/features/profile/widgets/user_activity_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/Home/widgets/posts.dart'; // Assuming Posts widget exists
import 'package:link_up/features/profile/state/user_activity_state.dart';
import 'package:link_up/features/profile/viewModel/user_activity_viewmodel.dart';
import 'package:link_up/features/profile/widgets/section_widget.dart'; // Assuming SectionWidget exists
import 'package:link_up/shared/widgets/custom_snackbar.dart'; // For error display
import 'package:link_up/shared/themes/colors.dart';

class UserActivitySection extends ConsumerStatefulWidget {
  final String userId;

  const UserActivitySection({required this.userId, super.key});

  @override
  ConsumerState<UserActivitySection> createState() => _UserActivitySectionState();
}

class _UserActivitySectionState extends ConsumerState<UserActivitySection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Load more when near the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200.h) {
      ref.read(userActivityViewModelProvider(widget.userId).notifier).loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userActivityViewModelProvider(widget.userId));
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Listen for errors to show a snackbar
    ref.listen<UserActivityState>(userActivityViewModelProvider(widget.userId), (previous, next) {
      if (next.isError && next.errorMessage != null) {
        // Avoid showing snackbar repeatedly for the same error
        if (previous?.errorMessage != next.errorMessage) {
           WidgetsBinding.instance.addPostFrameCallback((_) {
             if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('error loading activity'), backgroundColor: Colors.red),
              );
             }
           });
        }
      }
    });

    return SectionWidget(
      title: "Activity",
      // No add/edit buttons needed for this section directly
      child: _buildContent(state, isDarkMode),
    );
  }

  Widget _buildContent(UserActivityState state, bool isDarkMode) {
    if (state.isLoading && state.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.isError && state.posts.isEmpty) {
      return Center(
        child: Text(
          "Could not load activity.",
          style: TextStyle(color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey),
        ),
      );
    }

    if (state.posts.isEmpty && !state.isLoading) {
      return Center(
        child: Text(
          "No activity to show.",
          style: TextStyle(color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey),
        ),
      );
    }

    // Use ListView.builder for efficiency
    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true, // Important inside SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(), // Let parent scroll
      itemCount: state.posts.length + (state.isLoadingMore ? 1 : 0), // Add 1 for loading indicator
      itemBuilder: (context, index) {
        // Show loading indicator at the end if isLoadingMore is true
        if (index == state.posts.length && state.isLoadingMore) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Prevent index out of bounds if loading indicator isn't needed
        if (index >= state.posts.length) {
            return const SizedBox.shrink(); // Should not happen if logic is correct
        }

        final post = state.posts[index];
        // Wrap each Post in a Card for visual separation (optional)
        return Card(
           elevation: 1,
           margin: EdgeInsets.symmetric(vertical: 5.h),
           color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
           child: Posts(
              post: post,
              inFeed: false, // Indicate it's not in the main feed
              showBottom: true, // Or false, depending on design
            ),
        );
      },
    );
  }
}