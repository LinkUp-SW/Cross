import 'package:flutter/material.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class SubPagesFormLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const SubPagesFormLabel({super.key, required this.label, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Text(
      label + (isRequired ? "*" : ""),
      style: TextStyles.font14_400Weight.copyWith(
        color: isDarkMode ? AppColors.darkTextColor : AppColors.lightTextColor,
      ),
    );
  }
}