import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class SubPagesAppBar extends StatelessWidget {
  final String title;
  final Widget? action;
  final VoidCallback onClosePressed;

  const SubPagesAppBar({
    Key? key,
    required this.title,
    this.action,
    required this.onClosePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
              size: 24.sp,
            ),
            onPressed: onClosePressed,
          ),
          Text(
            title,
            style: TextStyles.font18_700Weight.copyWith(
              color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
            ),
          ),
          if (action != null) action!,
          if (action == null) SizedBox(width: 40.w), // Placeholder for spacing
        ],
      ),
    );
  }
}