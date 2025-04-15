import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class ManageMyNetworkScreenNavigationRow extends ConsumerWidget {
  final IconData icon;
  final String title;
  final int? count;
  final VoidCallback? onTap;
  final bool isLoading;

  const ManageMyNetworkScreenNavigationRow({
    super.key,
    required this.icon,
    required this.title,
    this.count = 0,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 0.3.w,
                color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
              ),
            ),
          ),
          height: 40.h,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 8.w,
                  children: [
                    Icon(
                      icon,
                      size: 20.h,
                    ),
                    Text(
                      title,
                      style: TextStyles.font16_500Weight.copyWith(
                        color: isDarkMode
                            ? AppColors.darkSecondaryText
                            : AppColors.lightTextColor,
                      ),
                    ),
                  ],
                ),
                if (isLoading)
                  SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      color: isDarkMode
                          ? AppColors.darkSecondaryText
                          : AppColors.lightTextColor,
                    ),
                  )
                else if (count != null)
                  Text(
                    '$count',
                    style: TextStyles.font16_500Weight.copyWith(
                      color: isDarkMode
                          ? AppColors.darkSecondaryText
                          : AppColors.lightTextColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
