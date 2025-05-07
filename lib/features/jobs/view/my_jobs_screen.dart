import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/jobs/view/job_details.dart';
import 'package:link_up/features/jobs/viewModel/my_jobs_view_model.dart';
import 'package:link_up/features/jobs/viewModel/applied_jobs_view_model.dart';
import 'package:link_up/features/jobs/widgets/empty_jobs_state.dart';
import 'package:link_up/features/jobs/widgets/saved_job_card.dart';
import 'package:link_up/features/jobs/widgets/applied_job_card.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:go_router/go_router.dart';

class MyJobsScreen extends ConsumerStatefulWidget {
  const MyJobsScreen({super.key});

  @override
  ConsumerState<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends ConsumerState<MyJobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    Future.microtask(() {
      // Load both saved and applied jobs
      ref.read(myJobsViewModelProvider.notifier).getSavedJobs();
      ref.read(appliedJobsViewModelProvider.notifier).getAppliedJobs();
    });

    _tabController.addListener(() {
      // Reload data when tab changes
      if (_tabController.index == 0) {
        ref.read(myJobsViewModelProvider.notifier).getSavedJobs();
      } else {
        ref.read(appliedJobsViewModelProvider.notifier).getAppliedJobs();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myJobsState = ref.watch(myJobsViewModelProvider);
    final appliedJobsState = ref.watch(appliedJobsViewModelProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Jobs',
          style: TextStyles.font18_700Weight.copyWith(
            color: isDarkMode ? AppColors.white : AppColors.black,
          ),
        ),
        backgroundColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isDarkMode ? AppColors.white : AppColors.blue,
          labelColor: isDarkMode ? AppColors.white : AppColors.blue,
          unselectedLabelColor: isDarkMode
              ? AppColors.darkSecondaryText
              : AppColors.lightSecondaryText,
          tabs: [
            Tab(
              icon: Icon(Icons.bookmark, size: 20.sp),
              text: 'Saved Jobs',
            ),
            Tab(
              icon: Icon(Icons.work_history, size: 20.sp),
              text: 'Applied Jobs',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Saved Jobs Tab
          _buildSavedJobsTab(myJobsState, isDarkMode),

          // Applied Jobs Tab
          _buildAppliedJobsTab(appliedJobsState, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildSavedJobsTab(myJobsState, bool isDarkMode) {
    if (myJobsState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (myJobsState.savedJobs.isEmpty) {
      return EmptyJobsState(
        isDarkMode: isDarkMode,
        title: 'No Saved Jobs',
        message: 'Save jobs to view them here.',
        onSearchTap: () {
          context.go('/jobs/search');
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(myJobsViewModelProvider.notifier).getSavedJobs();
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: myJobsState.savedJobs.length,
        itemBuilder: (context, index) {
          final job = myJobsState.savedJobs[index];
          return SavedJobCard(
            job: job,
            isDarkMode: isDarkMode,
            onTap: () {
              context.go('/jobs/details/${job.jobId}');
            },
            onUnsave: () {
              ref.read(myJobsViewModelProvider.notifier).unsaveJob(job.jobId);
            },
          );
        },
      ),
    );
  }

  Widget _buildAppliedJobsTab(appliedJobsState, bool isDarkMode) {
    if (appliedJobsState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (appliedJobsState.appliedJobs == null ||
        appliedJobsState.appliedJobs!.isEmpty) {
      return EmptyJobsState(
        isDarkMode: isDarkMode,
        title: 'No Applied Jobs',
        message: 'Apply to jobs to track your applications here.',
        onSearchTap: () {
          context.go('jobs/search');
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(appliedJobsViewModelProvider.notifier).getAppliedJobs();
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: appliedJobsState.appliedJobs!.length,
        itemBuilder: (context, index) {
          final job = appliedJobsState.appliedJobs![index];
          return AppliedJobCard(
            job: job,
            isDarkMode: isDarkMode,
            onTap: () {
              context.go('/jobs/details/${job.id}');
              // Refresh applied jobs after navigation
              ref.read(appliedJobsViewModelProvider.notifier).getAppliedJobs();
            },
          );
        },
      ),
    );
  }
}
