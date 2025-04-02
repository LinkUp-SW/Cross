import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class StandardEmptyListMessage extends ConsumerWidget {
  final bool isDarkMode;
  final String message;

  const StandardEmptyListMessage({
    super.key,
    required this.isDarkMode,
    required this.message,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10.w,
        children: [
          Image(
            image: const AssetImage('assets/images/man_on_chair.svg'),
            width: 150.w,
            height: 200.h,
          ),
          Text(
            message,
            style: TextStyles.font20_700Weight.copyWith(
              color: isDarkMode
                  ? AppColors.darkSecondaryText
                  : AppColors.lightTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
