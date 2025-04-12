import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';

class JobStyles {
  static ButtonStyle quickActionButtonStyle(bool isDarkMode) {
    return OutlinedButton.styleFrom(
      foregroundColor: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
      side: BorderSide(
        color: isDarkMode ? AppColors.darkDivider : AppColors.lightDivider,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
    );
  }

  static BoxDecoration searchBarDecoration(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(24.r),
    );
  }

  static BoxDecoration collectionItemDecoration(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(
        color: isDarkMode ? AppColors.darkDivider : AppColors.lightDivider,
      ),
    );
  }

  static TextStyle sectionTitleStyle(bool isDarkMode, TextTheme textTheme) {
    return textTheme.titleLarge?.copyWith(
      color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
      fontWeight: FontWeight.bold,
    ) ?? const TextStyle();
  }

  static TextStyle sectionSubtitleStyle(bool isDarkMode, TextTheme textTheme) {
    return textTheme.bodyMedium?.copyWith(
      color: isDarkMode ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
    ) ?? const TextStyle();
  }

  static EdgeInsets defaultPadding = EdgeInsets.all(16.w);
  static EdgeInsets searchBarPadding = EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h);
} 