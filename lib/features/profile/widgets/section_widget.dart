// profile/widgets/section_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class SectionWidget extends ConsumerWidget {
  final String title;
  final Widget child;
  final VoidCallback? onAddPressed;
  final VoidCallback? onEditPressed;
  final bool isMyProfile; 

  const SectionWidget({
    super.key,
    required this.title,
    required this.child,
    this.onAddPressed,
    this.onEditPressed,
    required this.isMyProfile, 
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      margin: EdgeInsets.only(top: 10.h),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyles.font18_600Weight.copyWith(
                  color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                ),
              ),
              if (isMyProfile)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onAddPressed != null)
                      IconButton(
                        icon: Icon(Icons.add, color: iconColor, size: 24.sp),
                        onPressed: onAddPressed,
                        splashRadius: 20.r,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        tooltip: "Add $title", 
                      ),
                    if (onEditPressed != null)
                      IconButton(
                        icon: Icon(Icons.edit, color: iconColor, size: 20.sp),
                        onPressed: onEditPressed,
                        splashRadius: 20.r,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.only(left: onAddPressed != null ? 8.w : 0),
                        tooltip: "Edit $title", 
                      ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 8.h),
          child,
        ],
      ),
    );
  }
}