import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/jobs/widgets/job_card_refactor.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class JobCategoryCard extends ConsumerWidget {
  final bool isDarkMode;
  final String description;
  final List<Widget> categories;
  final List<JobsCard> jobs;
  const JobCategoryCard({
    super.key,
    required this.isDarkMode,
    required this.categories,
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
        children: [
          // Section Header
          Padding(
            padding: EdgeInsets.only(
              left: 8.w,
              top: 5.h,
            ),
            child: Text(
              'Explore with job collections',
              style: TextStyles.font18_700Weight.copyWith(
                color: isDarkMode
                    ? AppColors.darkSecondaryText
                    : AppColors.lightTextColor,
              ),
            ),
          ),
          // Description

          Padding(
            padding: EdgeInsets.only(
              left: 8.w,
              top: 4.h,
              bottom: 12.h,
            ),
            child: Text(
              description,
              style: TextStyles.font13_400Weight.copyWith(
                color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
              ),
            ),
          ),
          // Categories List
          SizedBox(
            height: 80.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                categories.length,
                (index) => Container(
                  width: (MediaQuery.of(context).size.width - 32.w) / 4,
                  alignment: Alignment.center,
                  child: categories[index],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Divider(
              height: 1.h,
              thickness: 0.3.w,
              color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
            ),
          ),
          Column(
            children: jobs,
          ),
        ],
      ),
    );
  }
}
