// lib/features/company_profile/views/company_profile_view_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/company_profile/viewModel/company_profile_view_view_model.dart';
import 'package:link_up/shared/widgets/custom_app_bar.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/features/jobs/viewModel/job_details_view_model.dart';
import 'package:link_up/features/company_profile/widgets/company_job_card.dart';

class CompanyProfileViewPage extends ConsumerStatefulWidget {
  final String companyId;

  const CompanyProfileViewPage({
    Key? key,
    required this.companyId,
  }) : super(key: key);

  @override
  ConsumerState<CompanyProfileViewPage> createState() =>
      _CompanyProfileViewPageState();
}

class _CompanyProfileViewPageState
    extends ConsumerState<CompanyProfileViewPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(companyProfileViewViewModelProvider.notifier)
          .getCompanyProfile(widget.companyId);
      ref
          .read(companyProfileViewViewModelProvider.notifier)
          .getCompanyJobs(widget.companyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(companyProfileViewViewModelProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        leadingAction: () => context.pop(),
        searchBar: Container(),
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
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
                            state.errorMessage ??
                                'Error loading company profile',
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
                                  .read(companyProfileViewViewModelProvider
                                      .notifier)
                                  .getCompanyProfile(widget.companyId);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : state.companyProfile == null
                    ? Center(
                        child: Text(
                          'No company profile found',
                          style: TextStyle(
                            color: isDarkMode
                                ? AppColors.darkTextColor
                                : AppColors.lightTextColor,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Company header
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Company logo
                                  Container(
                                    width: 80.w,
                                    height: 80.h,
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Colors.grey[800]
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: state.companyProfile?.logo != null &&
                                            state.companyProfile!.logo!
                                                .isNotEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                            child: Image.network(
                                              state.companyProfile!.logo!,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Center(
                                                  child: Icon(
                                                    Icons.business,
                                                    size: 40.sp,
                                                    color: isDarkMode
                                                        ? Colors.grey[600]
                                                        : Colors.grey[400],
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : Center(
                                            child: Icon(
                                              Icons.business,
                                              size: 40.sp,
                                              color: isDarkMode
                                                  ? Colors.grey[600]
                                                  : Colors.grey[400],
                                            ),
                                          ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          state.companyProfile?.name ??
                                              'Company Name',
                                          style: TextStyles.font25_700Weight
                                              .copyWith(
                                            color: isDarkMode
                                                ? AppColors.darkSecondaryText
                                                : AppColors.lightTextColor,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          state.companyProfile?.industry ??
                                              'Industry',
                                          style: TextStyles.font16_400Weight
                                              .copyWith(
                                            color: isDarkMode
                                                ? AppColors.darkTextColor
                                                : AppColors.lightSecondaryText,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          '${state.companyProfile?.location?.city ?? ''}, ${state.companyProfile?.location?.country ?? ''}',
                                          style: TextStyles.font14_400Weight
                                              .copyWith(
                                            color: isDarkMode
                                                ? AppColors.darkTextColor
                                                : AppColors.lightSecondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24.h),

                              // Follow button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Implement follow functionality
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 12.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Follow',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.h),

                              // Company info
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'About',
                                      style:
                                          TextStyles.font20_700Weight.copyWith(
                                        color: isDarkMode
                                            ? AppColors.darkSecondaryText
                                            : AppColors.lightTextColor,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Text(
                                      state.companyProfile?.description ??
                                          'No description available',
                                      style:
                                          TextStyles.font16_400Weight.copyWith(
                                        color: isDarkMode
                                            ? AppColors.darkTextColor
                                            : AppColors.lightSecondaryText,
                                      ),
                                    ),
                                    SizedBox(height: 24.h),

                                    // Company details grid
                                    SizedBox(
                                      width: double.infinity,
                                      child: Wrap(
                                        spacing: 16.w,
                                        runSpacing: 16.h,
                                        children: [
                                          _buildInfoItem(
                                            icon: Icons.people,
                                            title: 'Company Size',
                                            subtitle:
                                                state.companyProfile?.size ??
                                                    'N/A',
                                            isDarkMode: isDarkMode,
                                          ),
                                          _buildInfoItem(
                                            icon: Icons.business_center,
                                            title: 'Company Type',
                                            subtitle:
                                                state.companyProfile?.type ??
                                                    'N/A',
                                            isDarkMode: isDarkMode,
                                          ),
                                          _buildInfoItem(
                                            icon: Icons.category,
                                            title: 'Industry',
                                            subtitle: state
                                                    .companyProfile?.industry ??
                                                'N/A',
                                            isDarkMode: isDarkMode,
                                          ),
                                          if (state.companyProfile?.website !=
                                                  null &&
                                              state.companyProfile!.website!
                                                  .isNotEmpty)
                                            _buildInfoItem(
                                              icon: Icons.language,
                                              title: 'Website',
                                              subtitle: state.companyProfile
                                                      ?.website ??
                                                  'N/A',
                                              isDarkMode: isDarkMode,
                                              isLink: true,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24.h),

                              // Jobs section
                              Text(
                                'Jobs at ${state.companyProfile?.name ?? 'Company'}',
                                style: TextStyles.font20_700Weight.copyWith(
                                  color: isDarkMode
                                      ? AppColors.darkSecondaryText
                                      : AppColors.lightTextColor,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    if (state.isJobsLoading)
                                      Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 24.h),
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    else if (state.isJobsError)
                                      Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 24.h),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                size: 32.sp,
                                                color: isDarkMode
                                                    ? AppColors.darkGrey
                                                    : AppColors.lightGrey,
                                              ),
                                              SizedBox(height: 8.h),
                                              Text(
                                                'Could not load jobs',
                                                style: TextStyles
                                                    .font14_400Weight
                                                    .copyWith(
                                                  color: isDarkMode
                                                      ? AppColors.darkGrey
                                                      : AppColors.lightGrey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    else if (state.companyJobs.isEmpty)
                                      Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 24.h),
                                          child: Text(
                                            'No jobs available at the moment',
                                            style: TextStyles.font16_400Weight
                                                .copyWith(
                                              color: isDarkMode
                                                  ? AppColors.darkGrey
                                                  : AppColors.lightGrey,
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      Column(
                                        children: [
                                          ...state.companyJobs
                                              .map((job) => CompanyJobCard(
                                                    job: job,
                                                    isDarkMode: isDarkMode,
                                                  ))
                                              .toList(),
                                          if (state.companyJobs.isNotEmpty)
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 16.h),
                                              child: TextButton(
                                                onPressed: () {
                                                  // Navigate to a full job listing page
                                                  // You could implement this later
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'View all ${state.companyJobs.length} jobs',
                                                      style: TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    Icon(Icons.arrow_forward,
                                                        size: 16.sp,
                                                        color: Colors.blue),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDarkMode,
    bool isLink = false,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 24.w,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[700] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: isLink
                    ? Colors.blue
                    : (isDarkMode ? Colors.white70 : Colors.black54),
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyles.font14_600Weight.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextColor
                      : AppColors.lightSecondaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyles.font14_400Weight.copyWith(
              color: isLink
                  ? Colors.blue
                  : (isDarkMode
                      ? AppColors.darkSecondaryText
                      : AppColors.lightTextColor),
              decoration: isLink ? TextDecoration.underline : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
