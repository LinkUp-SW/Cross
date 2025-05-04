import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/jobs/viewModel/job_details_view_model.dart';
import 'package:link_up/features/jobs/widgets/job_view_card.dart';
import 'package:link_up/shared/widgets/custom_app_bar.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:go_router/go_router.dart';

class JobDetailsPage extends ConsumerStatefulWidget {
  final String jobId;

  const JobDetailsPage({
    super.key,
    required this.jobId,
  });

  @override
  ConsumerState<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends ConsumerState<JobDetailsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(jobDetailsViewModelProvider.notifier)
          .getJobDetails(widget.jobId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobDetailsViewModelProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        leadingAction: () => context.pop(),
        searchBar: Container(),
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : state.isError
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48.w,
                            color: isDarkMode
                                ? AppColors.darkGrey
                                : AppColors.lightGrey,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            state.errorMessage ?? 'Error loading job details',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDarkMode
                                  ? AppColors.darkTextColor
                                  : AppColors.lightTextColor,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(jobDetailsViewModelProvider.notifier)
                                  .getJobDetails(widget.jobId);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : state.jobDetails == null
                    ? Center(
                        child: Text(
                          'No job details found',
                          style: TextStyle(
                            color: isDarkMode
                                ? AppColors.darkTextColor
                                : AppColors.lightTextColor,
                          ),
                        ),
                      )
                    : JobDetailsCard(
                        isDarkMode: isDarkMode,
                        data: state.jobDetails!,
                      ),
      ),
    );
  }
}
