import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';

class RetryErrorMessage extends ConsumerWidget {
  final String errorMessage;
  final VoidCallback buttonFunctionality;

  const RetryErrorMessage(
      {super.key,
      required this.errorMessage,
      required this.buttonFunctionality});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 10.w,
          children: [
            Text(
              errorMessage,
              style: TextStyles.font20_700Weight.copyWith(
                color: isDarkMode
                    ? AppColors.darkSecondaryText
                    : AppColors.lightTextColor,
              ),
            ),
            ElevatedButton(
              style: isDarkMode
                  ? LinkUpButtonStyles().profileOpenToDark(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.h,
                        horizontal: 15.w,
                      ),
                    )
                  : LinkUpButtonStyles().profileOpenToLight(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.h,
                        horizontal: 15.w,
                      ),
                    ),
              onPressed: buttonFunctionality,
              child: Text(
                "Retry",
                style: TextStyles.font18_700Weight.copyWith(
                  color: isDarkMode
                      ? AppColors.darkBackground
                      : AppColors.lightBackground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
