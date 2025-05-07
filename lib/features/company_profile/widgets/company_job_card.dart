// lib/features/company_profile/widgets/company_job_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/company_profile/model/company_jobs_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:intl/intl.dart';

class CompanyJobCard extends ConsumerWidget {
  final CompanyJobModel job;
  final bool isDarkMode;

  const CompanyJobCard({
    Key? key,
    required this.job,
    required this.isDarkMode,
  }) : super(key: key);

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays < 1) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        return '${(difference.inDays / 7).floor()} weeks ago';
      } else if (difference.inDays < 365) {
        return '${(difference.inDays / 30).floor()} months ago';
      } else {
        return '${(difference.inDays / 365).floor()} years ago';
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8.r),
          onTap: () {
            // Navigate to job details
            context.push('/jobs/details/${job.id}');
          },
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        job.jobTitle,
                        style: TextStyles.font18_700Weight.copyWith(
                          color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: job.jobStatus.toLowerCase() == 'open'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        job.jobStatus,
                        style: TextStyles.font12_700Weight.copyWith(
                          color: job.jobStatus.toLowerCase() == 'open'
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16.sp,
                      color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        job.location,
                        style: TextStyles.font14_400Weight.copyWith(
                          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightSecondaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.work_outline,
                      size: 16.sp,
                      color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      job.jobType,
                      style: TextStyles.font14_400Weight.copyWith(
                        color: isDarkMode ? AppColors.darkTextColor : AppColors.lightSecondaryText,
                      ),
                    ),
                    Spacer(),
                    Text(
                      _formatDate(job.postedTime),
                      style: TextStyles.font12_400Weight.copyWith(
                        color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}