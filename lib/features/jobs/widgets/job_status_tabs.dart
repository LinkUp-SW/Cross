import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

enum JobStatus {
  saved,
  inProgress,
  applied,
  archived,
}

class JobStatusTabs extends StatelessWidget {
  final JobStatus selectedStatus;
  final Function(JobStatus) onStatusChanged;
  final bool isDarkMode;

  const JobStatusTabs({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          _buildStatusTab(JobStatus.saved, 'Saved'),
          SizedBox(width: 8.w),
          _buildStatusTab(JobStatus.inProgress, 'In Progress'),
          SizedBox(width: 8.w),
          _buildStatusTab(JobStatus.applied, 'Applied'),
          SizedBox(width: 8.w),
          _buildStatusTab(JobStatus.archived, 'Archived'),
        ],
      ),
    );
  }

  Widget _buildStatusTab(JobStatus status, String label) {
    final isSelected = selectedStatus == status;
    final backgroundColor = isSelected
        ? (status == JobStatus.archived
            ? Colors.green
            : Colors.blue)
        : isDarkMode
            ? AppColors.darkGrey.withOpacity(0.1)
            : AppColors.lightGrey.withOpacity(0.1);

    final textColor = isSelected
        ? Colors.white
        : isDarkMode
            ? AppColors.darkTextColor
            : AppColors.lightTextColor;

    return InkWell(
      onTap: () => onStatusChanged(status),
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isSelected
                ? backgroundColor
                : isDarkMode
                    ? AppColors.darkGrey.withOpacity(0.3)
                    : AppColors.lightGrey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyles.font14_600Weight.copyWith(
            color: textColor,
          ),
        ),
      ),
    );
  }
} 