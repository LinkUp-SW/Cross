// profile/widgets/subpages_app_bar.dart

import 'package:flutter/material.dart';

import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class SubPagesAppBar extends StatelessWidget {
  final String title;
  final Widget? action;
  final VoidCallback onClosePressed;

  const SubPagesAppBar({
    super.key,
    required this.title,
    this.action,
    required this.onClosePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
              size: 24,
            ),
            onPressed: onClosePressed,
          ),
          // --- Wrap the Text with Flexible ---
          Flexible( // Or Expanded
            child: Text(
              title,
              style: TextStyles.font18_700Weight.copyWith(
                color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
              ),
              textAlign: TextAlign.center, // Center the text if it shrinks
              overflow: TextOverflow.ellipsis, // Handle overflow if needed
              maxLines: 1, // Ensure it stays on one line if possible
            ),
          ),
          // --- End of change ---
          if (action != null) action!,
          // Adjust placeholder if needed, ensure it doesn't take up too much rigid space
          if (action == null) SizedBox(width: 48), // Match IconButton default width roughly
        ],
      ),
    );
  }
}