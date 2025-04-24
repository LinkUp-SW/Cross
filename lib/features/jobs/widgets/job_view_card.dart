import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/jobs/model/job_detail_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class JobDetailsCard extends ConsumerWidget {
  final bool isDarkMode;
  final JobDetailsModel data;

  const JobDetailsCard({
    super.key,
    required this.isDarkMode,
    required this.data,
  });

  Widget _buildCompanyLogo() {
    return Container(
      width: 60.w,
      height: 60.h,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: data.logo.isNotEmpty
            ? Image.network(
                data.logo,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.business,
                      size: 30.w,
                      color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 30.w,
                      height: 30.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDarkMode ? Colors.grey[600]! : Colors.grey[400]!,
                        ),
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Icon(
                  Icons.business,
                  size: 30.w,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company logo and name
          Padding(
            padding: EdgeInsets.all(16.0.w),
            child: Row(
              children: [
                _buildCompanyLogo(),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.organizationName,
                        style: TextStyles.font18_700Weight.copyWith(
                          color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Job title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w),
            child: Text(
              data.jobTitle,
              style: TextStyles.font25_700Weight.copyWith(
                color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor,
              ),
            ),
          ),
          
          // Location and time posted
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 8.0.h),
            child: Row(
              children: [
                Text(
                  '${data.location} · ',
                  style: TextStyles.font14_400Weight.copyWith(
                    color: isDarkMode ? AppColors.darkTextColor : AppColors.lightSecondaryText,
                  ),
                ),
                Text(
                  data.postedTime,
                  style: TextStyles.font14_400Weight.copyWith(
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          
          // Job type tags
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _buildTag(data.workplaceType),
                _buildTag(data.experienceLevel),
              ],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Apply and Save buttons
          Padding(
            padding: EdgeInsets.all(16.0.w),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Apply'),
                        SizedBox(width: 4.w),
                        Icon(Icons.open_in_new, size: 16.sp),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
          
          // About the job
          Padding(
            padding: EdgeInsets.all(16.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About the job',
                  style: TextStyles.font18_700Weight.copyWith(
                    color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  data.description,
                  style: TextStyles.font14_400Weight.copyWith(
                    color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                  ),
                ),
                if (data.qualifications.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Text(
                    'Required Qualifications',
                    style: TextStyles.font18_700Weight.copyWith(
                      color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: data.qualifications
                        .map((qualification) => _buildTag(qualification))
                        .toList(),
                  ),
                ],
                if (data.responsibilities.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Text(
                    'Responsibilities',
                    style: TextStyles.font18_700Weight.copyWith(
                      color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: data.responsibilities
                        .map((responsibility) => _buildTag(responsibility))
                        .toList(),
                  ),
                ],
                if (data.benefits.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Text(
                    'Benefits',
                    style: TextStyles.font18_700Weight.copyWith(
                      color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightTextColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: data.benefits
                        .map((benefit) => _buildTag(benefit))
                        .toList(),
                  ),
                ],
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0.w, vertical: 6.0.h),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkGrey.withOpacity(0.3) : AppColors.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        text,
        style: TextStyles.font14_400Weight.copyWith(
          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
        ),
      ),
    );
  }
}