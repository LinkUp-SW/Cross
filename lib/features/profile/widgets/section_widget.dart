import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class SectionWidget extends ConsumerWidget {
  final String title;
  final Widget child;
  final VoidCallback? onAddPressed; // Callback for the Add icon
  final VoidCallback? onEditPressed; // Callback for the Edit icon

  const SectionWidget({
    super.key,
    required this.title,
    required this.child,
    this.onAddPressed, // Make callbacks optional
    this.onEditPressed,
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
        // Removed shadow to match image more closely, add back if needed
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black12,
        //     blurRadius: 4.r,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row for Title and Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title
              Text(
                title,
                style: TextStyles.font18_600Weight.copyWith( // Slightly bolder/larger title
                  color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
                ),
              ),
              // Action Icons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onAddPressed != null)
                    IconButton(
                      icon: Icon(Icons.add, color: iconColor, size: 24.sp),
                      onPressed: onAddPressed,
                      splashRadius: 20.r,
                      constraints: const BoxConstraints(), // Remove extra padding
                      padding: EdgeInsets.zero, // Remove extra padding
                    ),
                  if (onEditPressed != null)
                    IconButton(
                      icon: Icon(Icons.edit, color: iconColor, size: 20.sp), // Smaller edit icon
                      onPressed: onEditPressed,
                      splashRadius: 20.r,
                      constraints: const BoxConstraints(), // Remove extra padding
                      padding: EdgeInsets.only(left: onAddPressed != null ? 8.w : 0), // Space if Add is present
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          child, // Dynamic content inside the section
        ],
      ),
    );
  }
}