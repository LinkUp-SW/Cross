import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class JobsSection extends ConsumerWidget {
  final bool isDarkMode;
  final String title;
  final String description;
  final List<Widget> jobs;

  const JobsSection({
    super.key,
    required this.isDarkMode,
    required this.title,
    required this.description,
    required this.jobs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.h,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 8.w,
              top: 5.h,
            ),
            child: Text(
              title,
              style: TextStyles.font18_700Weight.copyWith(
                color: isDarkMode
                    ? AppColors.darkSecondaryText
                    : AppColors.lightTextColor,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
            ),
            child: Text(
              description,
              style: TextStyles.font13_700Weight.copyWith(
                color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ...jobs,
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h),
            child: InkWell(
              onTap: () {
                 context.go('/jobs/all');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 5.w,
                children: [
                  Text(
                    "Show all",
                    style: TextStyles.font15_700Weight.copyWith(
                      color: isDarkMode
                          ? AppColors.darkTextColor
                          : AppColors.lightSecondaryText,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: isDarkMode
                        ? AppColors.darkTextColor
                        : AppColors.lightSecondaryText,
                    size: 20.h,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}