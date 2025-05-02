import 'package:flutter/material.dart';

import 'package:link_up/shared/themes/colors.dart';

class JobStyles {
  static ButtonStyle quickActionButtonStyle(bool isDarkMode) {
    return OutlinedButton.styleFrom(
      foregroundColor: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
      side: BorderSide(
        color: isDarkMode ? AppColors.darkDivider : AppColors.lightDivider,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }

  static BoxDecoration searchBarDecoration(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(24),
    );
  }

  static BoxDecoration collectionItemDecoration(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode ? AppColors.darkSurface : AppColors.lightSurface,
      borderRadius: BorderRadius.circular(12),
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

  static EdgeInsets defaultPadding = EdgeInsets.all(16);
  static EdgeInsets searchBarPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
} 