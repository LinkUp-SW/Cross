import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class SnackbarContent extends ConsumerWidget {
  final String message;
  final IconData icon;

  const SnackbarContent({
    super.key,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      spacing: 10.w,
      children: [
        Icon(
          icon,
          size: 25.w,
        ),
        Flexible(
          child: Text(
            message,
            style: TextStyles.font14_600Weight.copyWith(
              color: isDarkMode
                  ? AppColors.darkSecondaryText
                  : AppColors.lightTextColor,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
