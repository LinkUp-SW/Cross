import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/jobs/model/job_detail_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class SavedJobCard extends StatelessWidget {
  final JobDetailsModel job;
  final bool isDarkMode;
  final VoidCallback onTap;
  final VoidCallback onUnsave;

  const SavedJobCard({
    super.key,
    required this.job,
    required this.isDarkMode,
    required this.onTap,
    required this.onUnsave,
  });

  Widget _buildCompanyLogo() {
    return Container(
      width: 50.w,
      height: 50.h,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: job.logo.isNotEmpty
            ? Image.network(
                job.logo,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.business,
                      size: 24.w,
                      color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                    ),
                  );
                },
              )
            : Center(
                child: Icon(
                  Icons.business,
                  size: 24.w,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: isDarkMode ? AppColors.darkGrey.withOpacity(0.2) : AppColors.lightGrey.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompanyLogo(),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.jobTitle,
                          style: TextStyles.font15_700Weight.copyWith(
                            color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          job.organizationName,
                          style: TextStyles.font14_400Weight.copyWith(
                            color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onUnsave,
                    icon: Icon(
                      Icons.bookmark,
                      color: Colors.blue,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16.sp,
                    color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    job.location,
                    style: TextStyles.font12_400Weight.copyWith(
                      color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Icon(
                    Icons.access_time,
                    size: 16.sp,
                    color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    job.timeAgo,
                    style: TextStyles.font12_400Weight.copyWith(
                      color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  _buildTag(job.workplaceType),
                  SizedBox(width: 8.w),
                  _buildTag(job.experienceLevel),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkGrey.withOpacity(0.1) : AppColors.lightGrey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDarkMode ? AppColors.darkGrey.withOpacity(0.2) : AppColors.lightGrey.withOpacity(0.2),
        ),
      ),
      child: Text(
        text,
        style: TextStyles.font12_400Weight.copyWith(
          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
        ),
      ),
    );
  }
} 