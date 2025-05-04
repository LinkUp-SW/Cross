import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class EmptyJobsState extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onSearchTap;

  const EmptyJobsState({
    super.key,
    required this.isDarkMode,
    required this.onSearchTap,
    required String title,
    required String message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/no_job.png',
              width: 200.w,
              height: 200.h,
            ),
            SizedBox(height: 24.h),
            Text(
              'No recent job activity',
              style: TextStyles.font20_700Weight.copyWith(
                color: isDarkMode
                    ? AppColors.darkTextColor
                    : AppColors.lightTextColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Find new opportunities and manage your job search progress here.',
              textAlign: TextAlign.center,
              style: TextStyles.font14_400Weight.copyWith(
                color: isDarkMode
                    ? AppColors.darkSecondaryText
                    : AppColors.lightSecondaryText,
              ),
            ),
            SizedBox(height: 24.h),
            OutlinedButton(
              onPressed: onSearchTap,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                side: BorderSide(
                  color: Colors.blue,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: Text(
                'Search for jobs',
                style: TextStyles.font16_600Weight.copyWith(
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
