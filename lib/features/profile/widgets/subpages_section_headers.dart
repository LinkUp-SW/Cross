import 'package:flutter/material.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class SubPagesSectionHeader extends StatelessWidget {
  final String title;

  const SubPagesSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Text(
      title,
      style: TextStyles.font18_700Weight.copyWith(
        color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
      ),
    );
  }
}