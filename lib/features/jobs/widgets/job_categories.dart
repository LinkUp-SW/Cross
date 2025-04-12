import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/jobs/model/jobs_screen_categories_model.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

// Add this provider at the top of the file
final selectedCategoryProvider = StateProvider<JobsCategoryModel?>((ref) => null);

class JobCategory extends ConsumerWidget {
  final bool isDarkMode;
  final JobsCategoryModel data;
  final VoidCallback? onTap;

  const JobCategory({
    super.key,
    required this.isDarkMode,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final isSelected = selectedCategory?.categoryName == data.categoryName;

    return GestureDetector(
      onTap: () {
        ref.read(selectedCategoryProvider.notifier).state = data;
      },
      child: Padding(
        padding: EdgeInsets.only(right: 12.w),
        child: Column(
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.lightBlue.withOpacity(0.2)
                    : (isDarkMode ? AppColors.darkGrey : AppColors.lightGrey),
                borderRadius: BorderRadius.circular(12.r),
                border: isSelected
                    ? Border.all(color: Colors.lightBlue, width: 2)
                    : null,
              ),
              child: Image.asset(
                data.categoryIcon,
                width: 10.w,
                height: 10.w,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              data.categoryName,
              style: TextStyles.font12_400Weight.copyWith(
                color: isSelected
                    ? Colors.lightBlue
                    : (isDarkMode 
                        ? AppColors.darkSecondaryText 
                        : AppColors.lightTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}