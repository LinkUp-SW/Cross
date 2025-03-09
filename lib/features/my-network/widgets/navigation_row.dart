import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class NavigationRow extends ConsumerWidget {
  final String title;
  final bool isDarkMode;
  const NavigationRow({
    super.key,
    required this.title,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
      ]),
    );
  }
}
