import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        children: [
          SvgPicture.asset(
            'assets/images/man_on_chair.svg',
            width: 300.w,
            height: 200.h,
            fit: BoxFit.cover,
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
