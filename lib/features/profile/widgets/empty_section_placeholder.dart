import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/themes/button_styles.dart';

class EmptySectionPlaceholder extends StatelessWidget {
  final IconData icon;
  final String titlePlaceholder;
  final String subtitlePlaceholder;
  final String datePlaceholder;
  final String callToActionText;
  final VoidCallback onAddPressed;
  final String? sectionSubtitle; 

  const EmptySectionPlaceholder({
    super.key,
    required this.icon,
    required this.titlePlaceholder,
    required this.subtitlePlaceholder,
    required this.datePlaceholder,
    required this.callToActionText,
    required this.onAddPressed,
    this.sectionSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final placeholderColor = AppColors.lightGrey;
    final buttonStyles = LinkUpButtonStyles();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        if (sectionSubtitle != null) ...[
           Text(
             sectionSubtitle!,
             style: TextStyles.font13_400Weight.copyWith(color: placeholderColor),
           ),
           SizedBox(height: 15.h),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            Container(
              width: 40.w,
              height: 40.h,
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkGrey.withOpacity(0.1) : AppColors.lightGrey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Icon(icon, color: placeholderColor, size: 20.sp),
            ),
            Expanded(
              child: Opacity(
                opacity: 0.6, 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titlePlaceholder,
                      style: TextStyles.font16_600Weight.copyWith(color: placeholderColor),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitlePlaceholder,
                      style: TextStyles.font14_400Weight.copyWith(color: placeholderColor),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      datePlaceholder, 
                      style: TextStyles.font12_400Weight.copyWith(color: placeholderColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: onAddPressed,
            style: (isDarkMode
                ? buttonStyles.blueOutlinedButtonDark()
                : buttonStyles.blueOutlinedButton())
                .copyWith(
                  padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h)),
                ),
            child: Text(
              callToActionText,
              style: TextStyles.font14_600Weight.copyWith(
                color: isDarkMode ? AppColors.darkBlue : AppColors.lightBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }
}