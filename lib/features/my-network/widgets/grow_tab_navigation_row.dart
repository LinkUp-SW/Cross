import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class GrowTabNavigationRow extends ConsumerWidget {
  final String title;
  final VoidCallback? onTap;

  const GrowTabNavigationRow({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Text(
                title,
                style: TextStyles.font15_700Weight,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Icon(
                Icons.arrow_forward,
                size: 16.h,
              ),
            )
          ],
        ),
      ),
    );
  }
}
