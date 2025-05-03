import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/jobs/model/applied_job_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class AppliedJobCard extends StatelessWidget {
  final AppliedJobModel job;
  final bool isDarkMode;
  final VoidCallback onTap;

  const AppliedJobCard({
    Key? key,
    required this.job,
    required this.isDarkMode,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      color: isDarkMode ? AppColors.darkGrey.withOpacity(0.2) : Colors.white,
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
                  // Company logo
                  Container(
                    width: 50.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: isDarkMode 
                          ? AppColors.darkGrey.withOpacity(0.3) 
                          : AppColors.lightGrey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: job.organization.logo.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.network(
                              job.organization.logo,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.business,
                                    color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.business,
                              color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
                            ),
                          ),
                  ),
                  SizedBox(width: 16.w),
                  
                  // Job details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.jobTitle,
                          style: TextStyles.font18_700Weight.copyWith(
                            color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          job.organization.name,
                          style: TextStyles.font14_500Weight.copyWith(
                            color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          job.location,
                          style: TextStyles.font14_400Weight.copyWith(
                            color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              
              // Job attributes
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _buildTag(job.workplaceType, isDarkMode),
                  _buildTag(job.experienceLevel, isDarkMode),
                  if (job.salary > 0)
                    _buildTag('\$${job.salary}', isDarkMode),
                ],
              ),
              SizedBox(height: 12.h),
              
              // Application status
              _buildApplicationStatus(job.applicationStatus, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? AppColors.darkGrey.withOpacity(0.3) 
            : AppColors.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyles.font12_400Weight.copyWith(
          color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
        ),
      ),
    );
  }

  Widget _buildApplicationStatus(String status, bool isDarkMode) {
    Color statusColor;
    IconData statusIcon;
    
    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'viewed':
        statusColor = Colors.blue;
        statusIcon = Icons.visibility;
        break;
      case 'interviewing':
        statusColor = Colors.purple;
        statusIcon = Icons.people;
        break;
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
        statusIcon = Icons.info_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 16.sp,
            color: statusColor,
          ),
          SizedBox(width: 6.w),
          Text(
            'Application $status',
            style: TextStyles.font12_500Weight.copyWith(
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}